<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Booking;
use App\Models\Payment;
use App\Models\Venue;
use App\Models\Schedule;
use Illuminate\Support\Facades\DB;
use Inertia\Inertia;

class DashboardController extends Controller
{
    public function index()
    {
        // Auto-complete bookings whose slots have ended
        Booking::autoCompleteAll();

        $today = now()->toDateString();

        // Key metrics
        $stats = [
            'bookings_today' => Booking::today()->count(),
            'active_bookings' => Booking::whereIn('status', ['pending', 'confirmed'])->count(),
            'revenue_today' => Payment::paid()->whereDate('paid_at', $today)->sum('amount'),
            'revenue_week' => Payment::paid()->whereBetween('paid_at', [now()->startOfWeek(), now()->endOfWeek()])->sum('amount'),
            'revenue_month' => Payment::paid()->whereMonth('paid_at', now()->month)->whereYear('paid_at', now()->year)->sum('amount'),
            'pending_payments' => Payment::pending()->count(),
            'total_venues' => Venue::count(),
            'available_slots' => Schedule::available()->where('date', '>=', $today)->count(),
        ];

        // Most popular venue fields
        $popularFields = DB::table('booking_items')
            ->join('venue_fields', 'booking_items.venue_field_id', '=', 'venue_fields.id')
            ->join('venues', 'venue_fields.venue_id', '=', 'venues.id')
            ->select(
                'venues.name as venue_name',
                'venue_fields.name as field_name',
                'venues.sport_type',
                DB::raw('COUNT(*) as booking_count')
            )
            ->groupBy('venue_fields.id', 'venues.name', 'venue_fields.name', 'venues.sport_type')
            ->orderByDesc('booking_count')
            ->limit(5)
            ->get();

        // Recent bookings
        $recentBookings = Booking::with(['user:id,name,email', 'items.venueField.venue', 'payment'])
            ->latest()
            ->take(10)
            ->get();

        // Revenue data for chart (last 7 days)
        $revenueChart = [];
        for ($i = 6; $i >= 0; $i--) {
            $date = now()->subDays($i);
            $revenueChart[] = [
                'date' => $date->format('Y-m-d'),
                'revenue' => Payment::paid()->whereDate('paid_at', $date->toDateString())->sum('amount'),
                'bookings' => Booking::whereDate('created_at', $date->toDateString())->count(),
            ];
        }

        // Booking by sport type
        $bookingBySport = DB::table('booking_items')
            ->join('venue_fields', 'booking_items.venue_field_id', '=', 'venue_fields.id')
            ->join('venues', 'venue_fields.venue_id', '=', 'venues.id')
            ->select('venues.sport_type', DB::raw('COUNT(*) as count'))
            ->groupBy('venues.sport_type')
            ->get();

        return Inertia::render('Admin/Dashboard', [
            'stats' => $stats,
            'popularFields' => $popularFields,
            'recentBookings' => $recentBookings,
            'revenueChart' => $revenueChart,
            'bookingBySport' => $bookingBySport,
        ]);
    }
}
