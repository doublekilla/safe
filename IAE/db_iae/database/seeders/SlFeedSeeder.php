<?php

namespace Database\Seeders;

use App\Models\SpaceLink\SlFeedLike;
use App\Models\SpaceLink\SlFeedPost;
use App\Models\User;
use Illuminate\Database\Seeder;

class SlFeedSeeder extends Seeder
{
    public function run(): void
    {
        $users = User::where('role', 'customer')->get();
        if ($users->count() < 2) return;

        $posts = [
            [
                'user_id' => $users[0]->id,
                'text' => 'Luar biasa match hari ini! Keringat ngucur deras! 🏸🔥',
                'tag' => 'match_result'
            ],
            [
                'user_id' => $users[1]->id,
                'text' => 'Ada yang mau mabar futsal malam ini? Kurang 2 orang nih. DM ya!',
                'tag' => 'announcement'
            ]
        ];

        foreach ($posts as $postData) {
            $post = SlFeedPost::firstOrCreate($postData);

            SlFeedLike::firstOrCreate([
                'feed_post_id' => $post->id,
                'user_id' => $users->last()->id,
            ]);
        }
    }
}