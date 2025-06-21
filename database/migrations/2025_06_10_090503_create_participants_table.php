<?php

use App\Models\Retro;
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        Schema::create('participants', function (Blueprint $table) {
            $table->id();
            $table->string('name');
            $table->uuid('session_id');
            $table->enum('status', ['active', 'finished'])->default('active');
            $table->enum('role', ['moderator', 'participant'])->default('participant');
            $table->timestamps();
            $table->foreignUuid('retro_id')->nullable()->constrained('retros')->cascadeOnDelete();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('participants');
    }
};
