<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class VenueField extends Model
{
    use HasFactory;

    protected $fillable = ['venue_id', 'name', 'photo', 'status'];

    public function venue()
    {
        return $this->belongsTo(Venue::class);
    }

    public function schedules()
    {
        return $this->hasMany(Schedule::class);
    }

    public function bookingItems()
    {
        return $this->hasMany(BookingItem::class);
    }

    public function scopeActive($query)
    {
        return $query->where('status', 'active');
    }
}
