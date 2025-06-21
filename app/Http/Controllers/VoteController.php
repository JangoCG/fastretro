<?php

namespace App\Http\Controllers;

use App\Models\Feedback;
use App\Models\FeedbackGroup;
use App\Models\Vote;
use App\Services\ParticipantSessionService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\Rule;

class VoteController extends Controller
{
    public function __construct(
        private ParticipantSessionService $sessionService
    ) {}

    /**
     * Store a new vote
     */
    public function store(Request $request)
    {
        $validated = $request->validate([
            'type' => ['required', Rule::in(['feedback', 'group'])],
            'id' => 'required|integer',
        ]);

        $participant = $this->sessionService->getCurrentParticipant();
        
        if (!$participant) {
            return back()->withErrors(['error' => 'No participant found']);
        }

        // Check how many votes the participant already has
        $currentVoteCount = Vote::where('participant_id', $participant->id)->count();
        $maxVotes = 3; // Each participant gets 3 votes
        
        if ($currentVoteCount >= $maxVotes) {
            return back()->withErrors(['error' => 'You have already used all your votes']);
        }

        try {
            DB::transaction(function () use ($validated, $participant) {
                $voteData = ['participant_id' => $participant->id];
                
                if ($validated['type'] === 'feedback') {
                    $feedback = Feedback::findOrFail($validated['id']);
                    
                    // Validate that the retro is in VOTING phase
                    if ($feedback->retro->state !== 'VOTING') {
                        throw new \Exception('Voting is only allowed during the VOTING phase');
                    }
                    
                    
                    $voteData['feedback_id'] = $feedback->id;
                } else {
                    $group = FeedbackGroup::findOrFail($validated['id']);
                    
                    // Validate that the retro is in VOTING phase
                    if ($group->retro->state !== 'VOTING') {
                        throw new \Exception('Voting is only allowed during the VOTING phase');
                    }
                    
                    
                    $voteData['feedback_group_id'] = $group->id;
                }
                
                Vote::create($voteData);
            });
            
            return back()->with('success', 'Vote cast successfully');
            
        } catch (\Exception $e) {
            return back()->withErrors(['error' => $e->getMessage()]);
        }
    }

    /**
     * Remove a vote
     */
    public function destroy(Request $request, Vote $vote)
    {
        $participant = $this->sessionService->getCurrentParticipant();
        
        if (!$participant) {
            return back()->withErrors(['error' => 'No participant found']);
        }

        // Ensure the vote belongs to the current participant
        if ($vote->participant_id !== $participant->id) {
            return back()->withErrors(['error' => 'You can only remove your own votes']);
        }

        // Get the retro from either feedback or group
        $retro = null;
        if ($vote->feedback_id) {
            $retro = $vote->feedback->retro;
        } elseif ($vote->feedback_group_id) {
            $retro = $vote->feedbackGroup->retro;
        }

        // Validate that the retro is in VOTING phase
        if ($retro && $retro->state !== 'VOTING') {
            return back()->withErrors(['error' => 'Vote removal is only allowed during the VOTING phase']);
        }

        $vote->delete();

        return back()->with('success', 'Vote removed successfully');
    }
}