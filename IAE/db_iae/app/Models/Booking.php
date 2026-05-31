<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Str;

class Booking extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id', 'booking_code', 'total_amount', 'service_fee',
        'tax', 'notes', 'status',
    ];

    protected $casts = [
        'total_amount' => 'decimal:2',
        'service_fee' => 'decimal:2',
        'tax' => 'decimal:2',
    ];

    protected static function boot()
    {
        parent::boot();

        static::creating(function ($booking) {
            if (empty($booking->booking_code)) {
                $booking->booking_code = 'ES-' . strtoupper(Str::random(8));
            }
        });
    }

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function items()
    {
        return $this->hasMany(BookingItem::class);
    }

    public function payment()
    {
        return $this->hasOne(Payment::class);
    }

    public function review()
    {
        return $this->hasOne(Review::class);
    }

    // Scopes
    public function scopeByStatus($query, $status)
    {
        return $query->where('status', $status);
    }

    public function scopeForUser($query, $userId)
    {
        return $query->where('user_id', $userId);
    }

    public function scopeToday($query)
    {
        return $query->whereDate('created_at', now()->toDateString());
    }

    public function scopeThisWeek($query)
    {
        return $query->whereBetween('created_at', [now()->startOfWeek(), now()->endOfWeek()]);
    }

    public function scopeThisMonth($query)
    {
        return $query->whereMonth('created_at', now()->month)
                     ->whereYear('created_at', now()->year);
    }

    // Accessors
    public function getGrandTotalAttribute()
    {
        return $this->total_amount + $this->service_fee + $this->tax;
    }

    public function getIsCancellableAttribute()
    {
        return in_array($this->status, ['pending', 'confirmed']);
    }

    public function getIsReschedulableAttribute()
    {
        return in_array($this->status, ['confirmed']);
    }

    public function getHasReviewAttribute()
    {
        return $this->review()->exists();
    }

    /**
     * Auto-complete this booking if all scheduled slots have ended.
     */
    public function autoCompleteIfDone(): bool
    {
        if ($this->status !== 'confirmed') {
            return false;
        }

        // Check payment is paid
        if (!$this->payment || $this->payment->status !== 'paid') {
            return false;
        }

        $now = now();
        $this->loadMissing('items');

        if ($this->items->isEmpty()) {
            return false;
        }

        foreach ($this->items as $item) {
            $endDateTime = \Carbon\Carbon::parse(
                \Carbon\Carbon::parse($item->date)->toDateString() . ' ' . $item->end_time
            );

            if ($endDateTime->gt($now)) {
                return false; // At least one slot hasn't ended yet
            }
        }

        $this->update(['status' => 'completed']);
        return true;
    }

    /**
     * Auto-complete all eligible confirmed bookings.
     */
    public static function autoCompleteAll(): int
    {
        $count = 0;
        $bookings = static::where('status', 'confirmed')
            ->whereHas('payment', fn ($q) => $q->where('status', 'paid'))
            ->with(['items', 'payment'])
            ->get();

        foreach ($bookings as $booking) {
            if ($booking->autoCompleteIfDone()) {
                $count++;
            }
        }

        return $count;
    }
}
