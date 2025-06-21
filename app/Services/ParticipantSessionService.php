<?php

namespace App\Services;

use App\Models\Participant;
use Illuminate\Support\Str;

class ParticipantSessionService
{
    private const SESSION_ID_KEY = 'participantSessionId';
    private const SESSION_NAME_KEY = 'name';

    /**
     * Get the current participant session ID
     */
    public function getSessionId(): ?string
    {
        return session(self::SESSION_ID_KEY);
    }

    /**
     * Get the current participant name
     */
    public function getName(): ?string
    {
        return session(self::SESSION_NAME_KEY);
    }

    /**
     * Set the participant session
     */
    public function setSession(string $name, ?string $sessionId = null): string
    {
        $sessionId = $sessionId ?: (string) Str::uuid();
        
        session([
            self::SESSION_ID_KEY => $sessionId,
            self::SESSION_NAME_KEY => $name,
        ]);

        return $sessionId;
    }

    /**
     * Clear the participant session
     */
    public function clearSession(): void
    {
        session()->forget([
            self::SESSION_ID_KEY,
            self::SESSION_NAME_KEY,
        ]);
    }

    /**
     * Check if a participant session exists
     */
    public function hasSession(): bool
    {
        return !empty($this->getSessionId());
    }

    /**
     * Find the participant associated with the current session
     */
    public function getCurrentParticipant(): ?Participant
    {
        $sessionId = $this->getSessionId();
        
        if (!$sessionId) {
            return null;
        }

        return Participant::where('session_id', $sessionId)->first();
    }

    /**
     * Ensure a session exists, creating one if needed
     */
    public function ensureSession(?string $name = null): string
    {
        $sessionId = $this->getSessionId();
        
        if (!$sessionId) {
            $sessionId = $this->setSession($name ?? 'Anonymous');
        }

        return $sessionId;
    }

    /**
     * Check if the current session has a participant in the given retro
     */
    public function hasParticipantInRetro(string $retroId): bool
    {
        $sessionId = $this->getSessionId();
        
        if (!$sessionId) {
            return false;
        }

        return Participant::where('session_id', $sessionId)
            ->where('retro_id', $retroId)
            ->exists();
    }
}