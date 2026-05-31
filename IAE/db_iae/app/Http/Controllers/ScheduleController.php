<?php

namespace App\Http\Controllers;

use App\Models\Schedule;
use App\Models\VenueField;
use Illuminate\Http\Request;

class ScheduleController extends Controller
{
    public function getAvailable(Request $request)
    {
        $request->validate([
            'venue_field_id' => 'required|exists:venue_fields,id',
            'date' => 'required|date|after_or_equal:today',
        ]);

        $schedules = Schedule::where('venue_field_id', $request->venue_field_id)
            ->where('date', $request->date)
            ->orderBy('start_time')
            ->get();

        // Mark past slots as 'expired' for today's date
        $now = now();
        $isToday = $request->date === $now->toDateString();

        if ($isToday) {
            $currentTime = $now->format('H:i:s');
            $schedules->transform(function ($schedule) use ($currentTime) {
                if ($schedule->status === 'available' && $schedule->start_time <= $currentTime) {
                    $schedule->status = 'expired';
                }
                return $schedule;
            });
        }

        return response()->json([
            'schedules' => $schedules,
        ]);
    }

    public function getFieldSchedules(Request $request, VenueField $venueField)
    {
        $date = $request->get('date', now()->toDateString());

        $schedules = Schedule::where('venue_field_id', $venueField->id)
            ->where('date', $date)
            ->orderBy('start_time')
            ->get();

        return response()->json([
            'schedules' => $schedules,
            'field' => $venueField->load('venue'),
        ]);
    }
}
