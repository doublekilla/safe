<?php

namespace App\Http\Controllers;

use App\Models\Booking;
use App\Models\Schedule;
use App\Models\BookingItem;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\DB;
use Inertia\Inertia;

class RescheduleController extends Controller
{
    public function show(Booking $booking)
    {
        if ($booking->user_id !== Auth::id()) {
            abort(403);
        }

        if (!$booking->is_reschedulable) {
            return redirect()->route('bookings.show', $booking->id)
                ->withErrors(['booking' => 'Booking tidak dapat dijadwal ulang.']);
        }

        $booking->load(['items.venueField.venue', 'items.schedule']);

        return Inertia::render('Bookings/Reschedule', [
            'booking' => $booking,
        ]);
    }

    public function store(Request $request, Booking $booking)
    {
        if ($booking->user_id !== Auth::id()) {
            abort(403);
        }

        $request->validate([
            'items' => 'required|array',
            'items.*.booking_item_id' => 'required|exists:booking_items,id',
            'items.*.new_schedule_id' => 'required|exists:schedules,id',
        ]);

        return DB::transaction(function () use ($request, $booking) {
            foreach ($request->items as $itemData) {
                $bookingItem = BookingItem::findOrFail($itemData['booking_item_id']);

                if ($bookingItem->booking_id !== $booking->id) {
                    continue;
                }

                $newSchedule = Schedule::findOrFail($itemData['new_schedule_id']);

                if ($newSchedule->status !== 'available') {
                    return back()->withErrors(['schedule' => 'Slot baru sudah tidak tersedia.']);
                }

                // Release old schedule
                Schedule::where('id', $bookingItem->schedule_id)->update(['status' => 'available']);

                // Book new schedule
                $newSchedule->update(['status' => 'booked']);

                // Update booking item
                $bookingItem->update([
                    'schedule_id' => $newSchedule->id,
                    'venue_field_id' => $newSchedule->venue_field_id,
                    'date' => $newSchedule->date,
                    'start_time' => $newSchedule->start_time,
                    'end_time' => $newSchedule->end_time,
                    'price' => $newSchedule->price,
                ]);
            }

            $booking->update(['status' => 'rescheduled']);

            return redirect()->route('bookings.show', $booking->id)
                ->with('success', 'Jadwal berhasil diubah.');
        });
    }
}
