<?php

namespace App\Http\Controllers\Api\SpaceLink;

use App\Http\Controllers\Controller;
use App\Models\SpaceLink\SlUserProfile;
use Illuminate\Http\Request;

class ProfileController extends Controller
{
    public function show(Request $request)
    {
        $user = $request->user();
        $profile = $user->slProfile;

        if (!$profile) {
            $profile = SlUserProfile::create(['user_id' => $user->id]);
        }

        return response()->json([
            'success' => true,
            'data' => [
                'user' => $user,
                'profile' => $profile
            ]
        ]);
    }

    public function update(Request $request)
    {
        $user = $request->user();
        $profile = SlUserProfile::firstOrCreate(['user_id' => $user->id]);

        $validated = $request->validate([
            'bio' => 'nullable|string',
            'location' => 'nullable|string',
            'favorite_sports' => 'nullable|array',
            'skill_level' => 'nullable|string',
            'availability' => 'nullable|array',
            'joining_purpose' => 'nullable|array',
            'age' => 'nullable|integer',
            'gender' => 'nullable|string',
            'profile_image' => 'nullable|string',
            'profile_image_base64' => 'nullable|string',
        ]);

        if ($request->has('profile_image_base64') && !empty($request->profile_image_base64)) {
            $base64Image = $request->profile_image_base64;
            if (preg_match('/^data:image\/(\w+);base64,/', $base64Image, $type)) {
                $data = substr($base64Image, strpos($base64Image, ',') + 1);
                $type = strtolower($type[1]);
                if (in_array($type, ['jpg', 'jpeg', 'gif', 'png', 'webp'])) {
                    $imageName = 'profile_' . $user->id . '_' . time() . '.' . $type;
                    \Illuminate\Support\Facades\Storage::disk('public')->put('profiles/' . $imageName, base64_decode($data));
                    $validated['profile_image'] = asset('storage/profiles/' . $imageName);
                }
            }
        }

        $profile->update($validated);

        if ($request->has('name') || $request->has('phone')) {
            $user->update($request->only(['name', 'phone']));
        }

        return response()->json([
            'success' => true,
            'message' => 'Profile updated successfully',
            'data' => [
                'user' => $user->fresh(),
                'profile' => $profile->fresh()
            ]
        ]);
    }
}