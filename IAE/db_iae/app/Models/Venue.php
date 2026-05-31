<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Venue extends Model
{
    use HasFactory;

    protected $fillable = [
        'name', 'sport_type', 'description', 'location',
        'price_per_hour', 'facilities', 'photos', 'operating_hours', 'status',
    ];

    protected $casts = [
        'facilities' => 'array',
        'photos' => 'array',
        'operating_hours' => 'array',
        'price_per_hour' => 'decimal:2',
    ];

    // Relationships
    public function fields()
    {
        return $this->hasMany(VenueField::class);
    }

    public function reviews()
    {
        return $this->hasMany(Review::class);
    }

    public function activeFields()
    {
        return $this->hasMany(VenueField::class)->where('status', 'active');
    }

    // Scopes
    public function scopeActive($query)
    {
        return $query->where('status', 'active');
    }

    public function scopeBySport($query, $sportType)
    {
        return $query->where('sport_type', $sportType);
    }

    public function scopePriceBetween($query, $min, $max)
    {
        return $query->whereBetween('price_per_hour', [$min, $max]);
    }

    public function scopeSearch($query, $search)
    {
        return $query->where(function ($q) use ($search) {
            $q->where('name', 'like', "%{$search}%")
              ->orWhere('location', 'like', "%{$search}%")
              ->orWhere('description', 'like', "%{$search}%");
        });
    }

    // Accessors
    public function getAverageRatingAttribute()
    {
        return $this->reviews()->where('is_visible', true)->avg('rating') ?? 0;
    }

    public function getReviewCountAttribute()
    {
        return $this->reviews()->where('is_visible', true)->count();
    }

    public function getMainPhotoAttribute()
    {
        $photos = $this->photos;
        return $photos && count($photos) > 0 ? $photos[0] : null;
    }
}
