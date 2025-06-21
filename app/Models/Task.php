<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Task extends Model
{
    protected $fillable = ['title', 'description', 'column_id', 'group_id', 'order', 'votes'];

    public function column(): BelongsTo
    {
        return $this->belongsTo(TaskColumn::class, 'column_id');
    }

    public function group(): BelongsTo
    {
        return $this->belongsTo(Task::class, 'group_id');
    }

    public function tasks(): HasMany
    {
        return $this->hasMany(Task::class, 'group_id')->orderBy('order');
    }

    public function isGroup(): bool
    {
        // A task is a group if it has an empty title and description (group placeholder)
        // and if it has child tasks
        return empty($this->title) && empty($this->description) && $this->tasks()->exists();
    }
} 