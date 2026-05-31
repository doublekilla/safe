<?php

namespace App\Models\SpaceLink;

use App\Models\User;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class SlFeedComment extends Model
{
    protected $table = 'sl_feed_comments';

    protected $fillable = [
        'feed_post_id',
        'user_id',
        'comment',
    ];

    public function post(): BelongsTo
    {
        return $this->belongsTo(SlFeedPost::class, 'feed_post_id');
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }
}
