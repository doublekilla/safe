<?php

namespace App\Models\SpaceLink;

use App\Models\User;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class SlFeedLike extends Model
{
    protected $table = 'sl_feed_likes';

    protected $fillable = [
        'feed_post_id',
        'user_id',
    ];

    public function feedPost(): BelongsTo
    {
        return $this->belongsTo(SlFeedPost::class, 'feed_post_id');
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }
}
