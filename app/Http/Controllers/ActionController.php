<?php

namespace App\Http\Controllers;

use App\Events\ActionCreated;
use App\Models\Action;
use App\Models\Participant;
use App\Models\Retro;
use App\Services\ParticipantSessionService;
use Illuminate\Http\Request;

class ActionController extends Controller
{
    public function __construct(
        private ParticipantSessionService $sessionService
    ) {}

    /**
     * Store a new action
     */
    public function store(Request $request, Retro $retro)
    {
        $validated = $request->validate([
            'content' => 'required|string|max:1000',
            'retro_id' => 'required|string|uuid',
        ]);

        $participant = $this->sessionService->getCurrentParticipant();
        
        if (!$participant) {
            return back()->withErrors(['error' => 'No participant session found']);
        }

        $action = Action::create([
            'content' => $validated['content'],
            'retro_id' => $validated['retro_id'],
            'participant_id' => $participant->id,
        ]);

        broadcast(new ActionCreated($action));

        return back()->with('success', 'Action added successfully');
    }
}