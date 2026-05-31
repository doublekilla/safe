<?php

namespace App\Http\Controllers\Api\SpaceLink;

use App\Http\Controllers\Controller;
use App\Models\SpaceLink\SlFeedPost;
use App\Models\SpaceLink\SlFeedLike;
use Illuminate\Http\Request;

class FeedController extends Controller
{
    public function index(Request $request)
    {
        $query = SlFeedPost::with(['user.slProfile', 'community', 'likes'])
            ->withCount('likes')
            ->latest();

        if ($request->has('community_id')) {
            $query->where('community_id', $request->community_id);
        }

        $posts = $query->paginate(20);

        return response()->json([
            'success' => true,
            'data' => $posts
        ]);
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'text' => 'required|string',
            'community_id' => 'nullable|exists:sl_communities,id',
            'tag' => 'nullable|string',
            'image' => 'nullable|image|max:5120',
        ]);

        if ($request->hasFile('image')) {
            $path = $request->file('image')->store('feed', 'public');
            $validated['image'] = '/storage/' . $path;
        }

        if ($request->community_id) {
            $community = \App\Models\SpaceLink\SlCommunity::find($request->community_id);
            if ($community && $community->admin_user_id !== $request->user()->id) {
                $member = $community->members()->where('user_id', $request->user()->id)->first();
                if (!$member || $member->pivot->role !== 'admin') {
                    return response()->json(['success' => false, 'message' => 'Hanya admin yang dapat membuat postingan feed.'], 403);
                }
            }
        }

        $validated['user_id'] = $request->user()->id;

        $post = SlFeedPost::create($validated);

        return response()->json([
            'success' => true,
            'message' => 'Post created successfully',
            'data' => $post->load(['user.slProfile', 'community'])
        ], 201);
    }

    public function toggleLike(Request $request, $id)
    {
        $post = SlFeedPost::findOrFail($id);
        $userId = $request->user()->id;

        $like = SlFeedLike::where('feed_post_id', $post->id)
            ->where('user_id', $userId)
            ->first();

        if ($like) {
            $like->delete();
            $isLiked = false;
        } else {
            SlFeedLike::create([
                'feed_post_id' => $post->id,
                'user_id' => $userId
            ]);
            $isLiked = true;
        }

        return response()->json([
            'success' => true,
            'message' => $isLiked ? 'Post liked' : 'Post unliked',
            'data' => [
                'is_liked' => $isLiked,
                'likes_count' => $post->likes()->count()
            ]
        ]);
    }
}