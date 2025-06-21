<?php

use App\Models\Feedback;
use App\Models\FeedbackGroup;
use App\Models\Participant;
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('votes', function (Blueprint $table) {
            $table->id();
            $table->timestamps();
            $table->foreignIdFor(Participant::class)->constrained()->cascadeOnDelete();
            
            // A vote can be either for a feedback item OR a feedback group, but not both
            $table->foreignIdFor(Feedback::class)->nullable()->constrained()->cascadeOnDelete();
            $table->foreignIdFor(FeedbackGroup::class)->nullable()->constrained('feedback_groups')->cascadeOnDelete();
            
            // Ensure each participant can only vote once per item/group
            $table->unique(['participant_id', 'feedback_id']);
            $table->unique(['participant_id', 'feedback_group_id']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('votes');
    }
};