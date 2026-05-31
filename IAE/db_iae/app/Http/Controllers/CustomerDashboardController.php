<?php

namespace App\Http\Controllers;

use App\Models\Booking;
use App\Models\Cart;
use Illuminate\Support\Facades\Auth;
use Inertia\Inertia;

class CustomerDashboardController extends Controller
{
    public function index()
    {
        $user = Auth::user();

        $activeBookings = Booking::where('user_id', $user->id)
            ->whereIn('status', ['pending', 'confirmed'])
            ->with(['items.venueField.venue', 'payment'])
            ->latest()
            ->take(5)
            ->get();

        $recentBookings = Booking::where('user_id', $user->id)
            ->with(['items.venueField.venue', 'payment'])
            ->latest()
            ->take(5)
            ->get();

        $stats = [
            'total_bookings' => Booking::where('user_id', $user->id)->count(),
            'active_bookings' => Booking::where('user_id', $user->id)
                ->whereIn('status', ['pending', 'confirmed'])->count(),
            'completed_bookings' => Booking::where('user_id', $user->id)
                ->where('status', 'completed')->count(),
            'cart_items' => Cart::where('user_id', $user->id)->first()?->items()->count() ?? 0,
        ];

        return Inertia::render('Customer/Dashboard', [
            'activeBookings' => $activeBookings,
            'recentBookings' => $recentBookings,
            'stats' => $stats,
        ]);
    }
}
