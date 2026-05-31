<?php

namespace Database\Seeders;

use App\Models\SpaceLink\SlFriendship;
use App\Models\User;
use Illuminate\Database\Seeder;

class SlFriendshipSeeder extends Seeder
{
    public function run(): void
    {
        $users = User::where('role', 'customer')->get();
        if ($users->count() < 2) return;

        $pairs = [];

        // Create friendship connections — each user gets 2-4 friends
        foreach ($users as $user) {
            $potentialFriends = $users->where('id', '!=', $user->id)->shuffle()->take(rand(2, 4));

            foreach ($potentialFriends as $friend) {
                $pairKey = min($user->id, $friend->id) . '-' . max($user->id, $friend->id);
                if (in_array($pairKey, $pairs)) continue;

                $pairs[] = $pairKey;

                SlFriendship::updateOrCreate(
                    ['user_id' => $user->id, 'friend_id' => $friend->id],
                    ['status' => 'accepted']
                );
            }
        }

        // Add a few pending requests for realism
        $pendingPairs = $users->shuffle()->take(3);
        for ($i = 0; $i < $pendingPairs->count() - 1; $i++) {
            $from = $pendingPairs[$i];
            $to = $pendingPairs[$i + 1];
            $pairKey = min($from->id, $to->id) . '-' . max($from->id, $to->id);

            if (!in_array($pairKey, $pairs)) {
                SlFriendship::updateOrCreate(
                    ['user_id' => $from->id, 'friend_id' => $to->id],
                    ['status' => 'pending']
                );
            }
        }
    }
}
