<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Attributes\Scope;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Feedback extends Model
{
    use HasFactory;

    protected $fillable = ['content', 'kind', 'participant_id', 'retro_id', 'feedback_group_id'];

    protected $hidden = ['created_at', 'updated_at', 'participant_id'];

    #[Scope]
    protected function positive(Builder $query): void
    {
        $query->where('kind', 'POSITIVE');
    }

    #[Scope]
    protected function negative(Builder $query): void
    {
        $query->where('kind', 'NEGATIVE');
    }

    #[Scope]
    protected function forRetro(Builder $query, $retroId): void
    {
        $query->where('retro_id', $retroId);
    }

    public function participant(): BelongsTo
    {
        return $this->belongsTo(Participant::class);
    }

    public function retro(): BelongsTo
    {
        return $this->belongsTo(Retro::class);
    }

    public function feedbackGroup(): BelongsTo
    {
        return $this->belongsTo(FeedbackGroup::class);
    }

    public function votes(): HasMany
    {
        return $this->hasMany(Vote::class);
    }

    /**
     * Get all feedbacks for a specific retro
     */
    public static function getAllForRetro(Retro $retro)
    {
        return static::forRetro($retro->id)->with('participant')->get();
    }

    /**
     * Get positive feedbacks for a specific retro
     */
    public static function getPositiveForRetro(Retro $retro)
    {
        return static::forRetro($retro->id)->positive()->with('participant')->get();
    }

    /**
     * Get negative feedbacks for a specific retro
     */
    public static function getNegativeForRetro(Retro $retro)
    {
        return static::forRetro($retro->id)->negative()->with('participant')->get();
    }
}
