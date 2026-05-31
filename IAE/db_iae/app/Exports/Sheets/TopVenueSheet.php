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

class TopVenueSheet implements FromArray, WithTitle, WithStyles, WithColumnWidths
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
        return 'Lapangan Populer';
    }

    public function columnWidths(): array
    {
        return ['A' => 6, 'B' => 25, 'C' => 22, 'D' => 15, 'E' => 18, 'F' => 25];
    }

    public function array(): array
    {
        $data = DB::table('booking_items')
            ->join('bookings', 'booking_items.booking_id', '=', 'bookings.id')
            ->join('payments', 'bookings.id', '=', 'payments.booking_id')
            ->join('venue_fields', 'booking_items.venue_field_id', '=', 'venue_fields.id')
            ->join('venues', 'venue_fields.venue_id', '=', 'venues.id')
            ->where('payments.status', 'paid')
            ->whereBetween('payments.paid_at', [$this->startDate, $this->endOfDay])
            ->select(
                'venues.name as venue_name',
                'venue_fields.name as field_name',
                'venues.sport_type',
                DB::raw('COUNT(*) as booking_count'),
                DB::raw('SUM(booking_items.price) as total_revenue')
            )
            ->groupBy('venues.name', 'venue_fields.name', 'venues.sport_type')
            ->orderByDesc('total_revenue')
            ->limit(15)
            ->get();

        $sportLabels = [
            'badminton' => 'Badminton', 'futsal' => 'Futsal', 'basketball' => 'Basket',
            'padel' => 'Padel', 'volleyball' => 'Voli',
        ];

        $rows = [];
        $rows[] = ['No', 'Venue', 'Lapangan', 'Olahraga', 'Jumlah Booking', 'Total Pendapatan (Rp)'];

        foreach ($data as $i => $item) {
            $rows[] = [
                $i + 1,
                $item->venue_name,
                $item->field_name,
                $sportLabels[$item->sport_type] ?? ucfirst($item->sport_type),
                (int) $item->booking_count,
                (float) $item->total_revenue,
            ];
        }

        return $rows;
    }

    public function styles(Worksheet $sheet)
    {
        $lastRow = $sheet->getHighestRow();

        $sheet->getStyle('A1:F1')->applyFromArray([
            'font' => ['bold' => true, 'color' => ['rgb' => 'FFFFFF'], 'size' => 10],
            'fill' => ['fillType' => Fill::FILL_SOLID, 'startColor' => ['rgb' => '1a3a5c']],
            'alignment' => ['horizontal' => Alignment::HORIZONTAL_CENTER],
            'borders' => ['allBorders' => ['borderStyle' => Border::BORDER_THIN]],
        ]);
        $sheet->getRowDimension(1)->setRowHeight(28);

        for ($i = 2; $i <= $lastRow; $i++) {
            $sheet->getStyle("A{$i}:F{$i}")->applyFromArray([
                'borders' => ['allBorders' => ['borderStyle' => Border::BORDER_THIN, 'color' => ['rgb' => 'E5E7EB']]],
            ]);
            if ($i % 2 === 0) {
                $sheet->getStyle("A{$i}:F{$i}")->applyFromArray([
                    'fill' => ['fillType' => Fill::FILL_SOLID, 'startColor' => ['rgb' => 'F9FAFB']],
                ]);
            }
        }

        $sheet->getStyle("A2:A{$lastRow}")->getAlignment()->setHorizontal(Alignment::HORIZONTAL_CENTER);
        $sheet->getStyle("E2:E{$lastRow}")->getAlignment()->setHorizontal(Alignment::HORIZONTAL_CENTER);
        $sheet->getStyle("F2:F{$lastRow}")->getNumberFormat()->setFormatCode('#,##0');

        return [];
    }
}
