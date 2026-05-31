<?php

namespace Database\Seeders;

use App\Models\SpaceLink\SlCommunity;
use App\Models\SpaceLink\SlCommunityMember;
use App\Models\User;
use Illuminate\Database\Seeder;

class SlCommunitySeeder extends Seeder
{
    public function run(): void
    {
        $users = User::where('role', 'customer')->get();
        if ($users->isEmpty()) return;

        $communities = [
            [
                'name' => 'JakSel Badminton Club',
                'description' => 'Komunitas pecinta badminton daerah Jakarta Selatan. Rutin main setiap Sabtu pagi.',
                'sport_category' => 'badminton',
                'location' => 'Jakarta Selatan',
                'rules' => 'No baper, always play fair',
                'admin_user_id' => $users->first()->id,
                'privacy' => 'public',
            ],
            [
                'name' => 'Futsal Anak Rantau',
                'description' => 'Ajang silaturahmi anak rantau lewat futsal. Jadwal main fleksibel.',
                'sport_category' => 'futsal',
                'location' => 'Jakarta Barat',
                'rules' => 'Iuran wajib tepat waktu',
                'admin_user_id' => $users->first()->id,
                'privacy' => 'public',
            ],
        ];

        foreach ($communities as $communityData) {
            $community = SlCommunity::firstOrCreate(
                ['name' => $communityData['name']],
                $communityData
            );

            // Add members
            foreach ($users->take(2) as $user) {
                SlCommunityMember::firstOrCreate([
                    'community_id' => $community->id,
                    'user_id' => $user->id,
                ], [
                    'role' => $user->id === $community->admin_user_id ? 'admin' : 'member',
                    'joined_at' => now(),
                ]);
            }
        }
    }
}