<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Participant extends Model
{
    use HasFactory;

    protected $fillable = ['name', 'retro_id', 'session_id', 'status', 'role'];

    protected $hidden = ['created_at', 'updated_at', 'id'];

    public function retro(): BelongsTo
    {
        return $this->belongsTo(Retro::class);
    }

    public function feedbacks(): HasMany
    {
        return $this->hasMany(Feedback::class);
    }

    public function votes(): HasMany
    {
        return $this->hasMany(Vote::class);
    }

    /**
     * Find the participant for the current session
     */
    public static function findByCurrentSession(): ?self
    {
        return app(\App\Services\ParticipantSessionService::class)->getCurrentParticipant();
    }

    /**
     * Check if the participant is a moderator
     */
    public function isModerator(): bool
    {
        return $this->role === 'moderator';
    }

    /**
     * Check if the participant is a regular participant
     */
    public function isParticipant(): bool
    {
        return $this->role === 'participant';
    }
}
