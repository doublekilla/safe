<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Payment extends Model
{
    use HasFactory;

    protected $fillable = [
        'booking_id', 'amount', 'method', 'status',
        'payment_proof', 'transaction_id', 'paid_at', 'expired_at', 'notes',
        'snap_token', 'midtrans_transaction_id', 'midtrans_payment_type', 'midtrans_response',
    ];

    protected $casts = [
        'amount' => 'decimal:2',
        'paid_at' => 'datetime',
        'expired_at' => 'datetime',
        'midtrans_response' => 'array',
    ];

    public function booking()
    {
        return $this->belongsTo(Booking::class);
    }

    // Scopes
    public function scopePending($query)
    {
        return $query->where('status', 'pending');
    }

    public function scopePaid($query)
    {
        return $query->where('status', 'paid');
    }

    public function scopeByStatus($query, $status)
    {
        return $query->where('status', $status);
    }

    // Accessors
    public function getIsPaidAttribute()
    {
        return $this->status === 'paid';
    }

    public function getIsExpiredAttribute()
    {
        return $this->status === 'expired' ||
               ($this->status === 'pending' && $this->expired_at && $this->expired_at->isPast());
    }

    /**
     * Get a human-readable payment method label.
     */
    public function getMethodLabelAttribute()
    {
        $labels = [
            'credit_card' => 'Kartu Kredit',
            'bank_transfer' => 'Transfer Bank',
            'echannel' => 'Mandiri Bill',
            'bca_va' => 'BCA Virtual Account',
            'bni_va' => 'BNI Virtual Account',
            'bri_va' => 'BRI Virtual Account',
            'permata_va' => 'Permata Virtual Account',
            'gopay' => 'GoPay',
            'shopeepay' => 'ShopeePay',
            'qris' => 'QRIS',
            'cstore' => 'Convenience Store',
            'akulaku' => 'Akulaku',
        ];

        return $labels[$this->method] ?? ucfirst(str_replace('_', ' ', $this->method ?? 'Belum dipilih'));
    }
}
