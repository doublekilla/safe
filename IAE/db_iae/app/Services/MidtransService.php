<?php

namespace App\Services;

use App\Models\Booking;
use App\Models\Payment;
use App\Models\Schedule;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
use Midtrans\Config;
use Midtrans\Snap;
use Midtrans\Notification;

class MidtransService
{
    public function __construct()
    {
        Config::$serverKey = config('midtrans.server_key');
        Config::$clientKey = config('midtrans.client_key');
        Config::$isProduction = config('midtrans.is_production');
        Config::$isSanitized = config('midtrans.is_sanitized');
        Config::$is3ds = config('midtrans.is_3ds');
    }

    /**
     * Create a Snap token for the given booking and payment.
     */
    public function createSnapToken(Booking $booking, Payment $payment): string
    {
        $booking->load(['user', 'items.venueField.venue']);

        $orderId = 'EITH-' . $booking->id . '-' . time();

        $itemDetails = [];
        foreach ($booking->items as $item) {
            $itemDetails[] = [
                'id' => 'SLOT-' . $item->id,
                'price' => (int) $item->price,
                'quantity' => 1,
                'name' => substr(
                    ($item->venueField->venue->name ?? 'Venue') . ' - ' . ($item->venueField->name ?? 'Field'),
                    0,
                    50
                ),
            ];
        }

        // Add service fee as line item
        if ($booking->service_fee > 0) {
            $itemDetails[] = [
                'id' => 'SERVICE-FEE',
                'price' => (int) $booking->service_fee,
                'quantity' => 1,
                'name' => 'Biaya Layanan',
            ];
        }

        // Add tax as line item
        if ($booking->tax > 0) {
            $itemDetails[] = [
                'id' => 'TAX',
                'price' => (int) $booking->tax,
                'quantity' => 1,
                'name' => 'Pajak (PPN)',
            ];
        }

        $params = [
            'transaction_details' => [
                'order_id' => $orderId,
                'gross_amount' => (int) $payment->amount,
            ],
            'item_details' => $itemDetails,
            'customer_details' => [
                'first_name' => $booking->user->name ?? 'Customer',
                'email' => $booking->user->email ?? '',
                'phone' => $booking->user->phone ?? '',
            ],
            'callbacks' => [
                'finish' => route('payments.show', $booking->id),
            ],
            'expiry' => [
                'start_time' => now()->format('Y-m-d H:i:s O'),
                'unit' => 'hours',
                'duration' => 24,
            ],
        ];

        $snapToken = Snap::getSnapToken($params);

        // Save snap token and order_id to payment
        $payment->update([
            'snap_token' => $snapToken,
            'transaction_id' => $orderId,
        ]);

        return $snapToken;
    }

    /**
     * Handle Midtrans webhook notification.
     */
    public function handleNotification(array $payload): void
    {
        $orderId = $payload['order_id'] ?? null;
        $transactionStatus = $payload['transaction_status'] ?? null;
        $fraudStatus = $payload['fraud_status'] ?? null;
        $paymentType = $payload['payment_type'] ?? null;
        $transactionId = $payload['transaction_id'] ?? null;
        $statusCode = $payload['status_code'] ?? null;
        $grossAmount = $payload['gross_amount'] ?? null;
        $signatureKey = $payload['signature_key'] ?? null;

        // Verify signature
        $serverKey = config('midtrans.server_key');
        $expectedSignature = hash('sha512', $orderId . $statusCode . $grossAmount . $serverKey);

        if ($signatureKey !== $expectedSignature) {
            Log::warning('Midtrans: Invalid signature for order ' . $orderId, [
                'expected' => $expectedSignature,
                'received' => $signatureKey,
            ]);
            throw new \Exception('Invalid signature');
        }

        // Find payment by order_id (transaction_id in our DB)
        $payment = Payment::where('transaction_id', $orderId)->first();

        if (!$payment) {
            Log::warning('Midtrans: Payment not found for order ' . $orderId);
            throw new \Exception('Payment not found');
        }

        $booking = $payment->booking;

        // Store raw Midtrans response
        $payment->update([
            'midtrans_transaction_id' => $transactionId,
            'midtrans_payment_type' => $paymentType,
            'midtrans_response' => $payload,
        ]);

        // Handle transaction status (idempotent — skip if already processed)
        DB::transaction(function () use ($payment, $booking, $transactionStatus, $fraudStatus, $paymentType) {
            if ($transactionStatus === 'capture') {
                if ($fraudStatus === 'accept') {
                    $this->markAsPaid($payment, $booking, $paymentType);
                } elseif ($fraudStatus === 'challenge') {
                    // Challenged by fraud detection — keep pending
                    Log::info("Midtrans: Payment {$payment->id} challenged by fraud detection");
                }
            } elseif ($transactionStatus === 'settlement') {
                $this->markAsPaid($payment, $booking, $paymentType);
            } elseif ($transactionStatus === 'pending') {
                // Keep as pending — payment method selected but not completed yet
                if ($payment->status !== 'paid') {
                    $payment->update([
                        'status' => 'pending',
                        'method' => $paymentType,
                    ]);
                }
            } elseif (in_array($transactionStatus, ['deny', 'cancel'])) {
                $this->markAsFailed($payment, $booking);
            } elseif ($transactionStatus === 'expire') {
                $this->markAsExpired($payment, $booking);
            }
        });
    }

    /**
     * Mark payment as paid and booking as confirmed.
     */
    private function markAsPaid(Payment $payment, Booking $booking, ?string $paymentType): void
    {
        // Idempotent: skip if already paid
        if ($payment->status === 'paid') {
            return;
        }

        $payment->update([
            'status' => 'paid',
            'method' => $paymentType,
            'paid_at' => now(),
        ]);

        $booking->update(['status' => 'confirmed']);
    }

    /**
     * Mark payment as failed and cancel booking.
     */
    private function markAsFailed(Payment $payment, Booking $booking): void
    {
        if (in_array($payment->status, ['paid', 'failed'])) {
            return;
        }

        $payment->update(['status' => 'failed']);
        $booking->update(['status' => 'cancelled']);

        $this->releaseSchedules($booking);
    }

    /**
     * Mark payment as expired and cancel booking.
     */
    private function markAsExpired(Payment $payment, Booking $booking): void
    {
        if (in_array($payment->status, ['paid', 'expired'])) {
            return;
        }

        $payment->update(['status' => 'expired']);
        $booking->update(['status' => 'cancelled']);

        $this->releaseSchedules($booking);
    }

    /**
     * Release all booked schedule slots back to available.
     */
    private function releaseSchedules(Booking $booking): void
    {
        foreach ($booking->items as $item) {
            Schedule::where('id', $item->schedule_id)->update(['status' => 'available']);
        }
    }
}
