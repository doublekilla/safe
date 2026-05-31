<?php

namespace App\Http\Controllers\Api\SpaceLink;

use App\Http\Controllers\Controller;
use App\Models\SpaceLink\SlFriendship;
use App\Models\User;
use Illuminate\Http\Request;

class FriendController extends Controller
{
    public function index(Request $request)
    {
        $userId = $request->user()->id;

        $friendships = SlFriendship::where(function ($q) use ($userId) {
            $q->where('user_id', $userId)
              ->orWhere('friend_id', $userId);
        })
        ->where('status', 'accepted')
        ->with(['user.slProfile', 'friend.slProfile'])
        ->get();

        $friends = $friendships->map(function ($friendship) use ($userId) {
            $user = $friendship->user_id == $userId ? $friendship->friend : $friendship->user;
            $profile = $user->slProfile;

            // Get mutual clubs
            $userClubIds = \App\Models\SpaceLink\SlCommunityMember::where('user_id', $user->id)->pluck('community_id');
            $myClubIds = \App\Models\SpaceLink\SlCommunityMember::where('user_id', $userId)->pluck('community_id');
            $mutualClubIds = $userClubIds->intersect($myClubIds);
            $mutualClubs = \App\Models\SpaceLink\SlCommunity::whereIn('id', $mutualClubIds)->withCount('members')->get(['id', 'name', 'image'])->map(function($c) {
                return [
                    'id' => $c->id,
                    'name' => $c->name,
                    'image' => $c->image ? (str_starts_with($c->image, 'http') ? $c->image : url($c->image)) : null,
                    'member_count' => $c->members_count
                ];
            });

            return [
                'id' => $user->id,
                'name' => $user->name,
                'email' => $user->email,
                'profile_image' => $profile?->profile_image ?? $user->avatar,
                'location' => $profile?->location,
                'sports' => $profile?->favorite_sports ?? [],
                'skill_level' => $profile?->skill_level,
                'availability' => $profile?->availability ?? [],
                'friend_status' => 'accepted',
                'gender' => $profile?->gender,
                'mutual_clubs' => $mutualClubs,
                'activity_count' => $this->getActivityCount($user->id),
            ];
        });

        return response()->json([
            'success' => true,
            'data' => $friends
        ]);
    }

    public function requests(Request $request)
    {
        $userId = $request->user()->id;

        $friendships = SlFriendship::where('friend_id', $userId)
            ->where('status', 'pending')
            ->with(['user.slProfile'])
            ->get();

        $requests = $friendships->map(function ($friendship) use ($userId) {
            $user = $friendship->user;
            $profile = $user->slProfile;
            // Get mutual clubs
            $userClubIds = \App\Models\SpaceLink\SlCommunityMember::where('user_id', $user->id)->pluck('community_id');
            $myClubIds = \App\Models\SpaceLink\SlCommunityMember::where('user_id', $userId)->pluck('community_id');
            $mutualClubIds = $userClubIds->intersect($myClubIds);
            $mutualClubs = \App\Models\SpaceLink\SlCommunity::whereIn('id', $mutualClubIds)->withCount('members')->get(['id', 'name', 'image'])->map(function($c) {
                return [
                    'id' => $c->id,
                    'name' => $c->name,
                    'image' => $c->image ? (str_starts_with($c->image, 'http') ? $c->image : url($c->image)) : null,
                    'member_count' => $c->members_count
                ];
            });

            return [
                'id' => $user->id,
                'name' => $user->name,
                'email' => $user->email,
                'profile_image' => $profile?->profile_image ?? $user->avatar,
                'location' => $profile?->location,
                'sports' => $profile?->favorite_sports ?? [],
                'skill_level' => $profile?->skill_level,
                'availability' => $profile?->availability ?? [],
                'friend_status' => 'pending_received',
                'gender' => $profile?->gender,
                'mutual_clubs' => $mutualClubs,
                'activity_count' => $this->getActivityCount($user->id),
            ];
        });

        return response()->json([
            'success' => true,
            'data' => $requests
        ]);
    }

    public function search(Request $request)
    {
        $userId = $request->user()->id;
        $q = $request->get('query') ?? $request->get('q');

        $usersQuery = User::where('id', '!=', $userId)
            ->where('role', 'customer')
            ->with('slProfile');

        if ($q) {
            $usersQuery->where('name', 'like', "%{$q}%");
        }

        if ($request->has('sport') && $request->sport !== 'all') {
            $sport = $request->sport;
            $usersQuery->whereHas('slProfile', function ($pq) use ($sport) {
                $pq->whereJsonContains('favorite_sports', $sport);
            });
        }

        $users = $usersQuery->take(50)->get();

        // Attach friendship status
        $friendships = SlFriendship::where(function ($fq) use ($userId) {
            $fq->where('user_id', $userId)->orWhere('friend_id', $userId);
        })->get();

        $result = $users->map(function ($user) use ($userId, $friendships) {
            $friendship = $friendships->first(function ($f) use ($userId, $user) {
                return ($f->user_id == $userId && $f->friend_id == $user->id)
                    || ($f->friend_id == $userId && $f->user_id == $user->id);
            });

            $profile = $user->slProfile;

            // Get mutual clubs
            $userClubIds = \App\Models\SpaceLink\SlCommunityMember::where('user_id', $user->id)->pluck('community_id');
            $myClubIds = \App\Models\SpaceLink\SlCommunityMember::where('user_id', $userId)->pluck('community_id');
            $mutualClubIds = $userClubIds->intersect($myClubIds);
            $mutualClubs = \App\Models\SpaceLink\SlCommunity::whereIn('id', $mutualClubIds)->withCount('members')->get(['id', 'name', 'image'])->map(function($c) {
                return [
                    'id' => $c->id,
                    'name' => $c->name,
                    'image' => $c->image ? (str_starts_with($c->image, 'http') ? $c->image : url($c->image)) : null,
                    'member_count' => $c->members_count
                ];
            });

            return [
                'id' => $user->id,
                'name' => $user->name,
                'email' => $user->email,
                'profile_image' => $profile?->profile_image ?? $user->avatar,
                'location' => $profile?->location,
                'sports' => $profile?->favorite_sports ?? [],
                'skill_level' => $profile?->skill_level,
                'availability' => $profile?->availability ?? [],
                'friend_status' => $friendship?->status ?? 'none',
                'gender' => $profile?->gender,
                'mutual_clubs' => $mutualClubs,
                'activity_count' => $this->getActivityCount($user->id),
            ];
        });

        return response()->json([
            'success' => true,
            'data' => $result
        ]);
    }

    public function add(Request $request, $friendId)
    {
        if ($request->user()->id == $friendId) {
            return response()->json(['success' => false, 'message' => 'Cannot add yourself'], 400);
        }

        $friendship = SlFriendship::firstOrCreate([
            'user_id' => $request->user()->id,
            'friend_id' => $friendId,
        ], [
            'status' => 'pending'
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Friend request sent',
            'data' => $friendship
        ]);
    }

    public function accept(Request $request, $friendId)
    {
        $friendship = SlFriendship::where('user_id', $friendId)
            ->where('friend_id', $request->user()->id)
            ->firstOrFail();

        $friendship->update(['status' => 'accepted']);

        return response()->json([
            'success' => true,
            'message' => 'Friend request accepted'
        ]);
    }

    public function remove(Request $request, $friendId)
    {
        $userId = $request->user()->id;

        SlFriendship::where(function ($q) use ($userId, $friendId) {
            $q->where('user_id', $userId)->where('friend_id', $friendId);
        })->orWhere(function ($q) use ($userId, $friendId) {
            $q->where('user_id', $friendId)->where('friend_id', $userId);
        })->delete();

        return response()->json([
            'success' => true,
            'message' => 'Friend removed'
        ]);
    }

    private function getActivityCount($userId)
    {
        return \App\Models\SpaceLink\SlActivity::where(function($q) use ($userId) {
                $q->where('host_user_id', $userId)
                  ->orWhereHas('participants', function($pq) use ($userId) {
                      $pq->where('user_id', $userId)->where('status', 'confirmed');
                  });
            })
            ->where(function($q) {
                $q->where('date', '<', now()->toDateString())
                  ->orWhere(function($q2) {
                      $q2->where('date', '=', now()->toDateString())
                         ->where('time', '<', now()->toTimeString());
                  });
            })
            ->count();
    }
}