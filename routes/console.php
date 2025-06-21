<?php

use Illuminate\Foundation\Inspiring;
use Illuminate\Support\Facades\Artisan;
use Illuminate\Support\Facades\Schedule;

Artisan::command('inspire', function () {
    $this->comment(Inspiring::quote());
})->purpose('Display an inspiring quote');

// Schedule daily deletion of all retrospectives
Schedule::command('retros:delete-all --force')
    ->daily()
    ->at('03:00')
    ->name('delete-all-retros')
    ->withoutOverlapping()
    ->runInBackground();
