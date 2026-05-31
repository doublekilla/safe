<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;

class User extends Authenticatable
{
    use HasFactory, Notifiable, HasApiTokens;

    /**
     * The attributes that are mass assignable.
     */
    protected $fillable = [
        'name',
        'email',
        'phone',
        'avatar',
        'role',
        'password',
        'google_id',
    ];

    /**
     * The attributes that should be hidden for serialization.
     */
    protected $hidden = [
        'password',
        'remember_token',
    ];

    /**
     * The attributes that should be cast.
     */
    protected function casts(): array
    {
        return [
            'email_verified_at' => 'datetime',
            'password' => 'hashed',
        ];
    }

    /**
     * Check if user is admin.
     */
    public function getIsAdminAttribute(): bool
    {
        return $this->role === 'admin';
    }

    public function isAdmin(): bool
    {
        return $this->role === 'admin';
    }

    /**
     * Scope for admin users.
     */
    public function scopeAdmin($query)
    {
        return $query->where('role', 'admin');
    }

    /**
     * Scope for customer users.
     */
    public function scopeCustomer($query)
    {
        return $query->where('role', 'customer');
    }

    // ─── EithSpace Relationships ───
    public function bookings()
    {
        return $this->hasMany(Booking::class);
    }

    public function reviews()
    {
        return $this->hasMany(Review::class);
    }

    public function cartItems()
    {
        return $this->hasMany(Cart::class);
    }

    // ─── SpaceLink Relationships ───
    public function slProfile()
    {
        return $this->hasOne(SpaceLink\SlUserProfile::class);
    }

    public function slCommunities()
    {
        return $this->belongsToMany(SpaceLink\SlCommunity::class, 'sl_community_members', 'user_id', 'community_id')
            ->withPivot('role', 'joined_at')
            ->withTimestamps();
    }

    public function slFriendshipsInitiated()
    {
        return $this->hasMany(SpaceLink\SlFriendship::class, 'user_id');
    }

    public function slFriendshipsReceived()
    {
        return $this->hasMany(SpaceLink\SlFriendship::class, 'friend_id');
    }

    public function slHostedActivities()
    {
        return $this->hasMany(SpaceLink\SlActivity::class, 'host_user_id');
    }

    public function slFeedPosts()
    {
        return $this->hasMany(SpaceLink\SlFeedPost::class);
    }

    public function slSentMessages()
    {
        return $this->hasMany(SpaceLink\SlChatMessage::class, 'sender_id');
    }

    /**
     * Get all accepted friends for this user (bidirectional).
     */
    public function getSlFriendsAttribute()
    {
        $initiated = $this->slFriendshipsInitiated()
            ->where('status', 'accepted')
            ->pluck('friend_id');

        $received = $this->slFriendshipsReceived()
            ->where('status', 'accepted')
            ->pluck('user_id');

        return User::whereIn('id', $initiated->merge($received))->get();
    }
}
