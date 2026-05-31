<?php

namespace App\Models\SpaceLink;

use App\Models\User;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class SlFeedPost extends Model
{
    protected $table = 'sl_feed_posts';

    protected $fillable = [
        'user_id',
        'community_id',
        'text',
        'image',
        'tag',
    ];

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function community(): BelongsTo
    {
        return $this->belongsTo(SlCommunity::class, 'community_id');
    }

    public function likes(): HasMany
    {
        return $this->hasMany(SlFeedLike::class, 'feed_post_id');
    }

<<<<<<< HEAD
    public function comments(): HasMany
    {
        return $this->hasMany(SlFeedComment::class, 'feed_post_id');
    }

=======
>>>>>>> 2bf0c916ae27714e7e8ee712538323298f719d29
    /**
     * Check if a given user has liked this post.
     */
    public function isLikedBy(int $userId): bool
    {
        return $this->likes()->where('user_id', $userId)->exists();
    }
}
