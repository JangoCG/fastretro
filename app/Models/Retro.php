<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Support\Facades\Log;

class Retro extends Model
{
    /** @use HasFactory<\Database\Factories\RetroFactory> */
    use HasFactory, HasUuids;

    const STATE_WAITING = 'WAITING';

    const STATE_BRAINSTORMING = 'BRAINSTORMING';

    const STATE_THEMING = 'THEMING';

    const STATE_VOTING = 'VOTING';

    const STATE_DISCUSSION = 'DISCUSSION';

    const STATE_SUMMARY = 'SUMMARY';

    protected $stateFlow = [
        self::STATE_WAITING => self::STATE_BRAINSTORMING,
        self::STATE_BRAINSTORMING => self::STATE_THEMING,
        self::STATE_THEMING => self::STATE_VOTING,
        self::STATE_VOTING => self::STATE_DISCUSSION,
        self::STATE_DISCUSSION => self::STATE_SUMMARY,
        self::STATE_SUMMARY => null,
    ];

    public function getNextState()
    {
        Log::info('Getting next state');

        return $this->stateFlow[$this->state] ?? null;
    }

    public function transitionToNextState()
    {
        Log::info('Transitioning to next state');
        $nextState = $this->getNextState();

        if ($nextState) {
            $this->state = $nextState;
            $this->save();
        }

        return $this;
    }

    protected $fillable = ['name'];

    /**
     * Indicates if the model's ID is auto-incrementing.
     */
    public $incrementing = false;

    /**
     * The data type of the auto-incrementing ID.
     */
    protected $keyType = 'string';

    public function participants(): HasMany
    {
        return $this->hasMany(Participant::class);
    }

    /**
     * Direkte Beziehung zu Feedbacks
     */
    public function feedbacks(): HasMany
    {
        return $this->hasMany(Feedback::class);
    }

    /**
     * Get all positive feedbacks
     */
    public function positiveFeedbacks(): HasMany
    {
        return $this->feedbacks()->positive();
    }

    /**
     * Get all negative feedbacks
     */
    public function negativeFeedbacks(): HasMany
    {
        return $this->feedbacks()->negative();
    }

    /**
     * Get feedback groups for this retro
     */
    public function feedbackGroups(): HasMany
    {
        return $this->hasMany(FeedbackGroup::class);
    }

    public function actions(): HasMany
    {
        return $this->hasMany(Action::class);
    }
}
