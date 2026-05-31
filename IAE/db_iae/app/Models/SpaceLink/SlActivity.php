<?php

namespace App\Models\SpaceLink;

use App\Models\User;
use App\Models\Venue;
use Illuminate\Database\Eloquent\Model;

class SlActivity extends Model
{
    protected $table = 'sl_activities';

    protected $fillable = [
        'title',
        'sport_type',
        'activity_type',
        'location',
        'date',
        'time',
        'quota',
        'current_participants',
        'cost',
        'skill_level',
        'host_user_id',
        'notes',
        'status',
        'community_id',
        'linked_booking_id',
    ];

    protected $casts = [
        'date' => 'date',
        'cost' => 'decimal:2',
    ];

    protected $with = ['host.slProfile'];

    public function host()
    {
        return $this->belongsTo(User::class, 'host_user_id');
    }

    public function community()
    {
        return $this->belongsTo(SlCommunity::class, 'community_id');
    }

    public function booking()
    {
        return $this->belongsTo(\App\Models\Booking::class, 'linked_booking_id');
    }

    public function participants()
    {
        return $this->hasMany(SlActivityParticipant::class, 'activity_id');
    }
}