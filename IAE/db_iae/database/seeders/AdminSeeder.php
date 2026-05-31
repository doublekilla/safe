<?php

namespace Database\Seeders;

use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class AdminSeeder extends Seeder
{
    public function run(): void
    {
        User::updateOrCreate(
            ['email' => 'admin@ex.com'],
            [
                'name' => 'Admin EithSpace',
                'phone' => '081234567890',
                'role' => 'admin',
                'password' => Hash::make('password'),
                'email_verified_at' => now(),
            ]
        );

    }
}
