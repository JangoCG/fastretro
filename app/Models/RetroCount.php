<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class RetroCount extends Model
{
    protected $fillable = ['key', 'count'];

    public static function incrementCounter(string $key = 'total_retros_created'): void
    {
        $counter = static::firstOrCreate(['key' => $key], ['count' => 0]);
        $counter->increment('count');
    }

    public static function getCount(string $key = 'total_retros_created'): int
    {
        return static::where('key', $key)->value('count') ?? 0;
    }

    public static function getTotalRetros(): int
    {
        return static::getCount('total_retros_created');
    }
}
