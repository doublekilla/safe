<?php

namespace Database\Seeders;

use App\Models\BusinessSetting;
use Illuminate\Database\Seeder;

class BusinessSettingSeeder extends Seeder
{
    public function run(): void
    {
        $settings = [
            ['key' => 'service_fee_percent', 'value' => '5', 'type' => 'integer', 'group' => 'payment', 'label' => 'Service Fee (%)'],
            ['key' => 'tax_percent', 'value' => '11', 'type' => 'integer', 'group' => 'payment', 'label' => 'Pajak PPN (%)'],
            ['key' => 'payment_expiry_hours', 'value' => '24', 'type' => 'integer', 'group' => 'payment', 'label' => 'Batas Waktu Pembayaran (Jam)'],
            ['key' => 'min_booking_hours', 'value' => '1', 'type' => 'integer', 'group' => 'booking', 'label' => 'Minimum Booking (Jam)'],
            ['key' => 'max_booking_hours', 'value' => '4', 'type' => 'integer', 'group' => 'booking', 'label' => 'Maksimum Booking (Jam)'],
            ['key' => 'reschedule_before_hours', 'value' => '2', 'type' => 'integer', 'group' => 'booking', 'label' => 'Reschedule Minimal Sebelum (Jam)'],
            ['key' => 'cancel_before_hours', 'value' => '4', 'type' => 'integer', 'group' => 'booking', 'label' => 'Cancel Minimal Sebelum (Jam)'],
            ['key' => 'buffer_time_minutes', 'value' => '0', 'type' => 'integer', 'group' => 'booking', 'label' => 'Buffer Time Antar Booking (Menit)'],
            ['key' => 'active_payment_methods', 'value' => '["transfer_bank","ewallet","qris"]', 'type' => 'json', 'group' => 'payment', 'label' => 'Metode Pembayaran Aktif'],
            ['key' => 'company_name', 'value' => 'EithSpace Sports Center', 'type' => 'string', 'group' => 'general', 'label' => 'Nama Perusahaan'],
            ['key' => 'company_address', 'value' => 'Jl. Olahraga No. 8, Jakarta Selatan, DKI Jakarta 12345', 'type' => 'string', 'group' => 'general', 'label' => 'Alamat'],
            ['key' => 'company_phone', 'value' => '021-12345678', 'type' => 'string', 'group' => 'general', 'label' => 'Telepon'],
            ['key' => 'company_email', 'value' => 'info@eithspace.com', 'type' => 'string', 'group' => 'general', 'label' => 'Email'],
            ['key' => 'company_whatsapp', 'value' => '6281234567890', 'type' => 'string', 'group' => 'general', 'label' => 'WhatsApp'],
        ];

        foreach ($settings as $setting) {
            BusinessSetting::updateOrCreate(
                ['key' => $setting['key']],
                $setting
            );
        }
    }
}
