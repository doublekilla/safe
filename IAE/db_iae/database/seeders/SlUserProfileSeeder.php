<?php

namespace Database\Seeders;

use App\Models\SpaceLink\SlUserProfile;
use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class SlUserProfileSeeder extends Seeder
{
    public function run(): void
    {
        $slUsers = [
            [
                'name' => 'Rian Pratama',
                'email' => 'rian.pratama@ex.com',
                'phone' => '081234567896',
                'profile' => [
                    'location' => 'Jakarta Selatan',
                    'favorite_sports' => ['badminton', 'futsal'],
                    'skill_level' => 'intermediate',
                    'availability' => ['weekday_evening', 'weekend_morning'],
                    'joining_purpose' => ['competitive', 'health'],
                    'bio' => 'Badminton player sejak SMA. Senang sparring dan kompetisi.',
                    'age' => 27,
                    'gender' => 'male',
                ],
            ],
            [
                'name' => 'Sari Wulandari',
                'email' => 'sari.wulan@ex.com',
                'phone' => '081234567897',
                'profile' => [
                    'location' => 'Jakarta Pusat',
                    'favorite_sports' => ['volleyball', 'basketball'],
                    'skill_level' => 'advanced',
                    'availability' => ['weekend_morning', 'weekend_afternoon'],
                    'joining_purpose' => ['competitive', 'fun'],
                    'bio' => 'Mantan atlet voli kampus. Sekarang aktif di komunitas.',
                    'age' => 25,
                    'gender' => 'female',
                ],
            ]
        ];

        foreach ($slUsers as $userData) {
            $user = User::firstOrCreate(
                ['email' => $userData['email']],
                [
                    'name' => $userData['name'],
                    'password' => Hash::make('password123'),
                    'role' => 'customer',
                    'phone' => $userData['phone'],
                ]
            );

            SlUserProfile::firstOrCreate(
                ['user_id' => $user->id],
                $userData['profile']
            );
        }
    }
}