<?php

namespace App\Http\Controllers;

use App\Services\ParticipantSessionService;
use Illuminate\Http\Request;

class SessionController extends Controller
{
    public function __construct(
        private ParticipantSessionService $sessionService
    ) {}

    public function index()
    {

    }

    public function update(Request $request)
    {
        $validated = $request->validate([
            'name' => 'required|string',
            'retroId' => 'required'
        ]);

        $this->sessionService->setSession($validated['name']);

        return to_route('retro.show', $validated['retroId']);
    }
}
