<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class FeedbackGroup extends Model
{
    use HasFactory;

    protected $fillable = ['retro_id'];

    public function feedbacks(): HasMany
    {
        return $this->hasMany(Feedback::class);
    }

    public function retro(): BelongsTo
    {
        return $this->belongsTo(Retro::class);
    }

    public function votes(): HasMany
    {
        return $this->hasMany(Vote::class);
    }
}
