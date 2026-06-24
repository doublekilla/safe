<?php

namespace Database\Seeders;

use App\Models\Booking;
use App\Models\BookingItem;
use App\Models\Payment;
use App\Models\Schedule;
use App\Models\User;
use Carbon\Carbon;
use Illuminate\Database\Seeder;
use Illuminate\Support\Str;

class PaymentDataSeeder extends Seeder
{
    /**
     * Seed payment data for all customer users from June 1 - 17, 2026.
     * Each customer gets minimum 3 bookings with payments.
     */
    public function run(): void
    {
        $startDate = Carbon::parse('2026-06-01');
        $endDate   = Carbon::parse('2026-06-17');

        // Get all customer users (exclude admin)
        $customers = User::where('role', '!=', 'admin')->get();

        if ($customers->isEmpty()) {
            $this->command->warn('No customer users found. Skipping PaymentDataSeeder.');
            return;
        }

        // Payment methods available in the system
        $paymentMethods = [
            'bank_transfer', 'qris', 'gopay', 'shopeepay',
            'credit_card', 'bca_va', 'bni_va', 'bri_va',
        ];

        // Realistic booking notes in Indonesian
        $bookingNotes = [
            'Booking untuk latihan rutin mingguan',
            'Sparring match dengan teman kantor',
            'Latihan persiapan turnamen',
            'Main bareng komunitas',
            'Sewa lapangan untuk acara kantor',
            'Booking untuk latihan anak-anak',
            'Fun match akhir pekan',
            'Latihan pagi sebelum kerja',
            'Booking untuk ulang tahun teman',
            'Olahraga rutin bersama keluarga',
            'Pertandingan antar divisi',
            'Latihan intensif menjelang kompetisi',
            'Booking reguler bulanan',
            'Sewa lapangan untuk gathering komunitas',
            null, // some bookings have no notes
            null,
            null,
        ];

        // Payment notes in Indonesian
        $paymentNotes = [
            'Pembayaran via mobile banking',
            'Transfer dari rekening BCA',
            'Pembayaran melalui e-wallet',
            'Scan QRIS di aplikasi',
            'Auto-debit kartu kredit',
            'Pembayaran lewat internet banking',
            'Transfer via ATM',
            null,
            null,
            null,
        ];

        // How many bookings per user (3–5 for variety)
        $bookingsPerUser = [
            3, 4, 5, 3, 4, 5, 3, 4, 3, 5, 4,
        ];

        // Predefined booking scenarios for realistic data diversity
        // Each scenario: [booking_status, payment_status, days_offset_from_start (0-16)]
        $scenarios = [
            // Completed & paid bookings (most common - past dates)
            ['completed', 'paid'],
            ['completed', 'paid'],
            ['completed', 'paid'],
            // Confirmed & paid (upcoming)
            ['confirmed', 'paid'],
            ['confirmed', 'paid'],
            // Pending payment
            ['pending', 'pending'],
            // Cancelled
            ['cancelled', 'refunded'],
            ['cancelled', 'failed'],
            // Failed payment
            ['pending', 'expired'],
            // Rescheduled
            ['rescheduled', 'paid'],
            ['reschedule_requested', 'paid'],
        ];

        $createdBookings = 0;
        $createdPayments = 0;
        $usedScheduleIds = [];

        foreach ($customers as $index => $customer) {
            $numBookings = $bookingsPerUser[$index % count($bookingsPerUser)];

            $this->command->info("Creating {$numBookings} bookings for {$customer->name} (ID: {$customer->id})...");

            for ($i = 0; $i < $numBookings; $i++) {
                // Pick a scenario
                $scenario = $scenarios[($index * 7 + $i) % count($scenarios)];
                $bookingStatus = $scenario[0];
                $paymentStatus = $scenario[1];

                // Spread dates across June 1-17
                $dayOffset = ($index * 3 + $i * 2) % 17; // 0 to 16
                $bookingDate = $startDate->copy()->addDays($dayOffset);

                // For completed/past bookings, created_at should be before the booking date
                // For pending, use more recent dates
                if (in_array($bookingStatus, ['completed', 'confirmed', 'rescheduled'])) {
                    $createdAt = $bookingDate->copy()->subDays(rand(1, 3))->setTime(rand(7, 22), rand(0, 59), rand(0, 59));
                } else {
                    $createdAt = $bookingDate->copy()->subDays(rand(0, 1))->setTime(rand(7, 22), rand(0, 59), rand(0, 59));
                }

                // Ensure created_at is within June 1-17 range
                if ($createdAt->lt($startDate)) {
                    $createdAt = $startDate->copy()->setTime(rand(7, 22), rand(0, 59), rand(0, 59));
                }
                if ($createdAt->gt($endDate->copy()->endOfDay())) {
                    $createdAt = $endDate->copy()->setTime(rand(7, 18), rand(0, 59), rand(0, 59));
                }

                // Pick a random available schedule for this date
                $schedule = Schedule::where('date', $bookingDate->toDateString())
                    ->where('status', 'available')
                    ->whereNotIn('id', $usedScheduleIds)
                    ->inRandomOrder()
                    ->first();

                if (!$schedule) {
                    // Try nearby dates if exact date has no slots
                    for ($try = 1; $try <= 5; $try++) {
                        $tryDate = $bookingDate->copy()->addDays($try);
                        if ($tryDate->gt($endDate)) {
                            $tryDate = $startDate->copy()->addDays($try);
                        }
                        $schedule = Schedule::where('date', $tryDate->toDateString())
                            ->where('status', 'available')
                            ->whereNotIn('id', $usedScheduleIds)
                            ->inRandomOrder()
                            ->first();
                        if ($schedule) {
                            $bookingDate = $tryDate;
                            break;
                        }
                    }
                }

                if (!$schedule) {
                    $this->command->warn("  No available schedule found for booking #{$i}. Skipping...");
                    continue;
                }

                $usedScheduleIds[] = $schedule->id;

                // Determine if booking has multiple items (20% chance for 2 slots)
                $numItems = (rand(1, 5) === 1) ? 2 : 1;
                $secondSchedule = null;

                if ($numItems === 2) {
                    // Try to find a consecutive slot on same field, same date
                    $secondSchedule = Schedule::where('date', $bookingDate->toDateString())
                        ->where('venue_field_id', $schedule->venue_field_id)
                        ->where('start_time', $schedule->end_time) // consecutive
                        ->where('status', 'available')
                        ->whereNotIn('id', $usedScheduleIds)
                        ->first();

                    if ($secondSchedule) {
                        $usedScheduleIds[] = $secondSchedule->id;
                    } else {
                        $numItems = 1;
                    }
                }

                // Calculate amounts
                $totalAmount = (float) $schedule->price;
                if ($secondSchedule) {
                    $totalAmount += (float) $secondSchedule->price;
                }

                $serviceFee = round($totalAmount * 0.05, 2); // 5% service fee
                $tax = round($totalAmount * 0.11, 2);        // 11% PPN
                $grandTotal = $totalAmount + $serviceFee + $tax;

                // Create booking
                $booking = Booking::create([
                    'user_id'      => $customer->id,
                    'booking_code' => 'ES-' . strtoupper(Str::random(8)),
                    'total_amount' => $totalAmount,
                    'service_fee'  => $serviceFee,
                    'tax'          => $tax,
                    'notes'        => $bookingNotes[array_rand($bookingNotes)],
                    'status'       => $bookingStatus,
                    'created_at'   => $createdAt,
                    'updated_at'   => $createdAt,
                ]);

                // Create booking item(s)
                BookingItem::create([
                    'booking_id'     => $booking->id,
                    'schedule_id'    => $schedule->id,
                    'venue_field_id' => $schedule->venue_field_id,
                    'date'           => $bookingDate->toDateString(),
                    'start_time'     => $schedule->start_time,
                    'end_time'       => $schedule->end_time,
                    'price'          => $schedule->price,
                    'created_at'     => $createdAt,
                    'updated_at'     => $createdAt,
                ]);

                if ($secondSchedule) {
                    BookingItem::create([
                        'booking_id'     => $booking->id,
                        'schedule_id'    => $secondSchedule->id,
                        'venue_field_id' => $secondSchedule->venue_field_id,
                        'date'           => $bookingDate->toDateString(),
                        'start_time'     => $secondSchedule->start_time,
                        'end_time'       => $secondSchedule->end_time,
                        'price'          => $secondSchedule->price,
                        'created_at'     => $createdAt,
                        'updated_at'     => $createdAt,
                    ]);
                }

                // Mark schedules as booked (for paid/confirmed/completed bookings)
                if (in_array($paymentStatus, ['paid'])) {
                    $schedule->update(['status' => 'booked']);
                    if ($secondSchedule) {
                        $secondSchedule->update(['status' => 'booked']);
                    }
                }

                // Create payment
                $method = $paymentMethods[array_rand($paymentMethods)];
                $paidAt = null;
                $expiredAt = null;
                $transactionId = null;
                $snapToken = null;
                $midtransTransactionId = null;
                $midtransPaymentType = null;
                $midtransResponse = null;

                if ($paymentStatus === 'paid') {
                    $paidAt = $createdAt->copy()->addMinutes(rand(1, 30));
                    $transactionId = 'EITH-' . $booking->id . '-' . $createdAt->timestamp;
                    $midtransTransactionId = 'midtrans-' . Str::uuid()->toString();
                    $midtransPaymentType = $method;
                    $snapToken = 'snap-' . Str::random(32);
                    $midtransResponse = [
                        'status_code'    => '200',
                        'transaction_id' => $midtransTransactionId,
                        'order_id'       => $booking->booking_code,
                        'gross_amount'   => number_format($grandTotal, 2, '.', ''),
                        'payment_type'   => $method,
                        'transaction_status' => 'settlement',
                        'fraud_status'   => 'accept',
                        'transaction_time' => $paidAt->toDateTimeString(),
                    ];
                } elseif ($paymentStatus === 'pending') {
                    $expiredAt = $createdAt->copy()->addHours(24);
                    $snapToken = 'snap-' . Str::random(32);
                    $midtransTransactionId = 'midtrans-' . Str::uuid()->toString();
                    $midtransPaymentType = $method;
                } elseif ($paymentStatus === 'expired') {
                    $expiredAt = $createdAt->copy()->addHours(24);
                    $transactionId = 'EITH-' . $booking->id . '-' . $createdAt->timestamp;
                    $snapToken = 'snap-' . Str::random(32);
                    $midtransTransactionId = 'midtrans-' . Str::uuid()->toString();
                    $midtransPaymentType = $method;
                    $midtransResponse = [
                        'status_code'    => '407',
                        'transaction_id' => $midtransTransactionId,
                        'order_id'       => $booking->booking_code,
                        'gross_amount'   => number_format($grandTotal, 2, '.', ''),
                        'payment_type'   => $method,
                        'transaction_status' => 'expire',
                        'transaction_time' => $expiredAt->toDateTimeString(),
                    ];
                } elseif ($paymentStatus === 'failed') {
                    $transactionId = 'EITH-' . $booking->id . '-' . $createdAt->timestamp;
                    $snapToken = 'snap-' . Str::random(32);
                    $midtransTransactionId = 'midtrans-' . Str::uuid()->toString();
                    $midtransPaymentType = $method;
                    $midtransResponse = [
                        'status_code'    => '202',
                        'transaction_id' => $midtransTransactionId,
                        'order_id'       => $booking->booking_code,
                        'gross_amount'   => number_format($grandTotal, 2, '.', ''),
                        'payment_type'   => $method,
                        'transaction_status' => 'deny',
                        'transaction_time' => $createdAt->toDateTimeString(),
                    ];
                } elseif ($paymentStatus === 'refunded') {
                    $paidAt = $createdAt->copy()->addMinutes(rand(1, 15));
                    $transactionId = 'EITH-' . $booking->id . '-' . $createdAt->timestamp;
                    $snapToken = 'snap-' . Str::random(32);
                    $midtransTransactionId = 'midtrans-' . Str::uuid()->toString();
                    $midtransPaymentType = $method;
                    $midtransResponse = [
                        'status_code'    => '200',
                        'transaction_id' => $midtransTransactionId,
                        'order_id'       => $booking->booking_code,
                        'gross_amount'   => number_format($grandTotal, 2, '.', ''),
                        'payment_type'   => $method,
                        'transaction_status' => 'refund',
                        'transaction_time' => $paidAt->toDateTimeString(),
                    ];
                }

                Payment::create([
                    'booking_id'              => $booking->id,
                    'amount'                  => $grandTotal,
                    'method'                  => $method,
                    'status'                  => $paymentStatus,
                    'payment_proof'           => null,
                    'transaction_id'          => $transactionId,
                    'snap_token'              => $snapToken,
                    'midtrans_transaction_id' => $midtransTransactionId,
                    'midtrans_payment_type'   => $midtransPaymentType,
                    'midtrans_response'       => $midtransResponse,
                    'paid_at'                 => $paidAt,
                    'expired_at'              => $expiredAt,
                    'notes'                   => $paymentNotes[array_rand($paymentNotes)],
                    'created_at'              => $createdAt,
                    'updated_at'              => $paidAt ?? $expiredAt ?? $createdAt,
                ]);

                $createdBookings++;
                $createdPayments++;
            }
        }

        $this->command->newLine();
        $this->command->info("✅ PaymentDataSeeder completed!");
        $this->command->info("   Created {$createdBookings} bookings with {$createdPayments} payments");
        $this->command->info("   For {$customers->count()} customer users");
        $this->command->info("   Date range: June 1 - 17, 2026");
    }
}
