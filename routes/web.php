<?php

use App\Http\Controllers\ActionController;
use App\Http\Controllers\FeedbackController;
use App\Http\Controllers\FeedbackGroupController;
use App\Http\Controllers\ParticipantStatusController;
use App\Http\Controllers\RetroController;
use App\Http\Controllers\SessionController as SessionControllerAlias;
use App\Http\Controllers\VoteController;
use Illuminate\Support\Facades\Route;
use Inertia\Inertia;

Route::get('/', function () {
    $retroCount = \App\Models\RetroCount::getTotalRetros();
    return view('welcome', compact('retroCount'));
})->name('home');

Route::patch('sessions', [SessionControllerAlias::class, 'update']);

Route::get('/privacy-policy', function () {
    return view('privacy-policy');
})->name('privacy-policy');

Route::get('/imprint', function () {
    return view('imprint');
})->name('imprint');

Route::post('/retros/{retro}/feedback-highlights', [RetroController::class, 'highlightParticipant'])->name('retro.feedback.highlight');

Route::resource('retro', RetroController::class)->only(['create', 'store', 'show', 'destroy']);
Route::post('/retro/{retro}/join', [RetroController::class, 'join'])->name('retro.join');
Route::patch('/retro/{retro}/phase', [RetroController::class, 'completePhase'])->name('retro.phase.complete');
Route::post('/retro/{retro}/participant/toggle-status', [ParticipantStatusController::class, 'toggleStatus'])->name('retro.participant.toggle-status');

// Vote routes
Route::post('votes', [VoteController::class, 'store'])->name('votes.store');
Route::delete('votes/{vote}', [VoteController::class, 'destroy'])->name('votes.destroy');

// Action routes
Route::post('/retros/{retro}/actions', [ActionController::class, 'store'])->name('actions.store');
Route::patch('/actions/{action}', [ActionController::class, 'update'])->name('actions.update');
Route::delete('/actions/{action}', [ActionController::class, 'destroy'])->name('actions.destroy');

Route::get('dashboard', function () {
    return Inertia::render('Dashboard');
})->middleware(['auth', 'verified'])->name('dashboard');

Route::resource('feedback', FeedbackController::class);

Route::post('feedback/groups', [FeedbackGroupController::class, 'store'])->name('feedback.groups.create');
Route::post('feedback/groups/add', [FeedbackGroupController::class, 'addToGroup'])->name('feedback.groups.add');
Route::post('feedback/groups/remove', [FeedbackGroupController::class, 'removeFromGroup'])->name('feedback.groups.remove');

Route::fallback(function () {
    return redirect()->route('retro.create');
});
// require __DIR__.'/settings.php';
// require __DIR__.'/auth.php';

if (app()->environment('local')) {
    require __DIR__.'/test-broadcasting.php';
}
