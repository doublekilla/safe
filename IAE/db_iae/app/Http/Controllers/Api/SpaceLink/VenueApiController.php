<?php

namespace App\Http\Controllers\Api\SpaceLink;

use App\Http\Controllers\Controller;
use App\Models\Venue;
use Illuminate\Http\Request;

class VenueApiController extends Controller
{
    public function index(Request $request)
    {
        $query = Venue::query();

        if ($request->has('sport_type')) {
            $query->where('sport_types', 'like', '%' . $request->sport_type . '%');
        }

        if ($request->has('search')) {
            $query->where('name', 'like', '%' . $request->search . '%')
                  ->orWhere('city', 'like', '%' . $request->search . '%');
        }

        $venues = $query->where('status', 'active')->latest()->get();

        return response()->json([
            'success' => true,
            'data' => $venues
        ]);
    }

    public function show($id)
    {
        $venue = Venue::with(['fields', 'faqs'])->findOrFail($id);

        return response()->json([
            'success' => true,
            'data' => $venue
        ]);
    }
}