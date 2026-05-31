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

        // Sample customers
        $customers = [
            ['name' => 'User One', 'email' => 'userone@ex.com', 'phone' => '081234567891'],
            ['name' => 'User Two', 'email' => 'usertwo@ex.com', 'phone' => '081234567892'],
            ['name' => 'User Three', 'email' => 'userthree@ex.com', 'phone' => '081234567893'],
            ['name' => 'User Four', 'email' => 'userfour@ex.com', 'phone' => '081234567894'],
            ['name' => 'User Five', 'email' => 'userfive@ex.com', 'phone' => '081234567895'],
        ];

        foreach ($customers as $customer) {
            User::updateOrCreate(
                ['email' => $customer['email']],
                array_merge($customer, [
                    'role' => 'customer',
                    'password' => Hash::make('password'),
                    'email_verified_at' => now(),
                ])
            );
        }
    }
}
