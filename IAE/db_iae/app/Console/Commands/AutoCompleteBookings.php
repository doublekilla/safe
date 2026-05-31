<?php

namespace App\Console\Commands;

use App\Models\Booking;
use Illuminate\Console\Command;

class AutoCompleteBookings extends Command
{
    protected $signature = 'booking:auto-complete';

    protected $description = 'Otomatis ubah status booking menjadi completed ketika semua jadwal sudah selesai';

    public function handle(): int
    {
        $completedCount = Booking::autoCompleteAll();

        $this->info("Auto-completed {$completedCount} booking(s).");

        return self::SUCCESS;
    }
}
