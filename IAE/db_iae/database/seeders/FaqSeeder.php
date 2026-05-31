<?php

namespace Database\Seeders;

use App\Models\Faq;
use Illuminate\Database\Seeder;

class FaqSeeder extends Seeder
{
    public function run(): void
    {
        $faqs = [
            ['category' => 'Booking', 'question' => 'Bagaimana cara melakukan booking lapangan?', 'answer' => 'Pilih lapangan yang tersedia, pilih tanggal dan jam yang diinginkan, tambahkan ke keranjang, lalu lakukan pembayaran. Anda akan menerima konfirmasi booking setelah pembayaran berhasil.', 'order' => 1],
            ['category' => 'Booking', 'question' => 'Berapa lama sebelumnya saya harus booking?', 'answer' => 'Anda dapat melakukan booking mulai dari 14 hari sebelumnya hingga hari H, selama slot masih tersedia.', 'order' => 2],
            ['category' => 'Booking', 'question' => 'Apakah bisa booking lebih dari satu jam?', 'answer' => 'Ya, Anda bisa memilih beberapa slot jam sekaligus dan semuanya akan masuk ke keranjang booking Anda.', 'order' => 3],
            ['category' => 'Pembayaran', 'question' => 'Metode pembayaran apa saja yang tersedia?', 'answer' => 'Kami menerima pembayaran melalui transfer bank, e-wallet (OVO, GoPay, Dana), dan QRIS.', 'order' => 4],
            ['category' => 'Pembayaran', 'question' => 'Berapa batas waktu pembayaran?', 'answer' => 'Batas waktu pembayaran adalah 24 jam setelah booking dibuat. Jika melebihi batas waktu, booking akan otomatis dibatalkan.', 'order' => 5],
            ['category' => 'Reschedule', 'question' => 'Apakah bisa reschedule?', 'answer' => 'Ya, Anda dapat mengajukan reschedule untuk booking yang sudah dikonfirmasi, maksimal 2 jam sebelum jadwal bermain.', 'order' => 6],
            ['category' => 'Reschedule', 'question' => 'Bagaimana cara melakukan reschedule?', 'answer' => 'Buka halaman detail booking Anda, klik tombol "Reschedule", pilih jadwal baru yang tersedia, dan konfirmasi perubahan.', 'order' => 7],
            ['category' => 'Pembatalan', 'question' => 'Apakah bisa membatalkan booking?', 'answer' => 'Booking dengan status pending atau confirmed dapat dibatalkan. Hubungi admin untuk bantuan proses refund.', 'order' => 8],
            ['category' => 'Fasilitas', 'question' => 'Fasilitas apa saja yang tersedia?', 'answer' => 'Kami menyediakan parkir luas, ruang ganti, toilet bersih, kantin, WiFi gratis, dan perlengkapan olahraga yang dapat disewa.', 'order' => 9],
            ['category' => 'Fasilitas', 'question' => 'Apakah tersedia penyewaan raket/sepatu?', 'answer' => 'Ya, kami menyediakan penyewaan raket badminton dan sepatu futsal. Silakan hubungi admin atau langsung datang ke counter.', 'order' => 10],
        ];

        foreach ($faqs as $faq) {
            Faq::updateOrCreate(
                ['question' => $faq['question']],
                array_merge($faq, ['is_active' => true])
            );
        }
    }
}
