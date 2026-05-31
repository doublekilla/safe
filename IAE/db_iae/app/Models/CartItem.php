<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class CartItem extends Model
{
    use HasFactory;

    protected $fillable = [
        'cart_id', 'schedule_id', 'venue_field_id',
        'date', 'start_time', 'end_time', 'price',
    ];

    protected $casts = [
        'date' => 'date:Y-m-d',
        'price' => 'decimal:2',
    ];

    public function cart()
    {
        return $this->belongsTo(Cart::class);
    }

    public function schedule()
    {
        return $this->belongsTo(Schedule::class);
    }

    public function venueField()
    {
        return $this->belongsTo(VenueField::class);
    }
}
