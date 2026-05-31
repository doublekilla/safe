<?php

namespace App\Exports;

use App\Models\Booking;
use App\Models\Payment;
use Carbon\Carbon;
use Illuminate\Support\Facades\DB;
use Maatwebsite\Excel\Concerns\WithMultipleSheets;

class FinancialReportExport implements WithMultipleSheets
{
    protected string $startDate;
    protected string $endDate;

    public function __construct(string $startDate, string $endDate)
    {
        $this->startDate = $startDate;
        $this->endDate = $endDate;
    }

    public function sheets(): array
    {
        $endOfDay = Carbon::parse($this->endDate)->endOfDay();

        return [
            'Ringkasan' => new Sheets\SummarySheet($this->startDate, $this->endDate, $endOfDay),
            'Pendapatan Harian' => new Sheets\DailyRevenueSheet($this->startDate, $endOfDay),
            'Detail Transaksi' => new Sheets\TransactionSheet($this->startDate, $endOfDay),
            'Per Olahraga' => new Sheets\SportRevenueSheet($this->startDate, $endOfDay),
            'Metode Pembayaran' => new Sheets\PaymentMethodSheet($this->startDate, $endOfDay),
            'Lapangan Populer' => new Sheets\TopVenueSheet($this->startDate, $endOfDay),
        ];
    }
}
