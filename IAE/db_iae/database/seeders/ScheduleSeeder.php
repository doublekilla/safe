<?php

namespace Database\Seeders;

use App\Models\Schedule;
use App\Models\VenueField;
use Carbon\Carbon;
use Illuminate\Database\Seeder;

class ScheduleSeeder extends Seeder
{
    public function run(): void
    {
        $fields = VenueField::with('venue')->get();

        foreach ($fields as $field) {
            $venue = $field->venue;
            $pricePerHour = $venue->price_per_hour;

            // Generate schedules for next 14 days
            for ($day = 0; $day < 14; $day++) {
                $date = Carbon::now()->addDays($day);
                $dayName = strtolower($date->format('l'));

                $hours = $venue->operating_hours[$dayName] ?? ['08:00', '22:00'];
                $startHour = (int) explode(':', $hours[0])[0];
                $endHour = (int) explode(':', $hours[1])[0];
                if ($endHour === 0) $endHour = 24;

                for ($hour = $startHour; $hour < $endHour; $hour++) {
                    $startTime = sprintf('%02d:00:00', $hour);
                    $endTime = sprintf('%02d:00:00', $hour + 1);

                    // Weekend price premium
                    $price = $pricePerHour;
                    if ($date->isWeekend()) {
                        $price = $pricePerHour * 1.25;
                    }
                    // Peak hour premium (17:00 - 21:00)
                    if ($hour >= 17 && $hour < 21) {
                        $price = $price * 1.2;
                    }

                    Schedule::updateOrCreate(
                        [
                            'venue_field_id' => $field->id,
                            'date' => $date->toDateString(),
                            'start_time' => $startTime,
                        ],
                        [
                            'end_time' => $endTime,
                            'price' => round($price, -3), // Round to nearest thousand
                            'status' => 'available',
                        ]
                    );
                }
            }
        }
    }
}
