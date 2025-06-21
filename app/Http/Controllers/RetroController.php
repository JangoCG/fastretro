<?php

namespace App\Http\Controllers;

use App\Events\ParticipantJoined;
use App\Events\ParticipantSelected;
use App\Events\PhaseCompleted;
use App\Models\Participant;
use App\Models\Retro;
use App\Models\RetroCount;
use App\Services\ParticipantSessionService;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Inertia\Inertia;
use Inertia\Response;

class RetroController extends Controller
{
    public function __construct(
        private ParticipantSessionService $sessionService
    ) {}

    public function create()
    {
        return Inertia::render('retro/CreateRetro');
    }

    public function highlightParticipant(Request $request, Retro $retro)
    {
        $validated = $request->validate([
            'participantId' => 'required',
        ]);
        broadcast(new ParticipantSelected($retro->id, $request->participantId));
    }

    public function store(Request $request): RedirectResponse
    {

        $validated = $request->validate([
            'name' => 'required',
            'creator_name' => 'required',
        ]);

        $this->sessionService->clearSession();

        $retro = Retro::create(['name' => $validated['name']]);

        // Increment the global retro counter
        RetroCount::incrementCounter();

        // Create session for the creator
        $sessionId = $this->sessionService->setSession($validated['creator_name']);

        // Create the creator as a participant with moderator role
        $createdParticipant = Participant::create([
            'name' => $validated['creator_name'],
            'retro_id' => $retro->id,
            'session_id' => $sessionId,
            'status' => 'active',
            'role' => 'moderator',
        ]);

        // Broadcast that the moderator has joined
        broadcast(new ParticipantJoined($createdParticipant));

        return to_route('retro.show', $retro->id);
    }

    public function completePhase(Request $request, Retro $retro)
    {
        // Check if the current participant is a moderator
        $participant = Participant::findByCurrentSession();

        if (! $participant || $participant->retro_id !== $retro->id || ! $participant->isModerator()) {
            abort(403, 'Only moderators can complete phases');
        }

        $retro->transitionToNextState();
        broadcast(new PhaseCompleted($retro->id));

        return back();
    }

    public function join(Request $request, Retro $retro): RedirectResponse
    {
        \Log::info('RetroController.join - Retro state: ' . $retro->state, ['retro_id' => $retro->id]);
        
        $validated = $request->validate([
            'name' => 'required',
        ]);

        $sessionId = $this->sessionService->setSession($request->name);

        $createdParticipant = Participant::create([
            'name' => $request->name,
            'retro_id' => $retro->id,
            'session_id' => $sessionId,
            'status' => 'active',
        ]);

        broadcast(new ParticipantJoined($createdParticipant));

        return to_route('retro.show', $retro->id);
    }

    public function show(Retro $retro): Response
    {
        \Log::info('RetroController.show - Retro state: ' . $retro->state, ['retro_id' => $retro->id]);

        $sessionId = $this->sessionService->getSessionId();
        $name = $this->sessionService->getName();

        $participantIsInRetro = $this->sessionService->hasParticipantInRetro($retro->id);

        $participant = Participant::findByCurrentSession();

        $positiveFeedbackOfParticipant = [];
        $negativeFeedbackOfParticipant = [];

        // Load feedback groups for phases where grouping is relevant
        $positiveFeedbackGroups = collect();
        $negativeFeedbackGroups = collect();

        // Load groups for theming and later phases
        if (in_array($retro->state, ['THEMING', 'VOTING', 'DISCUSSION', 'SUMMARY'])) {
            $positiveFeedbackGroups = $retro->feedbackGroups()
                ->whereHas('feedbacks', function ($query) {
                    $query->where('kind', 'POSITIVE');
                })
                ->with(['feedbacks.participant'])
                ->withCount('votes')
                ->get();

            $negativeFeedbackGroups = $retro->feedbackGroups()
                ->whereHas('feedbacks', function ($query) {
                    $query->where('kind', 'NEGATIVE');
                })
                ->with(['feedbacks.participant'])
                ->withCount('votes')
                ->get();

            // Get individual feedbacks (not grouped)
            $positiveFeedbackOfRetro = $retro->feedbacks()
                ->positive()
                ->whereNull('feedback_group_id')
                ->with('participant')
                ->withCount('votes')
                ->get();

            $negativeFeedbackOfRetro = $retro->feedbacks()
                ->negative()
                ->whereNull('feedback_group_id')
                ->with('participant')
                ->withCount('votes')
                ->get();
        } else {
            // For other phases, show all feedback
            $positiveFeedbackOfRetro = $retro->feedbacks()->positive()->with('participant')->get();
            $negativeFeedbackOfRetro = $retro->feedbacks()->negative()->with('participant')->get();
        }

        if ($retro->state != 'WAITING' && $participant !== null) {
            $positiveFeedbackOfParticipant = $participant->feedbacks()->positive()->get();
            $negativeFeedbackOfParticipant = $participant->feedbacks()->negative()->get();

        }

        // Load participant votes for voting phase
        $participantVotes = [];
        if ($retro->state === 'VOTING' && $participant) {
            $participantVotes = $participant->votes()->get();
        }

        // Load actions for discussion phase
        $actions = [];
        if ($retro->state === 'DISCUSSION') {
            $actions = $retro->actions()->with('participant')->get();
        }

        return Inertia::render('retro/ShowRetro', [
            'retro' => $retro,
            'showRegisterModal' => ! $participantIsInRetro,
            'name' => $name,
            'currentParticipant' => $participant,
            'participants' => $retro->participants()->get(),
            'positiveFeedbackOfParticipant' => $positiveFeedbackOfParticipant,
            'negativeFeedbackOfParticipant' => $negativeFeedbackOfParticipant,
            'positiveFeedbackOfRetro' => $positiveFeedbackOfRetro,
            'negativeFeedbackOfRetro' => $negativeFeedbackOfRetro,
            'positiveFeedbackGroups' => $positiveFeedbackGroups,
            'negativeFeedbackGroups' => $negativeFeedbackGroups,
            'participantVotes' => $participantVotes,
            'actions' => $actions,
        ]);
    }

    public function destroy(Retro $retro): RedirectResponse
    {
        // Check if the current participant is a moderator
        $participant = Participant::findByCurrentSession();

        if (! $participant || $participant->retro_id !== $retro->id || ! $participant->isModerator()) {
            abort(403, 'Only moderators can delete retrospectives');
        }

        // Delete the retro (all related data will be cascade deleted)
        $retro->delete();

        return to_route('retro.create')->with('success', 'Retrospective deleted successfully');
    }
}
