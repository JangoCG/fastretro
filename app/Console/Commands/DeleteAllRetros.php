<?php

namespace App\Console\Commands;

use App\Models\Retro;
use Illuminate\Console\Command;

class DeleteAllRetros extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'retros:delete-all {--force : Skip confirmation}';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'Delete all retrospectives and their related data';

    /**
     * Execute the console command.
     */
    public function handle()
    {
        $retroCount = Retro::count();
        
        if ($retroCount === 0) {
            $this->info('No retrospectives found to delete.');
            return Command::SUCCESS;
        }
        
        // Ask for confirmation unless --force flag is used
        if (!$this->option('force')) {
            if (!$this->confirm("This will delete {$retroCount} retrospective(s) and all related data. Are you sure?")) {
                $this->info('Operation cancelled.');
                return Command::SUCCESS;
            }
        }
        
        $this->info("Deleting {$retroCount} retrospective(s)...");
        
        // Delete all retros (cascade will handle related data)
        Retro::query()->delete();
        
        $this->info("Successfully deleted {$retroCount} retrospective(s) and all related data.");
        
        return Command::SUCCESS;
    }
}
