<?php

namespace Database\Seeders;

use App\Models\TaskBoard;
use App\Models\TaskColumn;
use App\Models\Task;
use App\Models\User;
use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;

class TaskBoardSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        // Get the first user or create one
        $user = User::first();
        if (!$user) {
            $user = User::factory()->create([
                'name' => 'Test User',
                'email' => 'test@example.com',
            ]);
        }

        // Create a test board
        $board = TaskBoard::create([
            'title' => 'Test Task Board',
            'user_id' => $user->id,
        ]);

        // Create columns
        $todoColumn = TaskColumn::create([
            'title' => 'To Do',
            'board_id' => $board->id,
            'order' => 0,
        ]);

        $inProgressColumn = TaskColumn::create([
            'title' => 'In Progress',
            'board_id' => $board->id,
            'order' => 1,
        ]);

        // Create tasks in To Do column
        Task::create([
            'title' => 'Konzept entwerfen',
            'description' => 'Brainstorming für das neue Feature',
            'column_id' => $todoColumn->id,
            'order' => 0,
        ]);

        Task::create([
            'title' => 'UI-Design erstellen',
            'description' => 'Figma-Mockups entwickeln',
            'column_id' => $todoColumn->id,
            'order' => 1,
        ]);

        Task::create([
            'title' => 'Style-Guide definieren',
            'description' => 'Farben & Schriften festlegen',
            'column_id' => $todoColumn->id,
            'order' => 2,
        ]);

        Task::create([
            'title' => 'API-Dokumentation',
            'description' => 'OpenAPI Spec schreiben',
            'column_id' => $todoColumn->id,
            'order' => 3,
        ]);

        Task::create([
            'title' => 'Datenbank Schema',
            'description' => 'ERD und Tabellen planen',
            'column_id' => $todoColumn->id,
            'order' => 4,
        ]);

        Task::create([
            'title' => 'Testing Strategy',
            'description' => 'Unit & Integration Tests definieren',
            'column_id' => $todoColumn->id,
            'order' => 5,
        ]);

        // Create tasks in In Progress column
        Task::create([
            'title' => 'Projekt-Setup',
            'description' => 'Vite & Vue konfigurieren',
            'column_id' => $inProgressColumn->id,
            'order' => 0,
        ]);

        Task::create([
            'title' => 'Komponenten bauen',
            'description' => 'Vue-Komponenten entwickeln',
            'column_id' => $inProgressColumn->id,
            'order' => 1,
        ]);

        Task::create([
            'title' => 'Backend API',
            'description' => 'Laravel Controller & Routes',
            'column_id' => $inProgressColumn->id,
            'order' => 2,
        ]);

        Task::create([
            'title' => 'Frontend Integration',
            'description' => 'Inertia.js Setup',
            'column_id' => $inProgressColumn->id,
            'order' => 3,
        ]);

        Task::create([
            'title' => 'State Management',
            'description' => 'Pinia Store implementieren',
            'column_id' => $inProgressColumn->id,
            'order' => 4,
        ]);

        Task::create([
            'title' => 'Error Handling',
            'description' => 'Try-Catch & User Feedback',
            'column_id' => $inProgressColumn->id,
            'order' => 5,
        ]);

        $this->command->info('Task board seeded successfully!');
    }
}
