<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Action extends Model
{
    use HasFactory;

    protected $fillable = ['content', 'retro_id', 'participant_id'];

    protected $hidden = ['created_at', 'updated_at'];

    public function retro(): BelongsTo
    {
        return $this->belongsTo(Retro::class);
    }

    public function participant(): BelongsTo
    {
        return $this->belongsTo(Participant::class);
    }
}