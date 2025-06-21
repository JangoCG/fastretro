<?php

namespace Database\Seeders;

use App\Models\Action;
use App\Models\Feedback;
use App\Models\FeedbackGroup;
use App\Models\Participant;
use App\Models\Retro;
use App\Models\Vote;
use Illuminate\Database\Seeder;
use Illuminate\Support\Str;

class DemoRetroSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        // Create a demo retro in THEMING phase to showcase grouping functionality
        $retro = Retro::create([
            'name' => 'Sprint 23 - Mobile App Release',
            'state' => Retro::STATE_THEMING,
        ]);

        // Create 5 realistic participants
        $participants = [
            [
                'name' => 'Sarah Chen',
                'session_id' => Str::uuid(),
                'role' => 'moderator',
                'status' => 'finished',
            ],
            [
                'name' => 'Marcus Weber',
                'session_id' => Str::uuid(),
                'role' => 'participant',
                'status' => 'finished',
            ],
            [
                'name' => 'Lisa Rodriguez',
                'session_id' => Str::uuid(),
                'role' => 'participant',
                'status' => 'finished',
            ],
            [
                'name' => 'Tom Anderson',
                'session_id' => Str::uuid(),
                'role' => 'participant',
                'status' => 'active',
            ],
            [
                'name' => 'Priya Patel',
                'session_id' => Str::uuid(),
                'role' => 'participant',
                'status' => 'finished',
            ],
        ];

        $createdParticipants = [];
        foreach ($participants as $participantData) {
            $createdParticipants[] = Participant::create([
                'retro_id' => $retro->id,
                ...$participantData,
            ]);
        }

        // Create realistic positive feedback
        $positiveFeedbacks = [
            ['content' => 'Great teamwork during the critical bug fix on Tuesday', 'participant_idx' => 0],
            ['content' => 'The new CI/CD pipeline saved us so much time', 'participant_idx' => 1],
            ['content' => 'Excellent code reviews - caught several potential issues', 'participant_idx' => 2],
            ['content' => 'Really good communication in daily standups', 'participant_idx' => 0],
            ['content' => 'The automated testing paid off - no major bugs in production', 'participant_idx' => 3],
            ['content' => 'Pair programming session was very productive', 'participant_idx' => 4],
            ['content' => 'Great collaboration between frontend and backend teams', 'participant_idx' => 1],
            ['content' => 'Documentation was clear and helpful', 'participant_idx' => 2],
            ['content' => 'Quick response time for fixing the login issue', 'participant_idx' => 3],
            ['content' => 'Good use of feature flags for gradual rollout', 'participant_idx' => 4],
        ];

        $positiveFeedbackModels = [];
        foreach ($positiveFeedbacks as $feedback) {
            $positiveFeedbackModels[] = Feedback::create([
                'content' => $feedback['content'],
                'kind' => 'POSITIVE',
                'participant_id' => $createdParticipants[$feedback['participant_idx']]->id,
                'retro_id' => $retro->id,
            ]);
        }

        // Create realistic negative feedback
        $negativeFeedbacks = [
            ['content' => 'Too many interruptions during focused coding time', 'participant_idx' => 1],
            ['content' => 'Release deployment took much longer than expected', 'participant_idx' => 2],
            ['content' => 'Some user stories were unclear and needed clarification', 'participant_idx' => 3],
            ['content' => 'We underestimated the complexity of the payment integration', 'participant_idx' => 0],
            ['content' => 'Not enough time for proper testing before the deadline', 'participant_idx' => 4],
            ['content' => 'Too many meetings this sprint - less coding time', 'participant_idx' => 1],
            ['content' => 'Database migration script caused temporary downtime', 'participant_idx' => 2],
            ['content' => 'Missing design specs delayed frontend development', 'participant_idx' => 3],
            ['content' => 'Third-party API was unstable during integration', 'participant_idx' => 4],
            ['content' => 'Code conflicts happened too often due to large features', 'participant_idx' => 0],
        ];

        $negativeFeedbackModels = [];
        foreach ($negativeFeedbacks as $feedback) {
            $negativeFeedbackModels[] = Feedback::create([
                'content' => $feedback['content'],
                'kind' => 'NEGATIVE',
                'participant_id' => $createdParticipants[$feedback['participant_idx']]->id,
                'retro_id' => $retro->id,
            ]);
        }

        // Create feedback groups to demonstrate grouping functionality
        $positiveGroups = [
            [
                'feedback_indices' => [0, 3, 6], // teamwork, communication, collaboration
            ],
            [
                'feedback_indices' => [1, 2, 4, 9], // CI/CD, code reviews, testing, feature flags
            ],
            [
                'feedback_indices' => [5, 7, 8], // pair programming, documentation, quick response
            ],
        ];

        foreach ($positiveGroups as $groupData) {
            $group = FeedbackGroup::create([
                'retro_id' => $retro->id,
            ]);

            foreach ($groupData['feedback_indices'] as $index) {
                $positiveFeedbackModels[$index]->update(['feedback_group_id' => $group->id]);
            }
        }

        $negativeGroups = [
            [
                'feedback_indices' => [0, 4, 5], // interruptions, not enough testing time, too many meetings
            ],
            [
                'feedback_indices' => [2, 3, 7], // unclear stories, underestimated complexity, missing specs
            ],
            [
                'feedback_indices' => [1, 6, 8, 9], // deployment, database migration, API issues, conflicts
            ],
        ];

        foreach ($negativeGroups as $groupData) {
            $group = FeedbackGroup::create([
                'retro_id' => $retro->id,
            ]);

            foreach ($groupData['feedback_indices'] as $index) {
                $negativeFeedbackModels[$index]->update(['feedback_group_id' => $group->id]);
            }
        }

        // Add votes to demonstrate voting system (3 votes per participant)
        $allFeedbackGroups = FeedbackGroup::where('retro_id', $retro->id)->get();
        
        foreach ($createdParticipants as $participant) {
            // Each participant gets 3 votes, distributed across different groups
            $votesPerParticipant = 3;
            $groupsToVoteFor = $allFeedbackGroups->random(min($votesPerParticipant, $allFeedbackGroups->count()));
            
            foreach ($groupsToVoteFor as $group) {
                // Vote on a random feedback from the group
                $groupFeedbacks = Feedback::where('feedback_group_id', $group->id)->get();
                if ($groupFeedbacks->isNotEmpty()) {
                    Vote::create([
                        'participant_id' => $participant->id,
                        'feedback_id' => $groupFeedbacks->random()->id,
                    ]);
                }
            }
        }

        // Create some sample action items for the demo
        $actionItems = [
            'Set up dedicated focus time blocks in calendar to reduce interruptions',
            'Create deployment checklist to reduce deployment time',
            'Implement story refinement session before sprint planning',
            'Add API monitoring and alerting for third-party services',
            'Schedule regular architecture discussions to prevent large conflicts',
        ];

        foreach ($actionItems as $actionText) {
            Action::create([
                'content' => $actionText,
                'retro_id' => $retro->id,
                'participant_id' => $createdParticipants[array_rand($createdParticipants)]->id,
            ]);
        }

        $this->command->info("Demo retro created with ID: {$retro->id}");
        $this->command->info("Visit: /retro/{$retro->id} to see the demo");
        $this->command->info("Retro is in THEMING phase - perfect for demonstrating grouping functionality!");
    }
}