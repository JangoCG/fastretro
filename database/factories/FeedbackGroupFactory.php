<?php

namespace Database\Factories;

use App\Models\FeedbackGroup;
use Illuminate\Database\Eloquent\Factories\Factory;
use Illuminate\Support\Carbon;

class FeedbackGroupFactory extends Factory
{
    protected $model = FeedbackGroup::class;

    public function definition(): array
    {
        return [
            'created_at' => Carbon::now(),
            'updated_at' => Carbon::now(),
        ];
    }
}
