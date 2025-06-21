<?php

use App\Events\ParticipantJoined;
use App\Events\ParticipantStatusChanged;
use App\Models\Participant;
use App\Models\Retro;
use Illuminate\Support\Facades\Route;

Route::get('/test-broadcast', function () {
    $retro = Retro::first();
    $participant = Participant::first();
    
    if (!$retro || !$participant) {
        return response()->json(['error' => 'No retro or participant found']);
    }
    
    // Update participant status
    $participant->update(['status' => 'finished']);
    
    // Broadcast the event
    ParticipantStatusChanged::dispatch($participant, $retro);
    
    return response()->json([
        'message' => 'Event dispatched',
        'participant' => $participant,
        'retro' => $retro->id,
    ]);
});

Route::get('/test-participant-joined', function () {
    $retro = Retro::first();
    
    if (!$retro) {
        return response()->json(['error' => 'No retro found']);
    }
    
    // Create a test participant
    $participant = Participant::create([
        'name' => 'Test Join User ' . rand(1000, 9999),
        'session_id' => 'test-session-' . uniqid(),
        'status' => 'active',
        'role' => 'participant',
        'retro_id' => $retro->id,
    ]);
    
    // Broadcast the ParticipantJoined event
    broadcast(new ParticipantJoined($participant));
    
    return response()->json([
        'message' => 'ParticipantJoined event dispatched',
        'participant' => $participant,
        'retro' => $retro->id,
    ]);
});