<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('votes', function (Blueprint $table) {
            $table->dropUnique(['participant_id', 'feedback_id']);
            $table->dropUnique(['participant_id', 'feedback_group_id']);
        });
    }

    public function down(): void
    {
        Schema::table('votes', function (Blueprint $table) {
            $table->unique(['participant_id', 'feedback_id']);
            $table->unique(['participant_id', 'feedback_group_id']);
        });
    }
};