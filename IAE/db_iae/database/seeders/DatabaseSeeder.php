<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;

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
        ]);
    }
}
