<?php

namespace App\Exports\Sheets;

use App\Models\Booking;
use App\Models\Payment;
use Carbon\Carbon;
use Illuminate\Support\Facades\DB;
use Maatwebsite\Excel\Concerns\FromArray;
use Maatwebsite\Excel\Concerns\WithTitle;
use Maatwebsite\Excel\Concerns\WithStyles;
use Maatwebsite\Excel\Concerns\WithColumnWidths;
use PhpOffice\PhpSpreadsheet\Worksheet\Worksheet;
use PhpOffice\PhpSpreadsheet\Style\Alignment;
use PhpOffice\PhpSpreadsheet\Style\Border;
use PhpOffice\PhpSpreadsheet\Style\Fill;
use PhpOffice\PhpSpreadsheet\Style\NumberFormat;

class SummarySheet implements FromArray, WithTitle, WithStyles, WithColumnWidths
{
    protected string $startDate;
    protected string $endDate;
    protected $endOfDay;

    public function __construct(string $startDate, string $endDate, $endOfDay)
    {
        $this->startDate = $startDate;
        $this->endDate = $endDate;
        $this->endOfDay = $endOfDay;
    }

    public function title(): string
    {
        return 'Ringkasan';
    }

    public function columnWidths(): array
    {
        return ['A' => 30, 'B' => 25, 'C' => 20];
    }

    public function array(): array
    {
        $totalRevenue = Payment::paid()->whereBetween('paid_at', [$this->startDate, $this->endOfDay])->sum('amount');
        $totalTransactions = Payment::paid()->whereBetween('paid_at', [$this->startDate, $this->endOfDay])->count();
        $avgTransaction = $totalTransactions > 0 ? $totalRevenue / $totalTransactions : 0;

        $totalBookings = Booking::whereBetween('created_at', [$this->startDate, $this->endOfDay])->count();
        $completedBookings = Booking::whereBetween('created_at', [$this->startDate, $this->endOfDay])->where('status', 'completed')->count();
        $cancelledBookings = Booking::whereBetween('created_at', [$this->startDate, $this->endOfDay])->where('status', 'cancelled')->count();
        $confirmedBookings = Booking::whereBetween('created_at', [$this->startDate, $this->endOfDay])->where('status', 'confirmed')->count();
        $pendingBookings = Booking::whereBetween('created_at', [$this->startDate, $this->endOfDay])->where('status', 'pending')->count();

        $statusLabels = [
            'completed' => 'Selesai',
            'cancelled' => 'Dibatalkan',
            'confirmed' => 'Dikonfirmasi',
            'pending' => 'Menunggu',
        ];

        $rows = [];
        $rows[] = ['LAPORAN KEUANGAN EITHSPACE'];
        $rows[] = [''];
        $rows[] = ['Periode', Carbon::parse($this->startDate)->format('d/m/Y') . ' - ' . Carbon::parse($this->endDate)->format('d/m/Y')];
        $rows[] = ['Tanggal Cetak', now()->format('d/m/Y H:i')];
        $rows[] = [''];
        $rows[] = ['RINGKASAN KEUANGAN', '', ''];
        $rows[] = ['Total Pendapatan', 'Rp ' . number_format($totalRevenue, 0, ',', '.')];
        $rows[] = ['Jumlah Transaksi', $totalTransactions];
        $rows[] = ['Rata-rata per Transaksi', 'Rp ' . number_format($avgTransaction, 0, ',', '.')];
        $rows[] = [''];
        $rows[] = ['STATISTIK BOOKING', '', ''];
        $rows[] = ['Total Booking', $totalBookings];
        $rows[] = ['Selesai', $completedBookings];
        $rows[] = ['Dikonfirmasi', $confirmedBookings];
        $rows[] = ['Menunggu', $pendingBookings];
        $rows[] = ['Dibatalkan', $cancelledBookings];
        $rows[] = [''];
        $rows[] = ['TINGKAT KEBERHASILAN', '', ''];
        $rows[] = ['Completion Rate', $totalBookings > 0 ? round(($completedBookings / $totalBookings) * 100, 1) . '%' : '0%'];
        $rows[] = ['Cancellation Rate', $totalBookings > 0 ? round(($cancelledBookings / $totalBookings) * 100, 1) . '%' : '0%'];

        return $rows;
    }

    public function styles(Worksheet $sheet)
    {
        // Title row
        $sheet->mergeCells('A1:C1');
        $sheet->getStyle('A1')->applyFromArray([
            'font' => ['bold' => true, 'size' => 16, 'color' => ['rgb' => 'FFFFFF']],
            'fill' => ['fillType' => Fill::FILL_SOLID, 'startColor' => ['rgb' => '1a3a5c']],
            'alignment' => ['horizontal' => Alignment::HORIZONTAL_CENTER, 'vertical' => Alignment::VERTICAL_CENTER],
        ]);
        $sheet->getRowDimension(1)->setRowHeight(40);

        // Section headers
        foreach ([6, 11, 18] as $row) {
            $sheet->mergeCells("A{$row}:C{$row}");
            $sheet->getStyle("A{$row}")->applyFromArray([
                'font' => ['bold' => true, 'size' => 11, 'color' => ['rgb' => 'FFFFFF']],
                'fill' => ['fillType' => Fill::FILL_SOLID, 'startColor' => ['rgb' => 'c9a84c']],
            ]);
            $sheet->getRowDimension($row)->setRowHeight(25);
        }

        // Data rows styling
        foreach ([3, 4, 7, 8, 9, 12, 13, 14, 15, 16, 19, 20] as $row) {
            $sheet->getStyle("A{$row}")->getFont()->setBold(true)->setSize(10);
            $sheet->getStyle("B{$row}")->getFont()->setSize(10);
            $sheet->getStyle("A{$row}:C{$row}")->applyFromArray([
                'borders' => ['bottom' => ['borderStyle' => Border::BORDER_THIN, 'color' => ['rgb' => 'E5E7EB']]],
            ]);
        }

        return [];
    }
}
