<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;

require_once __DIR__ . '/SlUserProfileSeeder.php';
require_once __DIR__ . '/SlCommunitySeeder.php';
require_once __DIR__ . '/SlActivitySeeder.php';
require_once __DIR__ . '/SlFriendshipSeeder.php';
require_once __DIR__ . '/SlFeedSeeder.php';
require_once __DIR__ . '/SlChatSeeder.php';

class DatabaseSeeder extends Seeder
{
    public function run(): void
    {
        $this->call([
            // ─── EithSpace Core ───
            AdminSeeder::class,
            VenueSeeder::class,
            ScheduleSeeder::class,
            FaqSeeder::class,
            BusinessSettingSeeder::class,

            // ─── SpaceLink ───
            SlUserProfileSeeder::class,
            SlCommunitySeeder::class,
            SlActivitySeeder::class,
            SlFriendshipSeeder::class,
            SlFeedSeeder::class,
            SlChatSeeder::class,
        ]);
    }
}
