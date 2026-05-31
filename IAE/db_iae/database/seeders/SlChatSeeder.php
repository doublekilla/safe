<?php

namespace Database\Seeders;

use App\Models\SpaceLink\SlChatMessage;
use App\Models\SpaceLink\SlFriendship;
use App\Models\User;
use Illuminate\Database\Seeder;

class SlChatSeeder extends Seeder
{
    public function run(): void
    {
        $users = User::where('role', 'customer')->get();
        if ($users->count() < 2) return;

        $friendships = SlFriendship::where('status', 'accepted')->take(5)->get();

        $dmConversations = [
            ['Hei! Jadi mabar besok?', 'Jadi dong! Jam 8 ya.', 'Siap! Aku bawa shuttlecock.', 'Oke mantap 👍'],
            ['Bro ada slot futsal malam ini?', 'Kayaknya masih ada deh, cek di booking.', 'Udah ku-book. Join yuk!'],
        ];

        foreach ($friendships as $index => $friendship) {
            $convMessages = $dmConversations[$index % count($dmConversations)];
            $baseTime = now()->subHours(rand(2, 48));

            foreach ($convMessages as $msgIndex => $text) {
                $senderId = $msgIndex % 2 === 0 ? $friendship->user_id : $friendship->friend_id;
                $receiverId = $senderId === $friendship->user_id ? $friendship->friend_id : $friendship->user_id;

                SlChatMessage::create([
                    'sender_id' => $senderId,
                    'receiver_id' => $receiverId,
                    'message' => $text,
                    'type' => 'text',
                    'created_at' => $baseTime->addMinutes($msgIndex * rand(1, 5)),
                ]);
            }
        }
    }
}