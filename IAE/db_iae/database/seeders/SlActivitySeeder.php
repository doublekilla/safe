<?php

namespace Database\Seeders;

use App\Models\SpaceLink\SlActivity;
use App\Models\SpaceLink\SlActivityParticipant;
use App\Models\SpaceLink\SlCommunity;
use App\Models\User;
use Illuminate\Database\Seeder;

class SlActivitySeeder extends Seeder
{
    public function run(): void
    {
        $users = User::where('role', 'customer')->get();
        if ($users->isEmpty()) return;

        $community = SlCommunity::first();
        $creator = $users->first();

        $activity = SlActivity::firstOrCreate(
            ['title' => 'Mabar Akhir Pekan'],
            [
                'community_id' => $community ? $community->id : null,
                'host_user_id' => $creator->id,
                'notes' => 'Main bareng seru-seruan. Bebas bawa teman.',
                'sport_type' => 'badminton',
                'activity_type' => 'fun_match',
                'location' => 'Gor Badminton Jaya',
                'date' => now()->addDays(2)->toDateString(),
                'time' => '19:00:00',
                'quota' => 10,
                'current_participants' => 3,
                'cost' => 35000,
                'status' => 'available'
            ]
        );

        foreach ($users->take(3) as $user) {
            SlActivityParticipant::firstOrCreate([
                'activity_id' => $activity->id,
                'user_id' => $user->id,
            ], [
                'status' => 'confirmed'
            ]);
        }
    }
}