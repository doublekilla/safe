<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Payment;
use App\Models\Booking;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Inertia\Inertia;

class PaymentController extends Controller
{
    public function index(Request $request)
    {
        $query = Payment::with(['booking.user:id,name,email,phone', 'booking.items.venueField.venue'])
            ->latest();

        if ($request->filled('status')) {
            $query->byStatus($request->status);
        }

        if ($request->filled('search')) {
            $query->whereHas('booking', function ($q) use ($request) {
                $q->where('booking_code', 'like', "%{$request->search}%")
                  ->orWhereHas('user', function ($q2) use ($request) {
                      $q2->where('name', 'like', "%{$request->search}%");
                  });
            });
        }

        $payments = $query->paginate(15)->withQueryString();

        $stats = [
            'total_paid' => Payment::paid()->sum('amount'),
            'total_pending' => Payment::pending()->sum('amount'),
            'count_pending' => Payment::pending()->count(),
            'count_paid' => Payment::paid()->count(),
        ];

        return Inertia::render('Admin/Payments/Index', [
            'payments' => $payments,
            'filters' => $request->only(['status', 'search']),
            'stats' => $stats,
        ]);
    }

    public function show(Payment $payment)
    {
        $payment->load(['booking.user', 'booking.items.venueField.venue']);

        return Inertia::render('Admin/Payments/Show', [
            'payment' => $payment,
        ]);
    }

    public function verify(Payment $payment)
    {
        $payment->update([
            'status' => 'paid',
            'paid_at' => now(),
        ]);

        $payment->booking->update(['status' => 'confirmed']);

        return back()->with('success', 'Pembayaran berhasil diverifikasi.');
    }

    public function reject(Payment $payment)
    {
        $payment->update(['status' => 'failed']);
        $payment->booking->update(['status' => 'cancelled']);

        // Release schedules
        foreach ($payment->booking->items as $item) {
            $item->schedule()->update(['status' => 'available']);
        }

        return back()->with('success', 'Pembayaran ditolak. Booking dibatalkan.');
    }

    public function refund(Request $request, Payment $payment)
    {
        $request->validate([
            'notes' => 'nullable|string|max:500',
        ]);

        $payment->update([
            'status' => 'refunded',
            'notes' => 'REFUND: ' . ($request->notes ?? 'Refund diproses oleh admin'),
        ]);

        $payment->booking->update(['status' => 'cancelled']);

        // Release schedules
        foreach ($payment->booking->items as $item) {
            $item->schedule()->update(['status' => 'available']);
        }

        return back()->with('success', 'Refund berhasil diproses.');
    }
}
