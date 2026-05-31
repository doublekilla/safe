<?php

namespace App\Models\SpaceLink;

use App\Models\User;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class SlUserProfile extends Model
{
    protected $table = 'sl_user_profiles';

    protected $fillable = [
        'user_id',
        'location',
        'favorite_sports',
        'skill_level',
        'availability',
        'joining_purpose',
        'bio',
        'age',
        'gender',
        'profile_image',
    ];

    protected function casts(): array
    {
        return [
            'favorite_sports' => 'array',
            'availability' => 'array',
            'joining_purpose' => 'array',
        ];
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }
}
