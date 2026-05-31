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

class PaymentMethodSheet implements FromArray, WithTitle, WithStyles, WithColumnWidths
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
        return 'Metode Pembayaran';
    }

    public function columnWidths(): array
    {
        return ['A' => 6, 'B' => 22, 'C' => 18, 'D' => 25, 'E' => 18];
    }

    public function array(): array
    {
        $data = Payment::paid()
            ->whereBetween('paid_at', [$this->startDate, $this->endOfDay])
            ->select('method', DB::raw('COUNT(*) as count'), DB::raw('SUM(amount) as total'))
            ->groupBy('method')
            ->orderByDesc('total')
            ->get();

        $methodLabels = [
            'credit_card' => 'Kartu Kredit', 'bank_transfer' => 'Transfer Bank',
            'echannel' => 'Mandiri Bill', 'bca_va' => 'BCA VA', 'bni_va' => 'BNI VA',
            'bri_va' => 'BRI VA', 'permata_va' => 'Permata VA', 'gopay' => 'GoPay',
            'shopeepay' => 'ShopeePay', 'qris' => 'QRIS', 'cstore' => 'Minimarket',
            'akulaku' => 'Akulaku',
        ];

        $rows = [];
        $rows[] = ['No', 'Metode Pembayaran', 'Jumlah Transaksi', 'Total Pendapatan (Rp)', 'Persentase'];

        $grandTotal = $data->sum('total');

        foreach ($data as $i => $item) {
            $pct = $grandTotal > 0 ? round(($item->total / $grandTotal) * 100, 1) : 0;
            $rows[] = [
                $i + 1,
                $methodLabels[$item->method] ?? ucfirst(str_replace('_', ' ', $item->method)),
                (int) $item->count,
                (float) $item->total,
                $pct . '%',
            ];
        }

        $rows[] = [''];
        $rows[] = ['', 'TOTAL', $data->sum('count'), $grandTotal, '100%'];

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
