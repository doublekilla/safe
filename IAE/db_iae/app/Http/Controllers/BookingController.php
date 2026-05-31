<?php

namespace App\Http\Controllers;

use App\Models\Booking;
use App\Models\BookingItem;
use App\Models\Cart;
use App\Models\Payment;
use App\Models\Schedule;
use App\Models\BusinessSetting;
use App\Services\MidtransService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
use Inertia\Inertia;

class BookingController extends Controller
{
    public function index(Request $request)
    {
        // Auto-complete bookings whose slots have ended
        Booking::autoCompleteAll();

        $query = Booking::where('user_id', Auth::id())
            ->with(['items.venueField.venue', 'payment'])
            ->latest();

        if ($request->filled('status')) {
            if ($request->status === 'rescheduled') {
                $query->whereIn('status', ['reschedule_requested', 'rescheduled']);
            } else {
                $query->byStatus($request->status);
            }
        }

        $bookings = $query->paginate(10)->withQueryString();

        return Inertia::render('Bookings/Index', [
            'bookings' => $bookings,
            'filters' => $request->only(['status']),
            'statuses' => ['pending', 'confirmed', 'completed', 'cancelled', 'rescheduled'],
        ]);
    }

    public function show(Booking $booking)
    {
        if ($booking->user_id !== Auth::id()) {
            abort(403);
        }

        $booking->load(['items.venueField.venue', 'items.schedule', 'payment', 'review', 'user']);

        // Auto-complete if all slots ended
        if ($booking->autoCompleteIfDone()) {
            $booking->load(['items.venueField.venue', 'items.schedule', 'payment', 'review', 'user']);
        }

        return Inertia::render('Bookings/Show', [
            'booking' => $booking,
        ]);
    }

    public function checkout()
    {
        $cart = Cart::where('user_id', Auth::id())->first();

        if (!$cart || $cart->items()->count() === 0) {
            return redirect()->route('cart.index')->withErrors(['cart' => 'Keranjang kosong.']);
        }

        $cart->load(['items.schedule', 'items.venueField.venue']);

        $serviceFeePercent = BusinessSetting::get('service_fee_percent', 5);
        $taxPercent = BusinessSetting::get('tax_percent', 11);

        $subtotal = $cart->items->sum('price');
        $serviceFee = $subtotal * ($serviceFeePercent / 100);
        $tax = $subtotal * ($taxPercent / 100);
        $total = $subtotal + $serviceFee + $tax;

        return Inertia::render('Checkout/Index', [
            'cart' => $cart,
            'cartItems' => $cart->items,
            'subtotal' => $subtotal,
            'serviceFee' => round($serviceFee, 2),
            'tax' => round($tax, 2),
            'total' => round($total, 2),
            'serviceFeePercent' => $serviceFeePercent,
            'taxPercent' => $taxPercent,
        ]);
    }

    public function store(Request $request)
    {
        $request->validate([
            'notes' => 'nullable|string|max:500',
        ]);

        $cart = Cart::where('user_id', Auth::id())->with('items.schedule')->first();

        if (!$cart || $cart->items()->count() === 0) {
            return back()->withErrors(['cart' => 'Keranjang kosong.']);
        }

        // Verify all schedules are still available/pending
        foreach ($cart->items as $item) {
            if (!in_array($item->schedule->status, ['available', 'pending'])) {
                return back()->withErrors([
                    'schedule' => "Slot {$item->venueField->name} ({$item->start_time}-{$item->end_time}) sudah tidak tersedia."
                ]);
            }
        }

        $serviceFeePercent = BusinessSetting::get('service_fee_percent', 5);
        $taxPercent = BusinessSetting::get('tax_percent', 11);

        $subtotal = $cart->items->sum('price');
        $serviceFee = round($subtotal * ($serviceFeePercent / 100), 2);
        $tax = round($subtotal * ($taxPercent / 100), 2);
        $total = $subtotal + $serviceFee + $tax;

        return DB::transaction(function () use ($cart, $request, $subtotal, $serviceFee, $tax, $total) {
            // Create booking
            $booking = Booking::create([
                'user_id' => Auth::id(),
                'total_amount' => $subtotal,
                'service_fee' => $serviceFee,
                'tax' => $tax,
                'notes' => $request->notes,
                'status' => 'pending',
            ]);

            // Create booking items from cart
            foreach ($cart->items as $item) {
                BookingItem::create([
                    'booking_id' => $booking->id,
                    'schedule_id' => $item->schedule_id,
                    'venue_field_id' => $item->venue_field_id,
                    'date' => $item->date,
                    'start_time' => $item->start_time,
                    'end_time' => $item->end_time,
                    'price' => $item->price,
                ]);

                // Mark schedule as booked
                Schedule::where('id', $item->schedule_id)->update(['status' => 'booked']);
            }

            // Create payment record
            $payment = Payment::create([
                'booking_id' => $booking->id,
                'amount' => $total,
                'status' => 'pending',
                'expired_at' => now()->addHours(24),
            ]);

            // Generate Midtrans Snap token
            try {
                $midtransService = new MidtransService();
                $midtransService->createSnapToken($booking, $payment);
            } catch (\Exception $e) {
                Log::error('Midtrans Snap token creation failed: ' . $e->getMessage());
                // Don't fail the booking — user can retry token generation on payment page
            }

            // Clear cart
            $cart->items()->delete();

            return redirect()->route('payments.show', $booking->id)
                ->with('success', 'Booking berhasil dibuat! Silakan lakukan pembayaran.');
        });
    }

    public function cancel(Booking $booking)
    {
        if ($booking->user_id !== Auth::id()) {
            abort(403);
        }

        if (!$booking->is_cancellable) {
            return back()->withErrors(['booking' => 'Booking tidak dapat dibatalkan.']);
        }

        DB::transaction(function () use ($booking) {
            // Release schedules
            foreach ($booking->items as $item) {
                Schedule::where('id', $item->schedule_id)->update(['status' => 'available']);
            }

            // Update booking status
            $booking->update(['status' => 'cancelled']);

            // Update payment status
            if ($booking->payment) {
                if ($booking->payment->status === 'paid') {
                    // Already paid → mark as refunded so revenue is excluded
                    $booking->payment->update([
                        'status' => 'refunded',
                        'notes' => 'Dibatalkan oleh customer',
                    ]);
                } elseif ($booking->payment->status === 'pending') {
                    $booking->payment->update(['status' => 'failed']);
                }
            }
        });

        return back()->with('success', 'Booking berhasil dibatalkan.');
    }
}
