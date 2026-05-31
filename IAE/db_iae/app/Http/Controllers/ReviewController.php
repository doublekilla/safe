<?php

namespace App\Http\Controllers;

use App\Models\Review;
use App\Models\Booking;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Inertia\Inertia;

class ReviewController extends Controller
{
    public function store(Request $request)
    {
        $request->validate([
            'booking_id' => 'required|exists:bookings,id',
            'venue_id' => 'required|exists:venues,id',
            'rating' => 'required|integer|min:1|max:5',
            'comment' => 'nullable|string|max:1000',
        ]);

        $booking = Booking::findOrFail($request->booking_id);

        if ($booking->user_id !== Auth::id()) {
            abort(403);
        }

        if ($booking->status !== 'completed') {
            return back()->withErrors(['booking' => 'Booking harus selesai sebelum memberikan ulasan.']);
        }

        // Check if already reviewed
        $existing = Review::where('user_id', Auth::id())
            ->where('booking_id', $request->booking_id)
            ->exists();

        if ($existing) {
            return back()->withErrors(['review' => 'Anda sudah memberikan ulasan untuk booking ini.']);
        }

        Review::create([
            'user_id' => Auth::id(),
            'venue_id' => $request->venue_id,
            'booking_id' => $request->booking_id,
            'rating' => $request->rating,
            'comment' => $request->comment,
            'is_visible' => true,
        ]);

        return back()->with('success', 'Ulasan berhasil dikirim. Terima kasih!');
    }

    public function venueReviews(Request $request, $venueId)
    {
        $reviews = Review::where('venue_id', $venueId)
            ->visible()
            ->with('user:id,name,avatar')
            ->latest()
            ->paginate(10);

        return response()->json($reviews);
    }
}
