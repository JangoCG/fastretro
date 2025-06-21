<?php

namespace App\Http\Controllers;

use App\Events\GroupCreated;
use App\Events\GroupDeleted;
use App\Models\Feedback;
use App\Models\FeedbackGroup;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class FeedbackGroupController extends Controller
{
    public function index() {}

    public function create() {}

    public function store(Request $request)
    {
        $validated = $request->validate([
            'draggedId' => 'required|exists:feedback,id',
            'targetId' => 'required|exists:feedback,id',
        ]);

        $group = null;
        
        DB::transaction(function () use ($validated, &$group) {
            $draggedFeedback = Feedback::findOrFail($validated['draggedId']);
            $targetFeedback = Feedback::findOrFail($validated['targetId']);
            
            // Validate that both feedback items belong to the same retro
            if ($draggedFeedback->retro_id !== $targetFeedback->retro_id) {
                throw new \Exception('Feedback items must belong to the same retro');
            }
            
            // Validate that the retro is in THEMING phase
            $retro = $draggedFeedback->retro;
            if ($retro->state !== 'THEMING') {
                throw new \Exception('Grouping is only allowed during the THEMING phase');
            }

            // Prüfe die Relation über die "magic property" (ohne Klammern)
            // und mit dem NEUEN Methodennamen
            $targetGroup = $targetFeedback->feedbackGroup;

            // Fall 1: Ziel-Feedback hat bereits eine Gruppe
            if ($targetGroup) {
                // Weise das gezogene Feedback der existierenden Gruppe zu
                $draggedFeedback->feedbackGroup()->associate($targetGroup);
                $draggedFeedback->save();
                $group = $targetGroup;
            } else {
                // Fall 2: Beide haben keine Gruppe, erstelle eine neue
                $group = FeedbackGroup::create([
                    'retro_id' => $draggedFeedback->retro_id,
                ]);

                // Weise beide Feedbacks der neuen Gruppe zu
                $draggedFeedback->feedbackGroup()->associate($group);
                $targetFeedback->feedbackGroup()->associate($group);
                $draggedFeedback->save();
                $targetFeedback->save();
            }
        });

        // Broadcast the GroupCreated event
        if ($group) {
            broadcast(new GroupCreated($group))->toOthers();
        }

        return back();
    }

    public function addToGroup(Request $request)
    {
        $validated = $request->validate([
            'feedbackId' => 'required|exists:feedback,id',
            'groupId' => 'required|exists:feedback_groups,id',
        ]);

        $feedback = Feedback::findOrFail($validated['feedbackId']);
        $group = FeedbackGroup::findOrFail($validated['groupId']);
        
        // Validate that the retro is in THEMING phase
        $retro = $feedback->retro;
        if ($retro->state !== 'THEMING') {
            throw new \Exception('Adding to groups is only allowed during the THEMING phase');
        }

        // Assign the feedback to the existing group
        $feedback->feedbackGroup()->associate($group);
        $feedback->save();

        // Broadcast the GroupCreated event (for adding to existing group)
        broadcast(new GroupCreated($group))->toOthers();

        return back();
    }

    public function removeFromGroup(Request $request)
    {
        $validated = $request->validate([
            'feedbackId' => 'required|exists:feedback,id',
        ]);

        $feedback = Feedback::findOrFail($validated['feedbackId']);
        $group = $feedback->feedbackGroup;
        
        // Validate that the retro is in THEMING phase
        $retro = $feedback->retro;
        if ($retro->state !== 'THEMING') {
            throw new \Exception('Removing from groups is only allowed during the THEMING phase');
        }

        // Remove the feedback from its group
        $feedback->feedbackGroup()->dissociate();
        $feedback->save();

        // Check if the group should be deleted (if it has less than 2 items)
        if ($group) {
            $group->refresh();
            $remainingCount = $group->feedbacks()->count();
            
            if ($remainingCount < 2) {
                // Remove remaining feedback items from the group and delete it
                $group->feedbacks()->update(['feedback_group_id' => null]);
                $groupId = $group->id;
                $retroId = $group->retro_id;
                $group->delete();
                
                // Broadcast the GroupDeleted event
                broadcast(new GroupDeleted($groupId, $retroId))->toOthers();
            } else {
                // Group still has items, just broadcast update
                broadcast(new GroupCreated($group))->toOthers();
            }
        }

        return back();
    }

    public function show($id) {}

    public function edit($id) {}

    public function update(Request $request, $id) {}

    public function destroy($id) {}
}
