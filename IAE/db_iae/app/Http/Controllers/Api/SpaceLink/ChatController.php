<?php

namespace App\Http\Controllers\Api\SpaceLink;

use App\Events\ChatMessageSent;
use App\Http\Controllers\Controller;
use App\Models\SpaceLink\SlChatMessage;
use App\Models\SpaceLink\SlCommunity;
use App\Models\SpaceLink\SlCommunityMember;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\DB;

class ChatController extends Controller
{
    public function index(Request $request)
    {
        $userId = $request->user()->id;

        $query = "
            WITH latest_messages AS (
                SELECT 
                    m.*,
                    ROW_NUMBER() OVER (
                        PARTITION BY 
                            CASE 
                                WHEN group_id IS NOT NULL THEN CONCAT('g_', group_id)
                                WHEN sender_id < receiver_id THEN CONCAT('p_', sender_id, '_', receiver_id)
                                ELSE CONCAT('p_', receiver_id, '_', sender_id)
                            END
                        ORDER BY created_at DESC
                    ) as rn
                FROM sl_chat_messages m
                WHERE (m.group_id IS NOT NULL OR m.sender_id = ? OR m.receiver_id = ?)
                  AND (m.group_id IS NULL OR m.group_id IN (
                        SELECT community_id FROM sl_community_members WHERE user_id = ?
                  ))
            )
            SELECT * FROM latest_messages WHERE rn = 1 ORDER BY created_at DESC
        ";

        $results = DB::select($query, [$userId, $userId, $userId]);
        $messageIds = array_column($results, 'id');

        $messages = SlChatMessage::with(['sender.slProfile', 'receiver.slProfile', 'group'])
            ->whereIn('id', $messageIds)
            ->orderBy('created_at', 'desc')
            ->get();

        $formatted = $messages->map(function ($m) use ($userId) {
            $isGroup = $m->group_id !== null;
            $otherUser = null;
            
            if (!$isGroup) {
                $otherUser = $m->sender_id === $userId ? $m->receiver : $m->sender;
            }

            // Exclude if soft-deleted for this user
            if (!$isGroup && $m->sender_id === $userId && $m->deleted_by_sender) {
                return null;
            }
            if (!$isGroup && $m->receiver_id === $userId && $m->deleted_by_receiver) {
                return null;
            }

            return [
                'id' => $isGroup ? $m->group_id : $otherUser?->id,
                'name' => $isGroup ? $m->group?->name : $otherUser?->name,
                'image' => $isGroup 
                    ? ($m->group?->image ? (str_starts_with($m->group->image, 'http') ? $m->group->image : url($m->group->image)) : null)
                    : ($otherUser?->slProfile?->profile_image ?? $otherUser?->avatar),
                'last_message' => $m->message,
                'time' => $m->created_at?->toISOString(),
                'unread_count' => 0, // Simplified for now
                'is_group' => $isGroup,
            ];
        })->filter()->values();

        return response()->json(['data' => $formatted]);
    }

    public function privateMessages(Request $request, int $otherUserId)
    {
        $userId = $request->user()->id;

        $messages = SlChatMessage::with(['sender.slProfile', 'linkedActivity'])
            ->whereNull('group_id')
            ->where(function ($q) use ($userId, $otherUserId) {
                $q->where(function ($q1) use ($userId, $otherUserId) {
                    $q1->where('sender_id', $userId)->where('receiver_id', $otherUserId)->where('deleted_by_sender', false);
                })->orWhere(function ($q2) use ($userId, $otherUserId) {
                    $q2->where('sender_id', $otherUserId)->where('receiver_id', $userId)->where('deleted_by_receiver', false);
                });
            })
            ->orderBy('created_at', 'desc')
            ->get();

        return response()->json([
            'data' => $messages->map(fn ($m) => $this->format($m, $userId)),
        ]);
    }

    public function groupMessages(Request $request, int $groupId)
    {
        $userId = $request->user()->id;
        $isMember = SlCommunityMember::where('community_id', $groupId)->where('user_id', $userId)->exists();
        
        if (!$isMember) {
            return response()->json(['message' => 'Akses ditolak.'], 403);
        }

        $messages = SlChatMessage::with(['sender.slProfile', 'linkedActivity'])
            ->where('group_id', $groupId)
            ->orderBy('created_at', 'desc')
            ->get();

        return response()->json([
            'data' => $messages->map(fn ($m) => $this->format($m, $userId)),
        ]);
    }

    public function send(Request $request)
    {
        $request->validate([
            'message' => 'required|string|max:2000',
            'receiver_id' => 'nullable|integer|exists:users,id',
            'group_id' => 'nullable|integer|exists:sl_communities,id',
            'type' => 'nullable|string|in:text,activity_invite,event_reminder,image',
            'linked_activity_id' => 'nullable|integer|exists:sl_activities,id',
        ]);

        if (!$request->receiver_id && !$request->group_id) {
            return response()->json(['message' => 'Harus ada receiver_id atau group_id.'], 422);
        }

        $message = SlChatMessage::create([
            'sender_id' => $request->user()->id,
            'receiver_id' => $request->receiver_id,
            'group_id' => $request->group_id,
            'message' => $request->message,
            'type' => $request->type ?? 'text',
            'linked_activity_id' => $request->linked_activity_id,
        ]);

        $message->load(['sender', 'sender.slProfile', 'linkedActivity']);

        try {
            broadcast(new ChatMessageSent($message))->toOthers();
        } catch (\Throwable $e) {}

        return response()->json([
            'message' => 'Pesan terkirim.',
            'data' => $this->format($message, $request->user()->id),
        ], 201);
    }

    public function deletePrivateChat(Request $request, int $otherUserId): JsonResponse
    {
        $userId = $request->user()->id;

        SlChatMessage::where('sender_id', $userId)
            ->where('receiver_id', $otherUserId)
            ->update(['deleted_by_sender' => true]);

        SlChatMessage::where('sender_id', $otherUserId)
            ->where('receiver_id', $userId)
            ->update(['deleted_by_receiver' => true]);

        return response()->json(['message' => 'Chat deleted successfully.']);
    }

    public function deleteMessages(Request $request): JsonResponse
    {
        $request->validate([
            'message_ids' => 'required|array',
            'message_ids.*' => 'integer',
        ]);

        $userId = $request->user()->id;

        SlChatMessage::whereIn('id', $request->message_ids)
            ->where('sender_id', $userId)
            ->update(['deleted_by_sender' => true]);

        SlChatMessage::whereIn('id', $request->message_ids)
            ->where('receiver_id', $userId)
            ->update(['deleted_by_receiver' => true]);

        return response()->json(['message' => 'Messages deleted successfully.']);
    }

    private function format(SlChatMessage $m, ?int $currentUserId = null): array
    {
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
            'linked_activity_title' => $m->linkedActivity?->title,
            'is_me' => $currentUserId !== null && $m->sender_id === $currentUserId,
        ];
    }
}