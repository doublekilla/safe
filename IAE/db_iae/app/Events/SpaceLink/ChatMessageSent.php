<?php

namespace App\Events\SpaceLink;

use App\Models\SpaceLink\SlChatMessage;
use Illuminate\Broadcasting\Channel;
use Illuminate\Broadcasting\InteractsWithSockets;
use Illuminate\Broadcasting\PresenceChannel;
use Illuminate\Broadcasting\PrivateChannel;
use Illuminate\Contracts\Broadcasting\ShouldBroadcast;
use Illuminate\Foundation\Events\Dispatchable;
use Illuminate\Queue\SerializesModels;

class ChatMessageSent implements ShouldBroadcast
{
    use Dispatchable, InteractsWithSockets, SerializesModels;

    public SlChatMessage $chatMessage;

    public function __construct(SlChatMessage $chatMessage)
    {
        $this->chatMessage = $chatMessage;
    }

    /**
     * Get the channels the event should broadcast on.
     */
    public function broadcastOn(): array
    {
        $channels = [];

        if ($this->chatMessage->group_id) {
            // Group chat → broadcast to community channel
            $channels[] = new PrivateChannel('sl-community.' . $this->chatMessage->group_id);
        }

        if ($this->chatMessage->receiver_id) {
            // DM → broadcast to receiver's private channel
            $channels[] = new PrivateChannel('sl-chat.' . $this->chatMessage->receiver_id);
        }

        return $channels;
    }

    public function broadcastAs(): string
    {
        return 'chat.message.sent';
    }

    /**
     * Data to broadcast.
     */
    public function broadcastWith(): array
    {
        $m = $this->chatMessage;
        $senderProfile = $m->sender?->slProfile;

        return [
            'id' => $m->id,
            'sender_id' => $m->sender_id,
            'sender_name' => $m->sender?->name,
            'sender_image' => $senderProfile?->profile_image ?? $m->sender?->avatar,
            'receiver_id' => $m->receiver_id,
            'group_id' => $m->group_id,
            'message' => $m->message,
            'time' => $m->created_at?->toISOString(),
            'created_at' => $m->created_at?->toISOString(),
            'type' => $m->type,
            'linked_activity_id' => $m->linked_activity_id,
        ];
    }
}