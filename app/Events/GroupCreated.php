<?php

namespace App\Events;

use App\Models\FeedbackGroup;
use Illuminate\Broadcasting\Channel;
use Illuminate\Broadcasting\InteractsWithSockets;
use Illuminate\Contracts\Broadcasting\ShouldBroadcastNow;
use Illuminate\Foundation\Events\Dispatchable;
use Illuminate\Queue\SerializesModels;

class GroupCreated implements ShouldBroadcastNow
{
    use Dispatchable, InteractsWithSockets, SerializesModels;

    public $group;

    public $retroId;

    /**
     * Create a new event instance.
     */
    public function __construct(FeedbackGroup $group)
    {
        $this->group = $group;
        $this->retroId = $group->retro_id;
    }

    /**
     * Get the channels the event should broadcast on.
     *
     * @return array<int, \Illuminate\Broadcasting\Channel>
     */
    public function broadcastOn(): array
    {
        return [
            new Channel('retro.'.$this->retroId),
        ];
    }

    /**
     * Get the data to broadcast.
     *
     * @return array<string, mixed>
     */
    public function broadcastWith(): array
    {
        return [
            'group' => $this->group->load('feedbacks'),
            'retro_id' => $this->retroId,
        ];
    }
}
