<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Booking;
use App\Models\BookingItem;
use App\Models\Payment;
use App\Models\Schedule;
use App\Models\Venue;
use App\Models\VenueField;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Inertia\Inertia;

class BookingController extends Controller
{
    public function index(Request $request)
    {
        // Auto-complete bookings whose slots have ended
        Booking::autoCompleteAll();

        $query = Booking::with(['user:id,name,email,phone', 'items.venueField.venue', 'payment'])
            ->latest();

        if ($request->filled('status')) {
            $query->byStatus($request->status);
        }

        if ($request->filled('date')) {
            $query->whereDate('created_at', $request->date);
        }

        if ($request->filled('search')) {
            $query->where(function ($q) use ($request) {
                $q->where('booking_code', 'like', "%{$request->search}%")
                  ->orWhereHas('user', function ($q2) use ($request) {
                      $q2->where('name', 'like', "%{$request->search}%")
                         ->orWhere('email', 'like', "%{$request->search}%");
                  });
            });
        }

        $bookings = $query->paginate(15)->withQueryString();

        return Inertia::render('Admin/Bookings/Index', [
            'bookings' => $bookings,
            'filters' => $request->only(['status', 'date', 'search']),
            'statuses' => ['pending', 'confirmed', 'completed', 'cancelled', 'reschedule_requested', 'rescheduled'],
        ]);
    }

    public function show(Booking $booking)
    {
        $booking->load(['user', 'items.venueField.venue', 'items.schedule', 'payment', 'review']);

        // Auto-complete if all slots ended
        if ($booking->autoCompleteIfDone()) {
            $booking->load(['user', 'items.venueField.venue', 'items.schedule', 'payment', 'review']);
        }

        return Inertia::render('Admin/Bookings/Show', [
            'booking' => $booking,
        ]);
    }

    public function updateStatus(Request $request, Booking $booking)
    {
        $request->validate([
            'status' => 'required|in:pending,confirmed,completed,cancelled,reschedule_requested,rescheduled',
        ]);

        $oldStatus = $booking->status;
        $newStatus = $request->status;

        DB::transaction(function () use ($booking, $newStatus, $oldStatus) {
            $booking->update(['status' => $newStatus]);

            // If cancelled, release schedules
            if ($newStatus === 'cancelled' && $oldStatus !== 'cancelled') {
                foreach ($booking->items as $item) {
                    Schedule::where('id', $item->schedule_id)->update(['status' => 'available']);
                }

                if ($booking->payment && $booking->payment->status === 'pending') {
                    $booking->payment->update(['status' => 'failed']);
                }
            }
        });

        return back()->with('success', 'Status booking berhasil diperbarui.');
    }

    public function manualCreate()
    {
        $venues = Venue::active()->with(['fields' => function ($q) {
            $q->active();
        }])->get();

        return Inertia::render('Admin/Bookings/ManualCreate', [
            'venues' => $venues,
        ]);
    }

    public function manualStore(Request $request)
    {
        $request->validate([
            'customer_name' => 'required|string|max:255',
            'customer_phone' => 'required|string|max:20',
            'schedule_ids' => 'required|array|min:1',
            'schedule_ids.*' => 'exists:schedules,id',
            'payment_method' => 'required|string',
            'notes' => 'nullable|string',
        ]);

        return DB::transaction(function () use ($request) {
            $schedules = Schedule::whereIn('id', $request->schedule_ids)
                ->where('status', 'available')
                ->get();

            if ($schedules->count() !== count($request->schedule_ids)) {
                return back()->withErrors(['schedule' => 'Beberapa slot sudah tidak tersedia.']);
            }

            $totalAmount = $schedules->sum('price');

            // Create or find walk-in user
            $user = \App\Models\User::firstOrCreate(
                ['phone' => $request->customer_phone],
                [
                    'name' => $request->customer_name,
                    'email' => 'walkin_' . time() . '@eithspace.local',
                    'password' => bcrypt('walkin_' . time()),
                    'role' => 'customer',
                ]
            );

            $booking = Booking::create([
                'user_id' => $user->id,
                'total_amount' => $totalAmount,
                'notes' => $request->notes ?? 'Booking manual - Walk-in/Telepon',
                'status' => 'confirmed',
            ]);

            foreach ($schedules as $schedule) {
                BookingItem::create([
                    'booking_id' => $booking->id,
                    'schedule_id' => $schedule->id,
                    'venue_field_id' => $schedule->venue_field_id,
                    'date' => $schedule->date,
                    'start_time' => $schedule->start_time,
                    'end_time' => $schedule->end_time,
                    'price' => $schedule->price,
                ]);

                Schedule::where('id', $schedule->id)->update(['status' => 'booked']);
            }

            Payment::create([
                'booking_id' => $booking->id,
                'amount' => $totalAmount,
                'method' => $request->payment_method,
                'status' => 'paid',
                'paid_at' => now(),
            ]);

            return redirect()->route('admin.bookings.index')
                ->with('success', 'Booking manual berhasil dibuat.');
        });
    }
}
