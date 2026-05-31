<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('schedules', function (Blueprint $table) {
            $table->id();
            $table->foreignId('venue_field_id')->constrained()->cascadeOnDelete();
            $table->date('date');
            $table->time('start_time');
            $table->time('end_time');
            $table->decimal('price', 12, 2);
            $table->enum('status', ['available', 'booked', 'pending', 'blocked', 'maintenance'])->default('available');
            $table->timestamps();

            $table->index(['venue_field_id', 'date', 'status']);
            $table->unique(['venue_field_id', 'date', 'start_time']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('schedules');
    }
};
