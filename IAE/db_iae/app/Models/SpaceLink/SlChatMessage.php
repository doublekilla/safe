<?php

namespace App\Models\SpaceLink;

use App\Models\User;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class SlChatMessage extends Model
{
    protected $table = 'sl_chat_messages';

    protected $fillable = [
        'sender_id',
        'receiver_id',
        'group_id',
        'message',
        'type',
        'linked_activity_id',
    ];

    public function sender(): BelongsTo
    {
        return $this->belongsTo(User::class, 'sender_id');
    }

    public function receiver(): BelongsTo
    {
        return $this->belongsTo(User::class, 'receiver_id');
    }

    public function group(): BelongsTo
    {
        return $this->belongsTo(SlCommunity::class, 'group_id');
    }

    public function linkedActivity(): BelongsTo
    {
        return $this->belongsTo(SlActivity::class, 'linked_activity_id');
    }
}
