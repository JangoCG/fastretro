<?php

namespace App\Http\Controllers;

use App\Models\Feedback;
use App\Models\Participant;
use Illuminate\Http\Request;

class FeedbackController extends Controller
{
    public function index() {}

    public function create() {}

    public function store(Request $request)
    {
        $validated = $request->validate([
            'content' => 'required|string|max:500',
            'kind' => 'required|string|in:POSITIVE,NEGATIVE',
        ]);

        $participant = Participant::findByCurrentSession();

        if (! $participant || ! $participant->retro) {
            return redirect()->route('home')->with('error', 'Sie müssen einer Retro beitreten, um Feedback zu geben.');
        }

        Feedback::create([
            'content' => $validated['content'],
            'kind' => $validated['kind'],
            'participant_id' => $participant->id,
            'retro_id' => $participant->retro->id, // Retro ID direkt speichern
        ]);

        return redirect()
            ->route('retro.show', $participant->retro->id)
            ->with('success', 'Feedback wurde erfolgreich hinzugefügt.');
    }

    public function show($id) {}

    public function edit($id) {}

    public function update(Request $request, $id) {}

    public function destroy($id)
    {
        $feedback = Feedback::findOrFail($id);
        $participant = Participant::findByCurrentSession();

        // Sicherstellen, dass nur der Ersteller sein Feedback löschen kann
        if ($feedback->participant_id !== $participant->id) {
            return redirect()->back()->with('error', 'Sie können nur Ihr eigenes Feedback löschen.');
        }

        $retroId = $feedback->retro_id;
        $feedback->delete();

        return redirect()
            ->route('retro.show', $retroId)
            ->with('success', 'Feedback wurde erfolgreich gelöscht.');
    }
}
