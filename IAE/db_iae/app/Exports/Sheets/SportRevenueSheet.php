<?php

namespace App\Exports\Sheets;

use Illuminate\Support\Facades\DB;
use Maatwebsite\Excel\Concerns\FromArray;
use Maatwebsite\Excel\Concerns\WithTitle;
use Maatwebsite\Excel\Concerns\WithStyles;
use Maatwebsite\Excel\Concerns\WithColumnWidths;
use PhpOffice\PhpSpreadsheet\Worksheet\Worksheet;
use PhpOffice\PhpSpreadsheet\Style\Alignment;
use PhpOffice\PhpSpreadsheet\Style\Border;
use PhpOffice\PhpSpreadsheet\Style\Fill;

class SportRevenueSheet implements FromArray, WithTitle, WithStyles, WithColumnWidths
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
        return 'Per Olahraga';
    }

    public function columnWidths(): array
    {
        return ['A' => 6, 'B' => 20, 'C' => 18, 'D' => 25, 'E' => 18];
    }

    public function array(): array
    {
        $data = DB::table('payments')
            ->join('bookings', 'payments.booking_id', '=', 'bookings.id')
            ->join('booking_items', 'bookings.id', '=', 'booking_items.booking_id')
            ->join('venue_fields', 'booking_items.venue_field_id', '=', 'venue_fields.id')
            ->join('venues', 'venue_fields.venue_id', '=', 'venues.id')
            ->where('payments.status', 'paid')
            ->whereBetween('payments.paid_at', [$this->startDate, $this->endOfDay])
            ->select(
                'venues.sport_type',
                DB::raw('COUNT(DISTINCT bookings.id) as booking_count'),
                DB::raw('SUM(booking_items.price) as total'),
            )
            ->groupBy('venues.sport_type')
            ->orderByDesc('total')
            ->get();

        $sportLabels = [
            'badminton' => 'Badminton', 'futsal' => 'Futsal', 'basketball' => 'Basket',
            'padel' => 'Padel', 'volleyball' => 'Voli',
        ];

        $rows = [];
        $rows[] = ['No', 'Olahraga', 'Jumlah Booking', 'Total Pendapatan (Rp)', 'Persentase'];

        $grandTotal = $data->sum('total');

        foreach ($data as $i => $item) {
            $pct = $grandTotal > 0 ? round(($item->total / $grandTotal) * 100, 1) : 0;
            $rows[] = [
                $i + 1,
                $sportLabels[$item->sport_type] ?? ucfirst($item->sport_type),
                (int) $item->booking_count,
                (float) $item->total,
                $pct . '%',
            ];
        }

        $rows[] = [''];
        $rows[] = ['', 'TOTAL', $data->sum('booking_count'), $grandTotal, '100%'];

        return $rows;
    }

    public function styles(Worksheet $sheet)
    {
        $lastRow = $sheet->getHighestRow();

        $sheet->getStyle('A1:E1')->applyFromArray([
            'font' => ['bold' => true, 'color' => ['rgb' => 'FFFFFF'], 'size' => 10],
            'fill' => ['fillType' => Fill::FILL_SOLID, 'startColor' => ['rgb' => '1a3a5c']],
            'alignment' => ['horizontal' => Alignment::HORIZONTAL_CENTER],
            'borders' => ['allBorders' => ['borderStyle' => Border::BORDER_THIN]],
        ]);
        $sheet->getRowDimension(1)->setRowHeight(28);

        for ($i = 2; $i <= $lastRow; $i++) {
            $sheet->getStyle("A{$i}:E{$i}")->applyFromArray([
                'borders' => ['allBorders' => ['borderStyle' => Border::BORDER_THIN, 'color' => ['rgb' => 'E5E7EB']]],
                'alignment' => ['horizontal' => Alignment::HORIZONTAL_CENTER],
            ]);
            if ($i % 2 === 0 && $i < $lastRow - 1) {
                $sheet->getStyle("A{$i}:E{$i}")->applyFromArray([
                    'fill' => ['fillType' => Fill::FILL_SOLID, 'startColor' => ['rgb' => 'F9FAFB']],
                ]);
            }
        }

        $sheet->getStyle("A{$lastRow}:E{$lastRow}")->applyFromArray([
            'font' => ['bold' => true, 'size' => 10, 'color' => ['rgb' => 'FFFFFF']],
            'fill' => ['fillType' => Fill::FILL_SOLID, 'startColor' => ['rgb' => 'c9a84c']],
        ]);

        $sheet->getStyle("D2:D{$lastRow}")->getNumberFormat()->setFormatCode('#,##0');

        return [];
    }
}
