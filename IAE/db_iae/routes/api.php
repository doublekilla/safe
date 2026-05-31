<?php

use App\Http\Controllers\Api\SpaceLink;
use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| SpaceLink API Routes
|--------------------------------------------------------------------------
| These routes serve the SpaceLink Flutter mobile app.
| Base URL: http://10.0.2.2:8001/api (Android emulator)
| Auth: Laravel Sanctum (Bearer token)
*/

// ─── Public Auth ───
Route::prefix('auth')->group(function () {
    Route::post('/login', [SpaceLink\AuthController::class, 'login']);
    Route::post('/register', [SpaceLink\AuthController::class, 'register']);
});

// ─── Authenticated Routes ───
Route::middleware('auth:sanctum')->group(function () {

    // Auth
    Route::get('/auth/me', [SpaceLink\AuthController::class, 'me']);
    Route::post('/auth/logout', [SpaceLink\AuthController::class, 'logout']);
    Route::post('/auth/change-password', [SpaceLink\AuthController::class, 'changePassword']);

    // Profile
    Route::get('/profile', [SpaceLink\ProfileController::class, 'show']);
    Route::put('/profile', [SpaceLink\ProfileController::class, 'update']);

    // Communities
    Route::get('/communities', [SpaceLink\CommunityController::class, 'index']);
    Route::get('/communities/mine', [SpaceLink\CommunityController::class, 'mine']);
    Route::get('/communities/{id}', [SpaceLink\CommunityController::class, 'show']);
    Route::post('/communities', [SpaceLink\CommunityController::class, 'store']);
    Route::post('/communities/{id}', [SpaceLink\CommunityController::class, 'update']);
    Route::delete('/communities/{id}', [SpaceLink\CommunityController::class, 'destroy']);
    Route::post('/communities/{id}/join', [SpaceLink\CommunityController::class, 'join']);
    Route::post('/communities/{id}/leave', [SpaceLink\CommunityController::class, 'leave']);
    Route::get('/communities/{id}/requests', [SpaceLink\CommunityController::class, 'pendingRequests']);
    Route::post('/communities/{id}/approve', [SpaceLink\CommunityController::class, 'approveRequest']);
    Route::post('/communities/{id}/deny', [SpaceLink\CommunityController::class, 'denyRequest']);
    Route::post('/communities/{id}/remove-member', [SpaceLink\CommunityController::class, 'removeMember']);
    Route::post('/communities/{id}/assign-admin', [SpaceLink\CommunityController::class, 'assignAdmin']);

    // Activities
    Route::get('/activities', [SpaceLink\ActivityController::class, 'index']);
    Route::get('/activities/my', [SpaceLink\ActivityController::class, 'myActivities']);
    Route::get('/activities/invitations', [SpaceLink\ActivityController::class, 'invitations']);
    Route::get('/activities/upcoming', [SpaceLink\ActivityController::class, 'upcoming']);
    Route::post('/activities', [SpaceLink\ActivityController::class, 'store']);
    Route::get('/activities/{id}', [SpaceLink\ActivityController::class, 'show']);
    Route::put('/activities/{id}', [SpaceLink\ActivityController::class, 'update']);
    Route::delete('/activities/{id}', [SpaceLink\ActivityController::class, 'destroy']);
    Route::post('/activities/{id}/join', [SpaceLink\ActivityController::class, 'join']);
    Route::delete('/activities/{id}/leave', [SpaceLink\ActivityController::class, 'leave']);
    Route::post('/activities/{id}/invite', [SpaceLink\ActivityController::class, 'invite']);
    Route::post('/activities/{id}/accept-invite', [SpaceLink\ActivityController::class, 'acceptInvitation']);
    Route::post('/activities/{id}/decline-invite', [SpaceLink\ActivityController::class, 'declineInvitation']);

    // Attendance
    Route::post('/activities/{id}/attendance', [SpaceLink\AttendanceController::class, 'mark']);

    // Feed
    Route::get('/feed', [SpaceLink\FeedController::class, 'index']);
    Route::post('/feed', [SpaceLink\FeedController::class, 'store']);
    Route::post('/feed/{id}/like', [SpaceLink\FeedController::class, 'toggleLike']);

    // Friends
    Route::get('/friends', [SpaceLink\FriendController::class, 'index']);
    Route::get('/friends/requests', [SpaceLink\FriendController::class, 'requests']);
    Route::get('/friends/search', [SpaceLink\FriendController::class, 'search']);
    Route::post('/friends/{id}/add', [SpaceLink\FriendController::class, 'add']);
    Route::post('/friends/{id}/accept', [SpaceLink\FriendController::class, 'accept']);
    Route::delete('/friends/{id}/remove', [SpaceLink\FriendController::class, 'remove']);

    // Chats
    Route::get('/chat', [SpaceLink\ChatController::class, 'index']);
    Route::get('/chat/private/{id}', [SpaceLink\ChatController::class, 'privateMessages']);
    Route::get('/chat/groups/{id}/messages', [SpaceLink\ChatController::class, 'groupMessages']);
    Route::post('/chat/send', [SpaceLink\ChatController::class, 'send']);
    Route::delete('/chat/private/{id}', [SpaceLink\ChatController::class, 'deletePrivateChat']);
    Route::post('/chat/messages/delete', [SpaceLink\ChatController::class, 'deleteMessages']);

    // Venues
    Route::get('/venues', [SpaceLink\VenueApiController::class, 'index']);
    Route::get('/venues/{id}', [SpaceLink\VenueApiController::class, 'show']);

    // Bookings (Fallback if they hit API)
    Route::post('/bookings', [\App\Http\Controllers\BookingController::class, 'store']);
});