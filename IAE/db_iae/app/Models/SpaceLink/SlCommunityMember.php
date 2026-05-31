<?php

namespace App\Models\SpaceLink;

use App\Models\User;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class SlCommunityMember extends Model
{
    protected $table = 'sl_community_members';

    protected $fillable = [
        'community_id',
        'user_id',
        'role',
        'joined_at',
    ];

    protected function casts(): array
    {
        return [
            'joined_at' => 'datetime',
        ];
    }

    public function community(): BelongsTo
    {
        return $this->belongsTo(SlCommunity::class, 'community_id');
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }
}
