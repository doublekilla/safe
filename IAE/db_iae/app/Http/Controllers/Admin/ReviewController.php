<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Review;
use Illuminate\Http\Request;
use Inertia\Inertia;

class ReviewController extends Controller
{
    public function index(Request $request)
    {
        $query = Review::with(['user:id,name,email', 'venue:id,name,sport_type', 'booking:id,booking_code'])
            ->latest();

        if ($request->filled('venue_id')) {
            $query->forVenue($request->venue_id);
        }

        if ($request->filled('rating')) {
            $query->where('rating', $request->rating);
        }

        if ($request->has('visible')) {
            $query->where('is_visible', $request->boolean('visible'));
        }

        $reviews = $query->paginate(15)->withQueryString();

        return Inertia::render('Admin/Reviews/Index', [
            'reviews' => $reviews,
            'filters' => $request->only(['venue_id', 'rating', 'visible']),
        ]);
    }

    public function reply(Request $request, Review $review)
    {
        $request->validate([
            'admin_reply' => 'required|string|max:1000',
        ]);

        $review->update(['admin_reply' => $request->admin_reply]);

        return back()->with('success', 'Balasan berhasil dikirim.');
    }

    public function toggleVisibility(Review $review)
    {
        $review->update(['is_visible' => !$review->is_visible]);

        return back()->with('success', 'Visibilitas ulasan berhasil diubah.');
    }
}
