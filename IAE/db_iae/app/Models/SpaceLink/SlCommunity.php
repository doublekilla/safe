<?php

namespace App\Models\SpaceLink;

use App\Models\User;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;

class SlCommunity extends Model
{
    protected $table = 'sl_communities';

    protected $fillable = [
        'name',
        'image',
        'sport_category',
        'location',
        'description',
        'rules',
        'privacy',
        'activity_frequency',
        'admin_user_id',
    ];

    public function admin(): BelongsTo
    {
        return $this->belongsTo(User::class, 'admin_user_id');
    }

    public function memberships(): HasMany
    {
        return $this->hasMany(SlCommunityMember::class, 'community_id');
    }

    public function members(): BelongsToMany
    {
        return $this->belongsToMany(User::class, 'sl_community_members', 'community_id', 'user_id')
            ->withPivot('role', 'joined_at')
            ->withTimestamps();
    }

    public function activities(): HasMany
    {
        return $this->hasMany(SlActivity::class, 'community_id');
    }

    public function feedPosts(): HasMany
    {
        return $this->hasMany(SlFeedPost::class, 'community_id');
    }

    public function chatMessages(): HasMany
    {
        return $this->hasMany(SlChatMessage::class, 'group_id');
    }
}
