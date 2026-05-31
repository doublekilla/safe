<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Schedule;
use App\Models\Venue;
use App\Models\VenueField;
use Illuminate\Http\Request;
use Inertia\Inertia;
use Carbon\Carbon;

class ScheduleController extends Controller
{
    public function index(Request $request)
    {
        $venues = Venue::with('fields')->get();
        $date = $request->get('date', now()->toDateString());
        $venueFieldId = $request->get('venue_field_id');

        $schedules = collect();

        if ($venueFieldId) {
            $schedules = Schedule::where('venue_field_id', $venueFieldId)
                ->where('date', $date)
                ->orderBy('start_time')
                ->get();
        }

        return Inertia::render('Admin/Schedules/Index', [
            'venues' => $venues,
            'schedules' => $schedules,
            'filters' => [
                'date' => $date,
                'venue_field_id' => $venueFieldId,
            ],
        ]);
    }

    public function generate(Request $request)
    {
        $request->validate([
            'venue_field_id' => 'required|exists:venue_fields,id',
            'start_date' => 'required|date',
            'end_date' => 'required|date|after_or_equal:start_date',
            'start_hour' => 'required|integer|min:0|max:23',
            'end_hour' => 'required|integer|min:1|max:24|gt:start_hour',
            'slot_duration' => 'nullable|integer|in:60,90,120',
            'price' => 'required|numeric|min:0',
            'excluded_days' => 'nullable|array',
        ]);

        $slotDuration = $request->get('slot_duration', 60);

        $venueField = VenueField::with('venue')->findOrFail($request->venue_field_id);
        $startDate = Carbon::parse($request->start_date);
        $endDate = Carbon::parse($request->end_date);
        $excludedDays = $request->get('excluded_days', []);

        $created = 0;

        while ($startDate->lte($endDate)) {
            // Skip excluded days (0=Sunday, 6=Saturday)
            if (in_array($startDate->dayOfWeek, $excludedDays)) {
                $startDate->addDay();
                continue;
            }

            for ($hour = $request->start_hour; $hour < $request->end_hour; $hour++) {
                $startTime = sprintf('%02d:00:00', $hour);
                $endTime = sprintf('%02d:00:00', $hour + ($slotDuration / 60));

                if ($endTime > sprintf('%02d:00:00', $request->end_hour)) break;

                // Skip if already exists
                $exists = Schedule::where('venue_field_id', $request->venue_field_id)
                    ->where('date', $startDate->toDateString())
                    ->where('start_time', $startTime)
                    ->exists();

                if (!$exists) {
                    Schedule::create([
                        'venue_field_id' => $request->venue_field_id,
                        'date' => $startDate->toDateString(),
                        'start_time' => $startTime,
                        'end_time' => $endTime,
                        'price' => $request->price,
                        'status' => 'available',
                    ]);
                    $created++;
                }
            }

            $startDate->addDay();
        }

        return back()->with('success', "{$created} slot jadwal berhasil dibuat.");
    }

    public function updateStatus(Request $request, Schedule $schedule)
    {
        $request->validate([
            'status' => 'required|in:available,blocked,maintenance',
        ]);

        $schedule->update(['status' => $request->status]);

        return back()->with('success', 'Status jadwal berhasil diperbarui.');
    }

    public function bulkUpdate(Request $request)
    {
        $request->validate([
            'schedule_ids' => 'required|array',
            'schedule_ids.*' => 'exists:schedules,id',
            'status' => 'required|in:available,blocked,maintenance',
        ]);

        Schedule::whereIn('id', $request->schedule_ids)
            ->whereNotIn('status', ['booked', 'pending'])
            ->update(['status' => $request->status]);

        return back()->with('success', 'Jadwal berhasil diperbarui.');
    }

    public function destroy(Schedule $schedule)
    {
        if (in_array($schedule->status, ['booked', 'pending'])) {
            return back()->withErrors(['schedule' => 'Tidak dapat menghapus slot yang sudah dipesan.']);
        }

        $schedule->delete();

        return back()->with('success', 'Slot jadwal berhasil dihapus.');
    }

    /**
     * Open all schedules for a field on a specific date.
     */
    public function openAll(Request $request)
    {
        $request->validate([
            'venue_field_id' => 'required|exists:venue_fields,id',
            'date' => 'required|date',
        ]);

        $count = Schedule::where('venue_field_id', $request->venue_field_id)
            ->where('date', $request->date)
            ->whereNotIn('status', ['booked', 'pending'])
            ->update(['status' => 'available']);

        return back()->with('success', "{$count} slot jadwal berhasil dibuka.");
    }

    /**
     * Block all schedules for a field on a specific date.
     */
    public function blockAll(Request $request)
    {
        $request->validate([
            'venue_field_id' => 'required|exists:venue_fields,id',
            'date' => 'required|date',
        ]);

        $count = Schedule::where('venue_field_id', $request->venue_field_id)
            ->where('date', $request->date)
            ->whereNotIn('status', ['booked', 'pending'])
            ->update(['status' => 'blocked']);

        return back()->with('success', "{$count} slot jadwal berhasil diblokir.");
    }

    /**
     * Block or open a specific time slot across a date range.
     */
    public function blockRange(Request $request)
    {
        $request->validate([
            'venue_field_id' => 'required|exists:venue_fields,id',
            'start_date' => 'required|date',
            'end_date' => 'required|date|after_or_equal:start_date',
            'start_time' => 'required|date_format:H:i',
            'end_time' => 'required|date_format:H:i|after:start_time',
            'action' => 'required|in:block,open',
        ]);

        $targetStatus = $request->action === 'block' ? 'blocked' : 'available';
        $startDate = Carbon::parse($request->start_date);
        $endDate = Carbon::parse($request->end_date);

        $count = Schedule::where('venue_field_id', $request->venue_field_id)
            ->whereBetween('date', [$startDate->toDateString(), $endDate->toDateString()])
            ->where('start_time', $request->start_time . ':00')
            ->where('end_time', $request->end_time . ':00')
            ->whereNotIn('status', ['booked', 'pending'])
            ->update(['status' => $targetStatus]);

        $actionLabel = $request->action === 'block' ? 'diblokir' : 'dibuka';

        return back()->with('success', "{$count} slot jadwal berhasil {$actionLabel}.");
    }
}
