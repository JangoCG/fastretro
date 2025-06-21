<?php

namespace Database\Seeders;

use App\Models\User;
// use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;

class DatabaseSeeder extends Seeder
{
    /**
     * Seed the application's database.
     */
    public function run(): void
    {
        // User::factory(10)->create();

        // Create test user
        User::factory()->create([
            'name' => 'Test User',
            'email' => 'c@c.de',
            'password' => 'c',
        ]);

        User::factory()->create([
            'name' => 'Bansu Amk',
            'email' => 'b@b.de',
            'password' => 'b',
        ]);

        // Run task board seeder
        $this->call(TaskBoardSeeder::class);
        
        // Run demo retro seeder
        $this->call(DemoRetroSeeder::class);
    }
}
