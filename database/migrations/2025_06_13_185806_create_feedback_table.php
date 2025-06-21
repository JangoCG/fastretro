<?php

use App\Models\FeedbackGroup;
use App\Models\Participant;
use App\Models\Retro;
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('feedback', function (Blueprint $table) {
            $table->id();
            $table->string('content');
            $table->enum('kind', ['POSITIVE', 'NEGATIVE']);
            $table->foreignIdFor(Participant::class)->constrained()->cascadeOnDelete();
            $table->foreignUuid('retro_id')->constrained('retros')->cascadeOnDelete();
            $table->foreignIdFor(FeedbackGroup::class)
                ->nullable()
                ->constrained()
                ->cascadeOnDelete();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('feedback');
    }
};
