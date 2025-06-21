<?php

namespace App\Events;

use App\Models\Participant;
use Illuminate\Broadcasting\Channel;
use Illuminate\Broadcasting\InteractsWithSockets;
use Illuminate\Broadcasting\PrivateChannel;
use Illuminate\Contracts\Broadcasting\ShouldBroadcastNow;
use Illuminate\Foundation\Events\Dispatchable;
use Illuminate\Queue\SerializesModels;

class ParticipantJoined implements ShouldBroadcastNow
{
    use Dispatchable, InteractsWithSockets, SerializesModels;

    public function __construct(protected Participant $participant) {}

    /**
     * Specify which values should be broadcasted.
     */
    public function broadcastWith(): array
    {
        return [
            'participant' => [
                'name' => $this->participant->name,
                'session_id' => $this->participant->session_id,
                'status' => $this->participant->status,
                'role' => $this->participant->role,
                'retro_id' => $this->participant->retro_id,
            ],
        ];
    }

    public function broadcastOn(): array
    {
        return [
            new Channel('retro.'.$this->participant->retro_id),
        ];
    }
}
