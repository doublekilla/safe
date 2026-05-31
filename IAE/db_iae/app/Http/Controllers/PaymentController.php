<?php

namespace App\Http\Controllers;

use App\Models\Payment;
use App\Models\Booking;
use App\Services\MidtransService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Log;
use Inertia\Inertia;

class PaymentController extends Controller
{
    public function show(Booking $booking)
    {
        if ($booking->user_id !== Auth::id()) {
            abort(403);
        }

        $booking->load(['payment', 'items.venueField.venue']);

        return Inertia::render('Payments/Show', [
            'booking' => $booking,
            'payment' => $booking->payment,
            'midtransClientKey' => config('midtrans.client_key'),
            'snapUrl' => config('midtrans.snap_url'),
        ]);
    }

    /**
     * Generate or regenerate Snap token for payment.
     */
    public function pay(Booking $booking)
    {
        if ($booking->user_id !== Auth::id()) {
            abort(403);
        }

        $payment = $booking->payment;

        if (!$payment || $payment->status !== 'pending') {
            return back()->withErrors(['payment' => 'Pembayaran tidak dapat diproses.']);
        }

        // Check if payment has expired
        if ($payment->is_expired) {
            $payment->update(['status' => 'expired']);
            $booking->update(['status' => 'cancelled']);

            foreach ($booking->items as $item) {
                $item->schedule()->update(['status' => 'available']);
            }

            return back()->withErrors(['payment' => 'Pembayaran telah kadaluarsa.']);
        }

        try {
            $midtransService = new MidtransService();
            $midtransService->createSnapToken($booking, $payment);

            return back()->with('success', 'Token pembayaran berhasil dibuat.');
        } catch (\Exception $e) {
            Log::error('Midtrans Snap token creation failed: ' . $e->getMessage());
            return back()->withErrors(['payment' => 'Gagal membuat token pembayaran: ' . $e->getMessage()]);
        }
    }

    public function checkStatus(Payment $payment)
    {
        $booking = $payment->booking;

        if ($booking->user_id !== Auth::id()) {
            abort(403);
        }

        // Check if expired
        if ($payment->is_expired && $payment->status === 'pending') {
            $payment->update(['status' => 'expired']);
            $booking->update(['status' => 'cancelled']);

            foreach ($booking->items as $item) {
                $item->schedule()->update(['status' => 'available']);
            }
        }

        // If still pending and has a transaction_id, check Midtrans for real status
        if ($payment->status === 'pending' && $payment->transaction_id) {
            try {
                $serverKey = config('midtrans.server_key');
                $apiUrl = config('midtrans.is_production')
                    ? 'https://api.midtrans.com/v2/'
                    : 'https://api.sandbox.midtrans.com/v2/';

                $response = \Illuminate\Support\Facades\Http::withHeaders([
                    'Accept' => 'application/json',
                    'Authorization' => 'Basic ' . base64_encode($serverKey . ':'),
                ])->get($apiUrl . $payment->transaction_id . '/status');

                if ($response->successful()) {
                    $data = $response->json();
                    $txStatus = $data['transaction_status'] ?? null;
                    $paymentType = $data['payment_type'] ?? $payment->method;

                    if (in_array($txStatus, ['capture', 'settlement'])) {
                        $payment->update([
                            'status' => 'paid',
                            'method' => $paymentType,
                            'paid_at' => now(),
                        ]);
                        $booking->update(['status' => 'confirmed']);

                        Log::info("Payment #{$payment->id} auto-confirmed via Midtrans status check", [
                            'transaction_status' => $txStatus,
                            'payment_type' => $paymentType,
                        ]);
                    } elseif (in_array($txStatus, ['deny', 'cancel'])) {
                        $payment->update(['status' => 'failed']);
                        $booking->update(['status' => 'cancelled']);
                        foreach ($booking->items as $item) {
                            $item->schedule()->update(['status' => 'available']);
                        }
                    } elseif ($txStatus === 'expire') {
                        $payment->update(['status' => 'expired']);
                        $booking->update(['status' => 'cancelled']);
                        foreach ($booking->items as $item) {
                            $item->schedule()->update(['status' => 'available']);
                        }
                    } elseif ($txStatus === 'pending' && $paymentType) {
                        $payment->update(['method' => $paymentType]);
                    }
                }
            } catch (\Exception $e) {
                Log::warning('Midtrans status check failed: ' . $e->getMessage());
            }
        }

        return response()->json([
            'status' => $payment->fresh()->status,
            'booking_status' => $booking->fresh()->status,
            'method' => $payment->fresh()->method,
            'paid_at' => $payment->fresh()->paid_at,
        ]);
    }

    /**
     * Confirm payment from Snap.js callback (onSuccess/onPending).
     * This is needed because Midtrans webhooks can't reach localhost.
     */
    public function confirmFromSnap(Request $request, Booking $booking)
    {
        if ($booking->user_id !== Auth::id()) {
            abort(403);
        }

        $payment = $booking->payment;

        if (!$payment) {
            return response()->json(['error' => 'Payment not found'], 404);
        }

        // Only update if still pending (idempotent)
        if ($payment->status !== 'pending') {
            return response()->json([
                'status' => $payment->status,
                'booking_status' => $booking->fresh()->status,
            ]);
        }

        $transactionStatus = $request->input('transaction_status', 'settlement');
        $paymentType = $request->input('payment_type', 'unknown');

        if (in_array($transactionStatus, ['capture', 'settlement'])) {
            $payment->update([
                'status' => 'paid',
                'method' => $paymentType,
                'paid_at' => now(),
            ]);
            $booking->update(['status' => 'confirmed']);

            Log::info("Payment #{$payment->id} confirmed via Snap callback", [
                'transaction_status' => $transactionStatus,
                'payment_type' => $paymentType,
            ]);
        } elseif ($transactionStatus === 'pending') {
            $payment->update(['method' => $paymentType]);
        }

        return response()->json([
            'status' => $payment->fresh()->status,
            'booking_status' => $booking->fresh()->status,
        ]);
    }
}
