<?php

namespace App\Http\Controllers;

use App\Events\ParticipantStatusChanged;
use App\Models\Participant;
use App\Models\Retro;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;

class ParticipantStatusController extends Controller
{
    /**
     * Toggle participant status between active and finished
     */
    public function toggleStatus(Request $request, Retro $retro)
    {
        $participant = Participant::findByCurrentSession();

        if (! $participant || $participant->retro_id !== $retro->id) {
            return back()->withErrors(['error' => 'Participant not found or not in this retro']);
        }

        // Toggle status
        $newStatus = $participant->status === 'finished' ? 'active' : 'finished';
        $participant->update(['status' => $newStatus]);

        Log::info('Participant status changed', [
            'participant_id' => $participant->id,
            'session_id' => $participant->session_id,
            'old_status' => $participant->status === 'finished' ? 'active' : 'finished',
            'new_status' => $newStatus,
            'retro_id' => $retro->id,
        ]);

        broadcast(new ParticipantStatusChanged($participant, $retro));

        return back();
    }
}
