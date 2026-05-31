<?php

namespace Database\Seeders;

use App\Models\Venue;
use App\Models\VenueField;
use Illuminate\Database\Seeder;

class VenueSeeder extends Seeder
{
    public function run(): void
    {
        $venues = [
            // ===== BADMINTON =====
            [
                'name' => 'Lapangan Badminton EithSpace',
                'sport_type' => 'badminton',
                'description' => 'Lapangan badminton premium dengan lantai vinyl berkualitas tinggi, pencahayaan LED standar turnamen, dan sistem ventilasi modern. Cocok untuk latihan rutin maupun pertandingan.',
                'location' => 'EithSpace Sports Center, Jakarta Selatan',
                'price_per_hour' => 75000,
                'facilities' => ['Parkir Luas', 'Ruang Ganti', 'Toilet Bersih', 'Kantin', 'WiFi Gratis', 'Peminjaman Raket', 'Shuttlecock tersedia'],
                'photos' => [],
                'operating_hours' => [
                    'monday' => ['08:00', '22:00'], 'tuesday' => ['08:00', '22:00'],
                    'wednesday' => ['08:00', '22:00'], 'thursday' => ['08:00', '22:00'],
                    'friday' => ['08:00', '22:00'], 'saturday' => ['07:00', '23:00'],
                    'sunday' => ['07:00', '23:00'],
                ],
                'status' => 'active',
                'fields' => [
                    ['name' => 'Badminton Court A', 'status' => 'active'],
                    ['name' => 'Badminton Court B', 'status' => 'active'],
                    ['name' => 'Badminton Court C', 'status' => 'active'],
                    ['name' => 'Badminton Court D', 'status' => 'active'],
                ],
            ],
            [
                'name' => 'Surya Badminton Hall',
                'sport_type' => 'badminton',
                'description' => 'Pusat pelatihan badminton profesional dengan 6 lapangan standar BWF. Dilengkapi tribun penonton, kamera analisis teknik, dan pelatih bersertifikat.',
                'location' => 'Jl. Gatot Subroto No. 88, Jakarta Pusat',
                'price_per_hour' => 90000,
                'facilities' => ['Parkir Luas', 'Tribun Penonton', 'Ruang Ganti & Shower', 'Pro Shop', 'WiFi Gratis', 'Sewa Raket', 'Kamera Analisis'],
                'photos' => [],
                'operating_hours' => [
                    'monday' => ['06:00', '22:00'], 'tuesday' => ['06:00', '22:00'],
                    'wednesday' => ['06:00', '22:00'], 'thursday' => ['06:00', '22:00'],
                    'friday' => ['06:00', '22:00'], 'saturday' => ['06:00', '23:00'],
                    'sunday' => ['06:00', '23:00'],
                ],
                'status' => 'active',
                'fields' => [
                    ['name' => 'Court 1 (Premium)', 'status' => 'active'],
                    ['name' => 'Court 2 (Premium)', 'status' => 'active'],
                    ['name' => 'Court 3 (Standar)', 'status' => 'active'],
                ],
            ],

            // ===== FUTSAL =====
            [
                'name' => 'Lapangan Futsal EithSpace',
                'sport_type' => 'futsal',
                'description' => 'Lapangan futsal berstandar nasional dengan rumput sintetis FIFA Quality. Dilengkapi scoring board digital, ruang pemain, dan area pemanasan. Pengalaman bermain futsal terbaik di Jakarta.',
                'location' => 'EithSpace Sports Center, Jakarta Selatan',
                'price_per_hour' => 200000,
                'facilities' => ['Parkir Luas', 'Ruang Ganti', 'Toilet & Shower', 'Kantin', 'WiFi Gratis', 'Sewa Sepatu Futsal', 'Sewa Rompi', 'Bola Futsal Tersedia'],
                'photos' => [],
                'operating_hours' => [
                    'monday' => ['08:00', '23:00'], 'tuesday' => ['08:00', '23:00'],
                    'wednesday' => ['08:00', '23:00'], 'thursday' => ['08:00', '23:00'],
                    'friday' => ['08:00', '23:00'], 'saturday' => ['07:00', '24:00'],
                    'sunday' => ['07:00', '24:00'],
                ],
                'status' => 'active',
                'fields' => [
                    ['name' => 'Futsal Field 1 (Vinyl)', 'status' => 'active'],
                    ['name' => 'Futsal Field 2 (Rumput Sintetis)', 'status' => 'active'],
                    ['name' => 'Futsal Field 3 (Rumput Sintetis)', 'status' => 'active'],
                ],
            ],

            // ===== BASKETBALL =====
            [
                'name' => 'Garuda Basketball Arena',
                'sport_type' => 'basketball',
                'description' => 'Arena basket indoor berstandar FIBA dengan lantai kayu maple premium, ring adjustable, dan scoring board digital. Lapangan digunakan untuk liga profesional dan komunitas.',
                'location' => 'Jl. Asia Afrika No. 12, Bandung',
                'price_per_hour' => 250000,
                'facilities' => ['Parkir Motor & Mobil', 'Ruang Ganti & Locker', 'Shower', 'Tribun 200 Kursi', 'WiFi Gratis', 'Sewa Bola', 'Scoring Board Digital', 'Sound System'],
                'photos' => [],
                'operating_hours' => [
                    'monday' => ['07:00', '22:00'], 'tuesday' => ['07:00', '22:00'],
                    'wednesday' => ['07:00', '22:00'], 'thursday' => ['07:00', '22:00'],
                    'friday' => ['07:00', '23:00'], 'saturday' => ['06:00', '23:00'],
                    'sunday' => ['06:00', '22:00'],
                ],
                'status' => 'active',
                'fields' => [
                    ['name' => 'Full Court A', 'status' => 'active'],
                    ['name' => 'Full Court B', 'status' => 'active'],
                    ['name' => 'Half Court (Latihan)', 'status' => 'active'],
                ],
            ],
            [
                'name' => 'Downtown Basketball Center',
                'sport_type' => 'basketball',
                'description' => 'Lapangan basket outdoor premium dengan lantai acrylic anti-slip, pencahayaan floodlight, dan area pemanasan. Suasana street basketball yang autentik.',
                'location' => 'Jl. Sudirman No. 45, Jakarta Pusat',
                'price_per_hour' => 180000,
                'facilities' => ['Parkir Luas', 'Toilet', 'Sewa Bola', 'Lampu Floodlight', 'Bench Area', 'Water Dispenser'],
                'photos' => [],
                'operating_hours' => [
                    'monday' => ['06:00', '22:00'], 'tuesday' => ['06:00', '22:00'],
                    'wednesday' => ['06:00', '22:00'], 'thursday' => ['06:00', '22:00'],
                    'friday' => ['06:00', '23:00'], 'saturday' => ['06:00', '23:00'],
                    'sunday' => ['06:00', '22:00'],
                ],
                'status' => 'active',
                'fields' => [
                    ['name' => 'Court Utama', 'status' => 'active'],
                    ['name' => 'Court Samping', 'status' => 'active'],
                ],
            ],

            // ===== PADEL =====
            [
                'name' => 'Padel Club Jakarta',
                'sport_type' => 'padel',
                'description' => 'Padel court berstandar internasional dengan dinding kaca tempered, rumput sintetis premium, dan pencahayaan LED. Olahraga padel terbaru yang sedang naik daun di Indonesia.',
                'location' => 'PIK Avenue, Jakarta Utara',
                'price_per_hour' => 300000,
                'facilities' => ['Parkir Basement', 'Ruang Ganti & Shower', 'Lounge Area', 'Café & Bar', 'WiFi Gratis', 'Sewa Raket Padel', 'Bola Padel Tersedia', 'Coaching Available'],
                'photos' => [],
                'operating_hours' => [
                    'monday' => ['07:00', '22:00'], 'tuesday' => ['07:00', '22:00'],
                    'wednesday' => ['07:00', '22:00'], 'thursday' => ['07:00', '22:00'],
                    'friday' => ['07:00', '23:00'], 'saturday' => ['06:00', '23:00'],
                    'sunday' => ['06:00', '22:00'],
                ],
                'status' => 'active',
                'fields' => [
                    ['name' => 'Padel Court 1 (Indoor)', 'status' => 'active'],
                    ['name' => 'Padel Court 2 (Indoor)', 'status' => 'active'],
                    ['name' => 'Padel Court 3 (Outdoor)', 'status' => 'active'],
                ],
            ],
            [
                'name' => 'Bali Padel Paradise',
                'sport_type' => 'padel',
                'description' => 'Padel court premium dengan pemandangan tropis Bali. Lapangan outdoor berkualitas tinggi dengan dinding kaca dan rumput sintetis Mondo.',
                'location' => 'Jl. Bypass Ngurah Rai No. 99, Bali',
                'price_per_hour' => 350000,
                'facilities' => ['Parkir Luas', 'Ruang Ganti', 'Infinity Pool', 'Beach Club', 'Sewa Raket', 'Pro Coaching', 'Café'],
                'photos' => [],
                'operating_hours' => [
                    'monday' => ['06:00', '21:00'], 'tuesday' => ['06:00', '21:00'],
                    'wednesday' => ['06:00', '21:00'], 'thursday' => ['06:00', '21:00'],
                    'friday' => ['06:00', '22:00'], 'saturday' => ['06:00', '22:00'],
                    'sunday' => ['06:00', '21:00'],
                ],
                'status' => 'active',
                'fields' => [
                    ['name' => 'Padel Court Sunset', 'status' => 'active'],
                    ['name' => 'Padel Court Ocean', 'status' => 'active'],
                ],
            ],

            // ===== VOLLEYBALL =====
            [
                'name' => 'Pantai Indah Voli Center',
                'sport_type' => 'volleyball',
                'description' => 'Pusat olahraga voli indoor dan outdoor dengan lapangan berstandar PBVSI. Lantai taraflex premium, net adjustable, dan tribun penonton. Cocok untuk latihan tim dan turnamen.',
                'location' => 'Jl. Mangga Dua Raya No. 22, Jakarta Utara',
                'price_per_hour' => 150000,
                'facilities' => ['Parkir Motor & Mobil', 'Ruang Ganti & Shower', 'Tribun 150 Kursi', 'Kantin', 'WiFi Gratis', 'Sewa Bola Voli', 'Net Standar PBVSI', 'Scoring Board'],
                'photos' => [],
                'operating_hours' => [
                    'monday' => ['07:00', '22:00'], 'tuesday' => ['07:00', '22:00'],
                    'wednesday' => ['07:00', '22:00'], 'thursday' => ['07:00', '22:00'],
                    'friday' => ['07:00', '22:00'], 'saturday' => ['06:00', '23:00'],
                    'sunday' => ['06:00', '22:00'],
                ],
                'status' => 'active',
                'fields' => [
                    ['name' => 'Voli Court A (Indoor)', 'status' => 'active'],
                    ['name' => 'Voli Court B (Indoor)', 'status' => 'active'],
                    ['name' => 'Voli Court C (Outdoor)', 'status' => 'active'],
                ],
            ],
            [
                'name' => 'Surabaya Volley Arena',
                'sport_type' => 'volleyball',
                'description' => 'Arena voli terbesar di Jawa Timur dengan 4 lapangan indoor full-size. Digunakan untuk Proliga dan event nasional. Fasilitas lengkap untuk atlet profesional dan komunitas.',
                'location' => 'Jl. Raya Darmo No. 50, Surabaya',
                'price_per_hour' => 175000,
                'facilities' => ['Parkir Luas', 'Ruang Ganti & Locker', 'Shower', 'Tribun 500 Kursi', 'Gym Area', 'Fisioterapi', 'Sewa Bola', 'Café'],
                'photos' => [],
                'operating_hours' => [
                    'monday' => ['06:00', '22:00'], 'tuesday' => ['06:00', '22:00'],
                    'wednesday' => ['06:00', '22:00'], 'thursday' => ['06:00', '22:00'],
                    'friday' => ['06:00', '23:00'], 'saturday' => ['06:00', '23:00'],
                    'sunday' => ['06:00', '22:00'],
                ],
                'status' => 'active',
                'fields' => [
                    ['name' => 'Main Court (Proliga)', 'status' => 'active'],
                    ['name' => 'Court 2 (Latihan)', 'status' => 'active'],
                ],
            ],
        ];

        foreach ($venues as $venueData) {
            $fields = $venueData['fields'];
            unset($venueData['fields']);

            $venue = Venue::updateOrCreate(
                ['name' => $venueData['name']],
                $venueData
            );

            foreach ($fields as $field) {
                VenueField::updateOrCreate(
                    ['venue_id' => $venue->id, 'name' => $field['name']],
                    $field
                );
            }
        }
    }
}
