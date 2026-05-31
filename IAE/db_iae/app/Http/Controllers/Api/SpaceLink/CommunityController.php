<?php

namespace App\Http\Controllers\Api\SpaceLink;

use App\Http\Controllers\Controller;
use App\Models\SpaceLink\SlCommunity;
use App\Models\SpaceLink\SlCommunityMember;
use Illuminate\Http\Request;

class CommunityController extends Controller
{
    public function index(Request $request)
    {
        $query = SlCommunity::query();

        if ($request->has('sport_category')) {
            $query->where('sport_category', $request->sport_category);
        }

        if ($request->has('search')) {
            $query->where('name', 'like', '%' . $request->search . '%');
        }

        $communities = $query->withCount('members')->latest()->get();
        
        $userId = $request->user() ? $request->user()->id : null;
        if ($userId) {
            $memberCommunityIds = SlCommunityMember::where('user_id', $userId)->pluck('community_id')->toArray();
            $communities->map(function ($community) use ($memberCommunityIds) {
                $community->is_joined = in_array($community->id, $memberCommunityIds);
                return $community;
            });
        }

        return response()->json([
            'success' => true,
            'data' => $communities
        ]);
    }

    public function mine(Request $request)
    {
        $communities = $request->user()->slCommunities()->withCount('members')->latest()->get();
        $communities->map(function ($community) {
            $community->is_joined = true;
            return $community;
        });

        return response()->json([
            'success' => true,
            'data' => $communities
        ]);
    }

    public function show(Request $request, $id)
    {
        $community = SlCommunity::with(['admin.slProfile', 'members.slProfile', 'activities'])->withCount('members')->findOrFail($id);
        
        $userId = $request->user() ? $request->user()->id : null;
        if ($userId) {
            $community->is_joined = $community->members->contains('id', $userId);
        } else {
            $community->is_joined = false;
        }

        return response()->json([
            'success' => true,
            'data' => $community
        ]);
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'sport_category' => 'required|string',
            'description' => 'nullable|string',
            'location' => 'nullable|string',
            'rules' => 'nullable|string',
            'privacy' => 'nullable|in:public,private',
            'image' => 'nullable|string',
        ]);

        $validated['admin_user_id'] = $request->user()->id;

        $community = SlCommunity::create($validated);

        SlCommunityMember::create([
            'community_id' => $community->id,
            'user_id' => $request->user()->id,
            'role' => 'admin',
            'joined_at' => now(),
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Community created successfully',
            'data' => $community
        ], 201);
    }

    public function update(Request $request, $id)
    {
        $community = SlCommunity::findOrFail($id);
        
        if ($community->admin_user_id !== $request->user()->id) {
            return response()->json(['success' => false, 'message' => 'Unauthorized'], 403);
        }

        $validated = $request->validate([
            'name' => 'nullable|string|max:255',
            'sport_category' => 'nullable|string',
            'description' => 'nullable|string',
            'location' => 'nullable|string',
            'rules' => 'nullable|string',
            'privacy' => 'nullable|in:public,private',
            'image' => 'nullable|image|max:5120',
        ]);

        if ($request->hasFile('image')) {
            $path = $request->file('image')->store('communities', 'public');
            $validated['image'] = '/storage/' . $path;
        }

        $community->update($validated);

        return response()->json([
            'success' => true,
            'message' => 'Community updated successfully',
            'data' => $community
        ]);
    }

    public function destroy(Request $request, $id)
    {
        $community = SlCommunity::findOrFail($id);

        if ($community->admin_user_id !== $request->user()->id) {
            return response()->json(['success' => false, 'message' => 'Unauthorized'], 403);
        }

        $community->delete();

        return response()->json([
            'success' => true,
            'message' => 'Community deleted successfully'
        ]);
    }

    public function join(Request $request, $id)
    {
        $community = SlCommunity::findOrFail($id);

        $role = $community->privacy === 'private' ? 'pending' : 'member';

        $member = SlCommunityMember::firstOrCreate([
            'community_id' => $community->id,
            'user_id' => $request->user()->id,
        ], [
            'role' => $role,
            'joined_at' => now(),
        ]);

        return response()->json([
            'success' => true,
            'message' => $role === 'pending' ? 'Join request sent' : 'Joined community successfully',
            'data' => $member
        ]);
    }

    public function leave(Request $request, $id)
    {
        SlCommunityMember::where('community_id', $id)
            ->where('user_id', $request->user()->id)
            ->delete();

        return response()->json([
            'success' => true,
            'message' => 'Left community successfully'
        ]);
    }

    public function pendingRequests(Request $request, $id)
    {
        $community = SlCommunity::findOrFail($id);

        if ($community->admin_user_id !== $request->user()->id) {
            return response()->json(['success' => false, 'message' => 'Unauthorized'], 403);
        }

        $requests = SlCommunityMember::where('community_id', $id)
            ->where('role', 'pending')
            ->with('user.slProfile')
            ->get();

        return response()->json([
            'success' => true,
            'data' => $requests
        ]);
    }

    public function approveRequest(Request $request, $id)
    {
        $request->validate(['user_id' => 'required|integer']);

        $community = SlCommunity::findOrFail($id);
        if ($community->admin_user_id !== $request->user()->id) {
            return response()->json(['success' => false, 'message' => 'Unauthorized'], 403);
        }

        SlCommunityMember::where('community_id', $id)
            ->where('user_id', $request->user_id)
            ->update(['role' => 'member', 'joined_at' => now()]);

        return response()->json([
            'success' => true,
            'message' => 'Request approved'
        ]);
    }

    public function denyRequest(Request $request, $id)
    {
        $request->validate(['user_id' => 'required|integer']);

        $community = SlCommunity::findOrFail($id);
        if ($community->admin_user_id !== $request->user()->id) {
            return response()->json(['success' => false, 'message' => 'Unauthorized'], 403);
        }

        SlCommunityMember::where('community_id', $id)
            ->where('user_id', $request->user_id)
            ->where('role', 'pending')
            ->delete();

        return response()->json([
            'success' => true,
            'message' => 'Request denied'
        ]);
    }

    public function removeMember(Request $request, $id)
    {
        $request->validate(['user_id' => 'required|integer']);

        $community = SlCommunity::findOrFail($id);
        if ($community->admin_user_id !== $request->user()->id) {
            return response()->json(['success' => false, 'message' => 'Unauthorized'], 403);
        }

        if ($request->user_id === $community->admin_user_id) {
            return response()->json(['success' => false, 'message' => 'Cannot remove the club owner'], 400);
        }

        SlCommunityMember::where('community_id', $id)
            ->where('user_id', $request->user_id)
            ->delete();

        return response()->json([
            'success' => true,
            'message' => 'Member removed'
        ]);
    }

    public function assignAdmin(Request $request, $id)
    {
        $request->validate([
            'user_id' => 'required|integer',
            'is_admin' => 'required|boolean'
        ]);

        $community = SlCommunity::findOrFail($id);
        if ($community->admin_user_id !== $request->user()->id) {
            return response()->json(['success' => false, 'message' => 'Unauthorized'], 403);
        }

        if ($request->user_id === $community->admin_user_id) {
            return response()->json(['success' => false, 'message' => 'Cannot change role of the club owner'], 400);
        }

        SlCommunityMember::where('community_id', $id)
            ->where('user_id', $request->user_id)
            ->update(['role' => $request->is_admin ? 'admin' : 'member']);

        return response()->json([
            'success' => true,
            'message' => 'Admin role updated'
        ]);
    }
}