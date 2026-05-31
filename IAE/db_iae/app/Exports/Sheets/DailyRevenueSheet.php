<?php

namespace App\Exports\Sheets;

use App\Models\Payment;
use Illuminate\Support\Facades\DB;
use Maatwebsite\Excel\Concerns\FromArray;
use Maatwebsite\Excel\Concerns\WithTitle;
use Maatwebsite\Excel\Concerns\WithStyles;
use Maatwebsite\Excel\Concerns\WithColumnWidths;
use PhpOffice\PhpSpreadsheet\Worksheet\Worksheet;
use PhpOffice\PhpSpreadsheet\Style\Alignment;
use PhpOffice\PhpSpreadsheet\Style\Border;
use PhpOffice\PhpSpreadsheet\Style\Fill;

class DailyRevenueSheet implements FromArray, WithTitle, WithStyles, WithColumnWidths
{
    protected string $startDate;
    protected $endOfDay;

    public function __construct(string $startDate, $endOfDay)
    {
        $this->startDate = $startDate;
        $this->endOfDay = $endOfDay;
    }

    public function title(): string
    {
        return 'Pendapatan Harian';
    }

    public function columnWidths(): array
    {
        return ['A' => 8, 'B' => 20, 'C' => 15, 'D' => 25, 'E' => 25];
    }

    public function array(): array
    {
        $dailyRevenue = Payment::paid()
            ->whereBetween('paid_at', [$this->startDate, $this->endOfDay])
            ->select(
                DB::raw('DATE(paid_at) as date'),
                DB::raw('SUM(amount) as total'),
                DB::raw('COUNT(*) as count')
            )
            ->groupBy(DB::raw('DATE(paid_at)'))
            ->orderBy('date')
            ->get();

        $rows = [];
        $rows[] = ['No', 'Tanggal', 'Jumlah Transaksi', 'Total Pendapatan', 'Rata-rata per Transaksi'];

        $grandTotal = 0;
        $grandCount = 0;

        foreach ($dailyRevenue as $i => $day) {
            $avg = $day->count > 0 ? $day->total / $day->count : 0;
            $rows[] = [
                $i + 1,
                \Carbon\Carbon::parse($day->date)->format('d/m/Y'),
                (int) $day->count,
                (float) $day->total,
                round($avg),
            ];
            $grandTotal += $day->total;
            $grandCount += $day->count;
        }

        $rows[] = [''];
        $rows[] = ['', 'TOTAL', $grandCount, $grandTotal, $grandCount > 0 ? round($grandTotal / $grandCount) : 0];

        return $rows;
    }

    public function styles(Worksheet $sheet)
    {
        $lastRow = $sheet->getHighestRow();

        // Header row
        $sheet->getStyle('A1:E1')->applyFromArray([
            'font' => ['bold' => true, 'color' => ['rgb' => 'FFFFFF'], 'size' => 10],
            'fill' => ['fillType' => Fill::FILL_SOLID, 'startColor' => ['rgb' => '1a3a5c']],
            'alignment' => ['horizontal' => Alignment::HORIZONTAL_CENTER],
            'borders' => ['allBorders' => ['borderStyle' => Border::BORDER_THIN]],
        ]);
        $sheet->getRowDimension(1)->setRowHeight(28);

        // Data rows
        for ($i = 2; $i <= $lastRow; $i++) {
            $sheet->getStyle("A{$i}:E{$i}")->applyFromArray([
                'borders' => ['allBorders' => ['borderStyle' => Border::BORDER_THIN, 'color' => ['rgb' => 'E5E7EB']]],
                'alignment' => ['horizontal' => Alignment::HORIZONTAL_CENTER],
            ]);

            // Alternating row colors
            if ($i % 2 === 0 && $i < $lastRow) {
                $sheet->getStyle("A{$i}:E{$i}")->applyFromArray([
                    'fill' => ['fillType' => Fill::FILL_SOLID, 'startColor' => ['rgb' => 'F9FAFB']],
                ]);
            }
        }

        // Total row
        $sheet->getStyle("A{$lastRow}:E{$lastRow}")->applyFromArray([
            'font' => ['bold' => true, 'size' => 10, 'color' => ['rgb' => 'FFFFFF']],
            'fill' => ['fillType' => Fill::FILL_SOLID, 'startColor' => ['rgb' => 'c9a84c']],
            'borders' => ['allBorders' => ['borderStyle' => Border::BORDER_THIN]],
        ]);

        // Currency format for columns D and E
        $sheet->getStyle("D2:D{$lastRow}")->getNumberFormat()->setFormatCode('#,##0');
        $sheet->getStyle("E2:E{$lastRow}")->getNumberFormat()->setFormatCode('#,##0');

        return [];
    }
}
