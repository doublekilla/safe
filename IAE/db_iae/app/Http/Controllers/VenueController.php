<?php

namespace App\Http\Controllers;

use App\Models\Venue;
use App\Models\Review;
use Illuminate\Http\Request;
use Inertia\Inertia;

class VenueController extends Controller
{
    public function index(Request $request)
    {
        $query = Venue::active()->withCount(['reviews' => function ($q) {
            $q->where('is_visible', true);
        }]);

        // Search
        if ($request->filled('search')) {
            $query->search($request->search);
        }

        // Filter by sport type
        if ($request->filled('sport_type')) {
            $query->bySport($request->sport_type);
        }

        // Filter by price range
        if ($request->filled('min_price') && $request->filled('max_price')) {
            $query->priceBetween($request->min_price, $request->max_price);
        }

        // Sort
        $sortBy = $request->get('sort', 'name');
        $sortDir = $request->get('direction', 'asc');
        $query->orderBy($sortBy, $sortDir);

        $venues = $query->paginate(12)->withQueryString();

        // Append average rating
        $venues->getCollection()->transform(function ($venue) {
            $venue->average_rating = $venue->reviews()->where('is_visible', true)->avg('rating') ?? 0;
            $venue->review_count = $venue->reviews_count;
            return $venue;
        });

        // Get price range for filter
        $priceRange = [
            'min' => Venue::active()->min('price_per_hour') ?? 0,
            'max' => Venue::active()->max('price_per_hour') ?? 500000,
        ];

        return Inertia::render('Venues/Index', [
            'venues' => $venues,
            'filters' => $request->only(['search', 'sport_type', 'min_price', 'max_price', 'sort', 'direction']),
            'priceRange' => $priceRange,
        ]);
    }

    public function show(Venue $venue)
    {
        $venue->load(['fields' => function ($q) {
            $q->where('status', 'active');
        }]);

        $reviews = $venue->reviews()
            ->visible()
            ->with('user:id,name,avatar')
            ->latest()
            ->paginate(10);

        $averageRating = $venue->reviews()->visible()->avg('rating') ?? 0;
        $reviewCount = $venue->reviews()->visible()->count();
        $ratingDistribution = [];
        for ($i = 5; $i >= 1; $i--) {
            $ratingDistribution[$i] = $venue->reviews()->visible()->where('rating', $i)->count();
        }

        return Inertia::render('Venues/Show', [
            'venue' => $venue,
            'reviews' => $reviews,
            'averageRating' => round($averageRating, 1),
            'reviewCount' => $reviewCount,
            'ratingDistribution' => $ratingDistribution,
        ]);
    }
}
