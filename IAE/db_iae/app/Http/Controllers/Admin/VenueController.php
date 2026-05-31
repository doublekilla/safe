<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Venue;
use App\Models\VenueField;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Inertia\Inertia;

class VenueController extends Controller
{
    public function index(Request $request)
    {
        $query = Venue::withCount('fields');

        if ($request->filled('search')) {
            $query->search($request->search);
        }

        if ($request->filled('sport_type')) {
            $query->bySport($request->sport_type);
        }

        if ($request->filled('status')) {
            $query->where('status', $request->status);
        }

        $venues = $query->latest()->paginate(10)->withQueryString();

        return Inertia::render('Admin/Venues/Index', [
            'venues' => $venues,
            'filters' => $request->only(['search', 'sport_type', 'status']),
        ]);
    }

    public function create()
    {
        return Inertia::render('Admin/Venues/Create');
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'sport_type' => 'required|in:badminton,futsal,basketball,padel,volleyball',
            'description' => 'nullable|string',
            'location' => 'required|string|max:255',
            'price_per_hour' => 'required|numeric|min:0',
            'facilities' => 'nullable|array',
            'operating_hours' => 'nullable|array',
            'status' => 'required|in:active,inactive,maintenance',
            'photos' => 'nullable|array',
            'photos.*' => 'image|max:2048',
        ]);

        $photos = [];
        if ($request->hasFile('photos')) {
            foreach ($request->file('photos') as $photo) {
                $photos[] = $photo->store('venues', 'public');
            }
        }

        $validated['photos'] = $photos;

        Venue::create($validated);

        return redirect()->route('admin.venues.index')
            ->with('success', 'Lapangan berhasil ditambahkan.');
    }

    public function edit(Venue $venue)
    {
        $venue->load('fields');

        return Inertia::render('Admin/Venues/Edit', [
            'venue' => $venue,
        ]);
    }

    public function update(Request $request, Venue $venue)
    {
        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'sport_type' => 'required|in:badminton,futsal,basketball,padel,volleyball',
            'description' => 'nullable|string',
            'location' => 'required|string|max:255',
            'price_per_hour' => 'required|numeric|min:0',
            'facilities' => 'nullable|array',
            'operating_hours' => 'nullable|array',
            'status' => 'required|in:active,inactive,maintenance',
            'new_photos' => 'nullable|array',
            'new_photos.*' => 'image|max:2048',
            'existing_photos' => 'nullable|array',
        ]);

        $photos = $request->get('existing_photos', []);

        if ($request->hasFile('new_photos')) {
            foreach ($request->file('new_photos') as $photo) {
                $photos[] = $photo->store('venues', 'public');
            }
        }

        // Delete removed photos
        $oldPhotos = $venue->photos ?? [];
        $removedPhotos = array_diff($oldPhotos, $photos);
        foreach ($removedPhotos as $removedPhoto) {
            Storage::disk('public')->delete($removedPhoto);
        }

        $validated['photos'] = $photos;
        unset($validated['new_photos'], $validated['existing_photos']);

        $venue->update($validated);

        return redirect()->route('admin.venues.index')
            ->with('success', 'Lapangan berhasil diperbarui.');
    }

    public function destroy(Venue $venue)
    {
        // Delete associated photos
        if ($venue->photos) {
            foreach ($venue->photos as $photo) {
                Storage::disk('public')->delete($photo);
            }
        }

        $venue->delete();

        return redirect()->route('admin.venues.index')
            ->with('success', 'Lapangan berhasil dihapus.');
    }

    // Venue Fields Management
    public function fields(Venue $venue)
    {
        $venue->load('fields');

        return Inertia::render('Admin/Venues/Fields', [
            'venue' => $venue,
        ]);
    }

    public function storeField(Request $request, Venue $venue)
    {
        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'status' => 'required|in:active,inactive,maintenance',
            'photo' => 'nullable|image|max:2048',
        ]);

        if ($request->hasFile('photo')) {
            $validated['photo'] = $request->file('photo')->store('venue-fields', 'public');
        }

        $venue->fields()->create($validated);

        return back()->with('success', 'Lapangan berhasil ditambahkan.');
    }

    public function updateField(Request $request, VenueField $field)
    {
        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'status' => 'required|in:active,inactive,maintenance',
            'photo' => 'nullable|image|max:2048',
        ]);

        if ($request->hasFile('photo')) {
            if ($field->photo) {
                Storage::disk('public')->delete($field->photo);
            }
            $validated['photo'] = $request->file('photo')->store('venue-fields', 'public');
        }

        $field->update($validated);

        return back()->with('success', 'Lapangan berhasil diperbarui.');
    }

    public function destroyField(VenueField $field)
    {
        if ($field->photo) {
            Storage::disk('public')->delete($field->photo);
        }

        $field->delete();

        return back()->with('success', 'Lapangan berhasil dihapus.');
    }
}
