<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Vote extends Model
{
    use HasFactory;

    protected $fillable = [
        'participant_id',
        'feedback_id',
        'feedback_group_id',
    ];

    /**
     * The participant who cast this vote
     */
    public function participant(): BelongsTo
    {
        return $this->belongsTo(Participant::class);
    }

    /**
     * The feedback item this vote is for (if any)
     */
    public function feedback(): BelongsTo
    {
        return $this->belongsTo(Feedback::class);
    }

    /**
     * The feedback group this vote is for (if any)
     */
    public function feedbackGroup(): BelongsTo
    {
        return $this->belongsTo(FeedbackGroup::class);
    }
}