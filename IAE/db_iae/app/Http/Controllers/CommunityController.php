<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Inertia\Inertia;
use App\Models\SpaceLink\SlCommunity;
use App\Models\SpaceLink\SlFeedPost;
use Illuminate\Support\Facades\Auth;

class CommunityController extends Controller
{
    /**
     * Display the community page.
     */
    public function index(Request $request)
    {
        $communities = SlCommunity::withCount(['memberships', 'feedPosts'])
            ->with(['admin'])
            ->latest()
            ->take(6)
            ->get();

        $recentDiscussions = SlFeedPost::with(['user', 'community', 'likes', 'comments.user'])
            ->withCount(['likes', 'comments'])
            ->latest()
            ->take(10)
            ->get();

        $stats = [
            'active_members' => \App\Models\User::count(),
            'total_communities' => SlCommunity::count(),
            'sport_types' => SlCommunity::distinct('sport_category')->count('sport_category'),
        ];

        $activeCommunities = SlCommunity::withCount(['memberships', 'feedPosts'])
            ->orderBy('feed_posts_count', 'desc')
            ->orderBy('memberships_count', 'desc')
            ->take(5)
            ->get();

        return Inertia::render('Community/Index', [
            'communities' => $communities,
            'activeCommunities' => $activeCommunities,
            'recentDiscussions' => $recentDiscussions,
            'stats' => $stats,
        ]);
    }

    public function browse(Request $request)
    {
        $query = SlCommunity::withCount(['memberships', 'feedPosts'])
            ->with(['admin']);

        if ($request->has('search') && $request->search) {
            $query->where(function($q) use ($request) {
                $q->where('name', 'like', '%' . $request->search . '%')
                  ->orWhere('description', 'like', '%' . $request->search . '%');
            });
        }

        if ($request->has('sport_type') && $request->sport_type) {
            $query->where('sport_category', strtolower($request->sport_type));
        }

        // Apply sorting
        if ($request->has('sort')) {
            $sortField = $request->sort;
            $sortDirection = $request->direction ?? 'asc';
            
            if ($sortField === 'name') {
                $query->orderBy('name', $sortDirection);
            } elseif ($sortField === 'members') {
                $query->orderBy('memberships_count', $sortDirection);
            }
        } else {
            $query->latest();
        }

        $communities = $query->paginate(9)->withQueryString();

        return Inertia::render('Community/Browse', [
            'communities' => $communities,
            'filters' => $request->only(['search', 'sport_type', 'sort', 'direction'])
        ]);
    }

    /**
     * Handle posting to the community forum.
     */
    public function storePost(Request $request)
    {
        // Enforce auth if you want, or just fallback to 1 for demonstration if guest
        $userId = Auth::id() ?? 1;

        $request->validate([
            'content' => 'required|string',
            'community_id' => 'required|exists:sl_communities,id',
        ]);

        SlFeedPost::create([
            'user_id' => $userId,
            'community_id' => $request->community_id,
            'text' => $request->content,
        ]);

        return back();
    }

    /**
     * Display the specified community detail.
     */
    public function show($id)
    {
        $community = SlCommunity::withCount(['memberships', 'feedPosts'])
            ->with(['admin', 'members' => function($q) {
                $q->take(10);
            }])
            ->findOrFail($id);

        $recentDiscussions = SlFeedPost::with(['user', 'community', 'likes', 'comments.user'])
            ->withCount(['likes', 'comments'])
            ->where('community_id', $id)
            ->latest()
            ->take(15)
            ->get();

        return Inertia::render('Community/Show', [
            'community' => $community,
            'recentDiscussions' => $recentDiscussions
        ]);
    }
}
