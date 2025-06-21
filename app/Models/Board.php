<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Board extends Model
{
    protected $fillable = ['title'];

    public function columns(): HasMany
    {
        return $this->hasMany(Column::class)->orderBy('order');
    }
} 