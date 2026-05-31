<?php

namespace App\Http\Controllers\Api\SpaceLink;

use App\Http\Controllers\Controller;
use App\Models\SpaceLink\SlActivity;
use App\Models\SpaceLink\SlActivityParticipant;
use Illuminate\Http\Request;

class ActivityController extends Controller
{
    public function index(Request $request)
    {
        $query = SlActivity::with(['host', 'community', 'participants']);

        if ($request->has('sport_type')) {
            $query->where('sport_type', $request->sport_type);
        }

        if ($request->has('status')) {
            $query->where('status', $request->status);
        }

        $activities = $query->latest('date')->get();

        return response()->json([
            'success' => true,
            'data' => $activities
        ]);
    }

    public function upcoming(Request $request)
    {
        $activities = SlActivity::with(['host', 'community', 'participants'])
            ->where('date', '>=', now()->toDateString())
            ->where('status', 'available')
            ->orderBy('date', 'asc')
            ->orderBy('time', 'asc')
            ->take(10)
            ->get();

        return response()->json([
            'success' => true,
            'data' => $activities
        ]);
    }

    public function myActivities(Request $request)
    {
        $userId = $request->user()->id;

        $activities = SlActivity::with(['host', 'community', 'participants'])
            ->where(function ($query) use ($userId) {
                $query->where('host_user_id', $userId)
                      ->orWhereHas('participants', function ($q) use ($userId) {
                          $q->where('user_id', $userId);
                      });
            })
            ->where(function ($q) {
                $q->where('date', '>', now()->toDateString())
                  ->orWhere(function ($q2) {
                      $q2->where('date', '=', now()->toDateString())
                         ->where('time', '>', now()->toTimeString());
                  });
            })
            ->orderBy('date', 'asc')
            ->orderBy('time', 'asc')
            ->get();

        return response()->json([
            'success' => true,
            'data' => $activities
        ]);
    }

    public function invitations(Request $request)
    {
        $userId = $request->user()->id;

        $activities = SlActivity::with(['host', 'community', 'participants'])
            ->whereHas('participants', function ($q) use ($userId) {
                $q->where('user_id', $userId)->where('status', 'invited');
            })
            ->where(function ($q) {
                $q->where('date', '>', now()->toDateString())
                  ->orWhere(function ($q2) {
                      $q2->where('date', '=', now()->toDateString())
                         ->where('time', '>', now()->toTimeString());
                  });
            })
            ->orderBy('date', 'asc')
            ->orderBy('time', 'asc')
            ->get();

        return response()->json([
            'success' => true,
            'data' => $activities
        ]);
    }

    public function show($id)
    {
        $activity = SlActivity::with(['host', 'community', 'participants.user'])->findOrFail($id);

        return response()->json([
            'success' => true,
            'data' => $activity
        ]);
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'title' => 'required|string|max:255',
            'sport_type' => 'required|string',
            'activity_type' => 'nullable|string|in:fun_match,sparring',
            'location' => 'nullable|string',
            'date' => 'required|date',
            'time' => 'required|string',
            'quota' => 'required|integer|min:2',
            'cost' => 'nullable|numeric',
            'skill_level' => 'nullable|string',
            'community_id' => 'nullable|exists:sl_communities,id',
            'venue_id' => 'nullable|exists:venues,id',
            'notes' => 'nullable|string',
        ]);

        $validated['host_user_id'] = $request->user()->id;
        $validated['current_participants'] = 1;

        $activity = SlActivity::create($validated);

        SlActivityParticipant::create([
            'activity_id' => $activity->id,
            'user_id' => $request->user()->id,
            'status' => 'confirmed',
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Activity created successfully',
            'data' => $activity
        ], 201);
    }

    public function join(Request $request, $id)
    {
        $activity = SlActivity::findOrFail($id);
        $userId = $request->user()->id;

        $isFull = $activity->current_participants >= $activity->quota;
        $status = $isFull ? 'waiting' : 'confirmed';

        $participant = SlActivityParticipant::where('activity_id', $activity->id)
            ->where('user_id', $userId)
            ->first();

        if ($participant) {
            if ($participant->status === 'invited') {
                $participant->update(['status' => $status]);
                
                if ($status === 'confirmed') {
                    $activity->increment('current_participants');
                    if ($activity->current_participants >= $activity->quota) {
                        $activity->update(['status' => 'full']);
                    }
                }
                
                return response()->json([
                    'success' => true,
                    'message' => $status === 'waiting' ? 'Added to waiting list' : 'Joined activity successfully',
                    'data' => $activity->fresh(['participants.user'])
                ]);
            }

            return response()->json([
                'success' => false,
                'message' => 'Already joined this activity'
            ], 400);
        }

        SlActivityParticipant::create([
            'activity_id' => $activity->id,
            'user_id' => $userId,
            'status' => $status,
        ]);

        if ($status === 'confirmed') {
            $activity->increment('current_participants');
            if ($activity->current_participants >= $activity->quota) {
                $activity->update(['status' => 'full']);
            }
        }

        return response()->json([
            'success' => true,
            'message' => $status === 'waiting' ? 'Added to waiting list' : 'Joined activity successfully',
            'data' => $activity->fresh(['participants.user'])
        ]);
    }

    public function leave(Request $request, $id)
    {
        $activity = SlActivity::findOrFail($id);
        $userId = $request->user()->id;

        $participant = SlActivityParticipant::where('activity_id', $activity->id)
            ->where('user_id', $userId)
            ->first();

        if (!$participant) {
            return response()->json(['success' => false, 'message' => 'Not joined'], 400);
        }

        $wasConfirmed = $participant->status === 'confirmed';
        $participant->delete();

        if ($wasConfirmed) {
            $activity->decrement('current_participants');
            
            // Promote next waiting user
            $nextWaiting = SlActivityParticipant::where('activity_id', $activity->id)
                ->where('status', 'waiting')
                ->orderBy('created_at', 'asc')
                ->first();

            if ($nextWaiting) {
                $nextWaiting->update(['status' => 'confirmed']);
                $activity->increment('current_participants');
            } else {
                if ($activity->current_participants < $activity->quota) {
                    $activity->update(['status' => 'available']);
                }
            }
        }

        return response()->json([
            'success' => true,
            'message' => 'Left activity',
            'data' => $activity->fresh(['participants.user'])
        ]);
    }

    public function update(Request $request, $id)
    {
        $activity = SlActivity::findOrFail($id);

        if ($activity->host_user_id !== $request->user()->id) {
            return response()->json(['success' => false, 'message' => 'Unauthorized'], 403);
        }

        $validated = $request->validate([
            'title' => 'required|string|max:255',
            'sport_type' => 'required|string',
            'activity_type' => 'nullable|string|in:fun_match,sparring',
            'location' => 'nullable|string',
            'date' => 'required|date',
            'time' => 'required|string',
            'quota' => 'required|integer|min:2',
            'cost' => 'nullable|numeric',
            'skill_level' => 'nullable|string',
            'community_id' => 'nullable|exists:sl_communities,id',
            'venue_id' => 'nullable|exists:venues,id',
            'notes' => 'nullable|string',
        ]);

        $activity->update($validated);

        return response()->json([
            'success' => true,
            'message' => 'Activity updated successfully',
            'data' => $activity->fresh(['host', 'community', 'participants.user'])
        ]);
    }

    public function destroy(Request $request, $id)
    {
        $activity = SlActivity::findOrFail($id);
        
        if ($activity->host_user_id !== $request->user()->id) {
            return response()->json(['success' => false, 'message' => 'Unauthorized'], 403);
        }

        $activity->delete();

        return response()->json(['success' => true, 'message' => 'Left activity successfully']);
    }

    public function invite(Request $request, $id)
    {
        $validated = $request->validate([
            'user_id' => 'required|exists:users,id'
        ]);

        $activity = SlActivity::findOrFail($id);
        $friendId = $validated['user_id'];
        $userId = $request->user()->id;

        // Verify that the person inviting is either the host or a confirmed participant
        $isHost = $activity->host_user_id === $userId;
        $isParticipant = SlActivityParticipant::where('activity_id', $activity->id)
            ->where('user_id', $userId)
            ->where('status', 'confirmed')
            ->exists();

        if (!$isHost && !$isParticipant) {
            return response()->json([
                'success' => false,
                'message' => 'You must be a confirmed participant or host to invite others.'
            ], 403);
        }

        // Check if friend is already a participant
        $existing = SlActivityParticipant::where('activity_id', $activity->id)
            ->where('user_id', $friendId)
            ->first();

        if ($existing) {
            return response()->json([
                'success' => false,
                'message' => 'User is already in this activity or has been invited.'
            ], 400);
        }

        SlActivityParticipant::create([
            'activity_id' => $activity->id,
            'user_id' => $friendId,
            'status' => 'invited',
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Invitation sent successfully.'
        ]);
    }

    public function acceptInvitation(Request $request, $id)
    {
        $activity = SlActivity::findOrFail($id);
        $userId = $request->user()->id;

        $participant = SlActivityParticipant::where('activity_id', $activity->id)
            ->where('user_id', $userId)
            ->where('status', 'invited')
            ->first();

        if (!$participant) {
            return response()->json([
                'success' => false,
                'message' => 'No pending invitation found.'
            ], 404);
        }

        $isFull = $activity->current_participants >= $activity->quota;

        if ($isFull) {
            $participant->update(['status' => 'waiting']);
            return response()->json([
                'success' => true,
                'message' => 'Activity is full. You have been added to the waiting list.'
            ]);
        }

        $participant->update(['status' => 'confirmed']);
        $activity->increment('current_participants');

        if ($activity->current_participants >= $activity->quota) {
            $activity->update(['status' => 'full']);
        }

        return response()->json([
            'success' => true,
            'message' => 'Invitation accepted! You have joined the activity.'
        ]);
    }

    public function declineInvitation(Request $request, $id)
    {
        $activity = SlActivity::findOrFail($id);
        $userId = $request->user()->id;

        $participant = SlActivityParticipant::where('activity_id', $activity->id)
            ->where('user_id', $userId)
            ->where('status', 'invited')
            ->first();

        if (!$participant) {
            return response()->json([
                'success' => false,
                'message' => 'No pending invitation found.'
            ], 404);
        }

        $participant->delete();

        return response()->json([
            'success' => true,
            'message' => 'Invitation declined.'
        ]);
    }
}