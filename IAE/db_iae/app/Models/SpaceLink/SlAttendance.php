<?php

namespace App\Models\SpaceLink;

use App\Models\User;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class SlAttendance extends Model
{
    protected $table = 'sl_attendances';

    protected $fillable = [
        'activity_id',
        'user_id',
        'status',
    ];

    public function activity(): BelongsTo
    {
        return $this->belongsTo(SlActivity::class, 'activity_id');
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }
}
