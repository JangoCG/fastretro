<?php

use App\Models\Retro;
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('feedback_groups', function (Blueprint $table) {
            $table->id();
            $table->timestamps();
            $table->foreignUuid('retro_id')->constrained('retros')->cascadeOnDelete();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('feedback_groups');
    }
};
