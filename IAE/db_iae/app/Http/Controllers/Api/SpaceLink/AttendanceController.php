<?php

namespace App\Http\Controllers\Api\SpaceLink;

use App\Http\Controllers\Controller;
use App\Models\SpaceLink\SlAttendance;
use App\Models\SpaceLink\SlActivityParticipant;
use Illuminate\Http\Request;

class AttendanceController extends Controller
{
    public function mark(Request $request, $activityId)
    {
        $validated = $request->validate([
            'status' => 'required|in:present,absent',
            'user_id' => 'required|exists:users,id',
        ]);

        $participant = SlActivityParticipant::where('activity_id', $activityId)
            ->where('user_id', $validated['user_id'])
            ->firstOrFail();

        $attendance = SlAttendance::updateOrCreate(
            [
                'activity_id' => $activityId,
                'user_id' => $validated['user_id']
            ],
            [
                'status' => $validated['status'],
                'recorded_by' => $request->user()->id
            ]
        );

        return response()->json([
            'success' => true,
            'message' => 'Attendance marked successfully',
            'data' => $attendance
        ]);
    }
}