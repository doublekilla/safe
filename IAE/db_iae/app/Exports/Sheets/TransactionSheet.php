<?php

namespace App\Exports\Sheets;

use App\Models\Payment;
use Carbon\Carbon;
use Maatwebsite\Excel\Concerns\FromArray;
use Maatwebsite\Excel\Concerns\WithTitle;
use Maatwebsite\Excel\Concerns\WithStyles;
use Maatwebsite\Excel\Concerns\WithColumnWidths;
use PhpOffice\PhpSpreadsheet\Worksheet\Worksheet;
use PhpOffice\PhpSpreadsheet\Style\Alignment;
use PhpOffice\PhpSpreadsheet\Style\Border;
use PhpOffice\PhpSpreadsheet\Style\Fill;

class TransactionSheet implements FromArray, WithTitle, WithStyles, WithColumnWidths
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
        return 'Detail Transaksi';
    }

    public function columnWidths(): array
    {
        return ['A' => 6, 'B' => 18, 'C' => 20, 'D' => 22, 'E' => 15, 'F' => 25, 'G' => 18, 'H' => 18, 'I' => 15];
    }

    public function array(): array
    {
        $transactions = Payment::paid()
            ->whereBetween('paid_at', [$this->startDate, $this->endOfDay])
            ->with(['booking.user:id,name,email,phone', 'booking.items.venueField.venue:id,name,sport_type'])
            ->orderBy('paid_at', 'desc')
            ->get();

        $methodLabels = [
            'credit_card' => 'Kartu Kredit',
            'bank_transfer' => 'Transfer Bank',
            'echannel' => 'Mandiri Bill',
            'bca_va' => 'BCA VA',
            'bni_va' => 'BNI VA',
            'bri_va' => 'BRI VA',
            'permata_va' => 'Permata VA',
            'gopay' => 'GoPay',
            'shopeepay' => 'ShopeePay',
            'qris' => 'QRIS',
            'cstore' => 'Minimarket',
            'akulaku' => 'Akulaku',
        ];

        $sportLabels = [
            'badminton' => 'Badminton',
            'futsal' => 'Futsal',
            'basketball' => 'Basket',
            'padel' => 'Padel',
            'volleyball' => 'Voli',
        ];

        $rows = [];
        $rows[] = ['No', 'Kode Booking', 'Customer', 'Email', 'No. Telepon', 'Venue / Lapangan', 'Metode Bayar', 'Tanggal Bayar', 'Jumlah (Rp)'];

        $grandTotal = 0;

        foreach ($transactions as $i => $payment) {
            $booking = $payment->booking;
            $user = $booking?->user;

            $venueNames = $booking?->items->map(function ($item) use ($sportLabels) {
                $venueName = $item->venueField?->venue?->name ?? '-';
                $fieldName = $item->venueField?->name ?? '-';
                $sport = $sportLabels[$item->venueField?->venue?->sport_type ?? ''] ?? '';
                return "{$venueName} - {$fieldName}" . ($sport ? " ({$sport})" : '');
            })->unique()->implode(', ') ?? '-';

            $rows[] = [
                $i + 1,
                $booking?->booking_code ?? '-',
                $user?->name ?? '-',
                $user?->email ?? '-',
                $user?->phone ?? '-',
                $venueNames,
                $methodLabels[$payment->method] ?? ucfirst(str_replace('_', ' ', $payment->method ?? '-')),
                $payment->paid_at ? Carbon::parse($payment->paid_at)->format('d/m/Y H:i') : '-',
                (float) $payment->amount,
            ];

            $grandTotal += $payment->amount;
        }

        $rows[] = [''];
        $rows[] = ['', '', '', '', '', '', '', 'TOTAL', $grandTotal];

        return $rows;
    }

    public function styles(Worksheet $sheet)
    {
        $lastRow = $sheet->getHighestRow();

        // Header row
        $sheet->getStyle('A1:I1')->applyFromArray([
            'font' => ['bold' => true, 'color' => ['rgb' => 'FFFFFF'], 'size' => 10],
            'fill' => ['fillType' => Fill::FILL_SOLID, 'startColor' => ['rgb' => '1a3a5c']],
            'alignment' => ['horizontal' => Alignment::HORIZONTAL_CENTER, 'vertical' => Alignment::VERTICAL_CENTER, 'wrapText' => true],
            'borders' => ['allBorders' => ['borderStyle' => Border::BORDER_THIN]],
        ]);
        $sheet->getRowDimension(1)->setRowHeight(30);
        $sheet->setAutoFilter('A1:I1');

        // Data rows
        for ($i = 2; $i <= $lastRow; $i++) {
            $sheet->getStyle("A{$i}:I{$i}")->applyFromArray([
                'borders' => ['allBorders' => ['borderStyle' => Border::BORDER_THIN, 'color' => ['rgb' => 'E5E7EB']]],
                'font' => ['size' => 9],
            ]);

            if ($i % 2 === 0 && $i < $lastRow - 1) {
                $sheet->getStyle("A{$i}:I{$i}")->applyFromArray([
                    'fill' => ['fillType' => Fill::FILL_SOLID, 'startColor' => ['rgb' => 'F9FAFB']],
                ]);
            }
        }

        // Total row
        $sheet->getStyle("A{$lastRow}:I{$lastRow}")->applyFromArray([
            'font' => ['bold' => true, 'size' => 10, 'color' => ['rgb' => 'FFFFFF']],
            'fill' => ['fillType' => Fill::FILL_SOLID, 'startColor' => ['rgb' => 'c9a84c']],
            'borders' => ['allBorders' => ['borderStyle' => Border::BORDER_THIN]],
        ]);

        // Currency format
        $sheet->getStyle("I2:I{$lastRow}")->getNumberFormat()->setFormatCode('#,##0');

        // Center certain columns
        $sheet->getStyle("A2:A{$lastRow}")->getAlignment()->setHorizontal(Alignment::HORIZONTAL_CENTER);
        $sheet->getStyle("H2:H{$lastRow}")->getAlignment()->setHorizontal(Alignment::HORIZONTAL_CENTER);

        return [];
    }
}
