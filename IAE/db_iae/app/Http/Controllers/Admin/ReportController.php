<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Booking;
use App\Models\Payment;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Inertia\Inertia;
use Carbon\Carbon;

class ReportController extends Controller
{
    public function index(Request $request)
    {
        $startDate = $request->get('start_date', now()->startOfMonth()->toDateString());
        $endDate = $request->get('end_date', now()->toDateString());

        // Revenue summary
        $revenueSummary = [
            'total' => Payment::paid()
                ->whereBetween('paid_at', [$startDate, Carbon::parse($endDate)->endOfDay()])
                ->sum('amount'),
            'count' => Payment::paid()
                ->whereBetween('paid_at', [$startDate, Carbon::parse($endDate)->endOfDay()])
                ->count(),
        ];

        // Daily revenue
        $dailyRevenue = Payment::paid()
            ->whereBetween('paid_at', [$startDate, Carbon::parse($endDate)->endOfDay()])
            ->select(
                DB::raw('DATE(paid_at) as date'),
                DB::raw('SUM(amount) as total'),
                DB::raw('COUNT(*) as count')
            )
            ->groupBy(DB::raw('DATE(paid_at)'))
            ->orderBy('date')
            ->get();

        // Booking stats
        $bookingStats = Booking::whereBetween('created_at', [$startDate, Carbon::parse($endDate)->endOfDay()])
            ->select('status', DB::raw('COUNT(*) as count'))
            ->groupBy('status')
            ->get();

        // Revenue by sport type
        $revenueBySport = DB::table('payments')
            ->join('bookings', 'payments.booking_id', '=', 'bookings.id')
            ->join('booking_items', 'bookings.id', '=', 'booking_items.booking_id')
            ->join('venue_fields', 'booking_items.venue_field_id', '=', 'venue_fields.id')
            ->join('venues', 'venue_fields.venue_id', '=', 'venues.id')
            ->where('payments.status', 'paid')
            ->whereBetween('payments.paid_at', [$startDate, Carbon::parse($endDate)->endOfDay()])
            ->select('venues.sport_type', DB::raw('SUM(booking_items.price) as total'))
            ->groupBy('venues.sport_type')
            ->get();

        // Payment method breakdown
        $paymentMethods = Payment::paid()
            ->whereBetween('paid_at', [$startDate, Carbon::parse($endDate)->endOfDay()])
            ->select('method', DB::raw('COUNT(*) as count'), DB::raw('SUM(amount) as total'))
            ->groupBy('method')
            ->get();

        return Inertia::render('Admin/Reports/Index', [
            'revenueSummary' => $revenueSummary,
            'dailyRevenue' => $dailyRevenue,
            'bookingStats' => $bookingStats,
            'revenueBySport' => $revenueBySport,
            'paymentMethods' => $paymentMethods,
            'filters' => [
                'start_date' => $startDate,
                'end_date' => $endDate,
            ],
        ]);
    }

    public function downloadPdf(Request $request)
    {
        $startDate = $request->get('start_date', now()->startOfMonth()->toDateString());
        $endDate = $request->get('end_date', now()->toDateString());
        $endOfDay = Carbon::parse($endDate)->endOfDay();

        // Revenue summary
        $revenueSummary = [
            'total' => Payment::paid()->whereBetween('paid_at', [$startDate, $endOfDay])->sum('amount'),
            'count' => Payment::paid()->whereBetween('paid_at', [$startDate, $endOfDay])->count(),
            'average' => Payment::paid()->whereBetween('paid_at', [$startDate, $endOfDay])->avg('amount'),
        ];

        // Daily revenue
        $dailyRevenue = Payment::paid()
            ->whereBetween('paid_at', [$startDate, $endOfDay])
            ->select(
                DB::raw('DATE(paid_at) as date'),
                DB::raw('SUM(amount) as total'),
                DB::raw('COUNT(*) as count')
            )
            ->groupBy(DB::raw('DATE(paid_at)'))
            ->orderBy('date')
            ->get();

        // Booking stats
        $bookingStats = Booking::whereBetween('created_at', [$startDate, $endOfDay])
            ->select('status', DB::raw('COUNT(*) as count'))
            ->groupBy('status')
            ->get();

        // Revenue by sport
        $revenueBySport = DB::table('payments')
            ->join('bookings', 'payments.booking_id', '=', 'bookings.id')
            ->join('booking_items', 'bookings.id', '=', 'booking_items.booking_id')
            ->join('venue_fields', 'booking_items.venue_field_id', '=', 'venue_fields.id')
            ->join('venues', 'venue_fields.venue_id', '=', 'venues.id')
            ->where('payments.status', 'paid')
            ->whereBetween('payments.paid_at', [$startDate, $endOfDay])
            ->select('venues.sport_type', DB::raw('SUM(booking_items.price) as total'), DB::raw('COUNT(DISTINCT bookings.id) as booking_count'))
            ->groupBy('venues.sport_type')
            ->get();

        // Payment methods
        $paymentMethods = Payment::paid()
            ->whereBetween('paid_at', [$startDate, $endOfDay])
            ->select('method', DB::raw('COUNT(*) as count'), DB::raw('SUM(amount) as total'))
            ->groupBy('method')
            ->get();

        // Detailed transactions
        $transactions = Payment::paid()
            ->whereBetween('paid_at', [$startDate, $endOfDay])
            ->with(['booking.user:id,name,email,phone', 'booking.items.venueField.venue:id,name,sport_type'])
            ->orderBy('paid_at', 'desc')
            ->get();

        // Top venues
        $topVenues = DB::table('booking_items')
            ->join('bookings', 'booking_items.booking_id', '=', 'bookings.id')
            ->join('payments', 'bookings.id', '=', 'payments.booking_id')
            ->join('venue_fields', 'booking_items.venue_field_id', '=', 'venue_fields.id')
            ->join('venues', 'venue_fields.venue_id', '=', 'venues.id')
            ->where('payments.status', 'paid')
            ->whereBetween('payments.paid_at', [$startDate, $endOfDay])
            ->select(
                'venues.name as venue_name',
                'venue_fields.name as field_name',
                'venues.sport_type',
                DB::raw('COUNT(*) as booking_count'),
                DB::raw('SUM(booking_items.price) as total_revenue')
            )
            ->groupBy('venues.name', 'venue_fields.name', 'venues.sport_type')
            ->orderByDesc('total_revenue')
            ->limit(10)
            ->get();

        $pdf = \Barryvdh\DomPDF\Facade\Pdf::loadView('reports.financial-pdf', [
            'revenueSummary' => $revenueSummary,
            'dailyRevenue' => $dailyRevenue,
            'bookingStats' => $bookingStats,
            'revenueBySport' => $revenueBySport,
            'paymentMethods' => $paymentMethods,
            'transactions' => $transactions,
            'topVenues' => $topVenues,
            'startDate' => $startDate,
            'endDate' => $endDate,
            'generatedAt' => now()->format('d/m/Y H:i'),
        ]);

        $pdf->setPaper('a4', 'portrait');

        return $pdf->download("laporan-keuangan-eithspace-{$startDate}-{$endDate}.pdf");
    }

    public function downloadExcel(Request $request)
    {
        $startDate = $request->get('start_date', now()->startOfMonth()->toDateString());
        $endDate = $request->get('end_date', now()->toDateString());

        return \Maatwebsite\Excel\Facades\Excel::download(
            new \App\Exports\FinancialReportExport($startDate, $endDate),
            "laporan-keuangan-eithspace-{$startDate}-{$endDate}.xls",
            \Maatwebsite\Excel\Excel::XLS
        );
    }
}
