<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('bookings', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->string('booking_code', 20)->unique();
            $table->decimal('total_amount', 12, 2);
            $table->decimal('service_fee', 12, 2)->default(0);
            $table->decimal('tax', 12, 2)->default(0);
            $table->text('notes')->nullable();
            $table->enum('status', [
                'pending', 'confirmed', 'completed', 'cancelled',
                'reschedule_requested', 'rescheduled'
            ])->default('pending');
            $table->timestamps();

            $table->index(['user_id', 'status']);
            $table->index('created_at');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('bookings');
    }
};
