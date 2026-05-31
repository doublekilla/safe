<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('sl_activities', function (Blueprint $table) {
            $table->id();
            $table->string('title');
            $table->string('sport_type');
            $table->string('activity_type')->default('fun_match'); // fun_match, sparring
            $table->string('location')->nullable();
            $table->date('date')->nullable();
            $table->string('time')->nullable();
            $table->integer('quota')->default(0);
            $table->integer('current_participants')->default(0);
            $table->decimal('cost', 12, 2)->default(0);
            $table->string('skill_level')->nullable();
            $table->foreignId('host_user_id')->constrained('users')->cascadeOnDelete();
            $table->text('notes')->nullable();
            $table->enum('status', ['available', 'full', 'completed', 'canceled'])->default('available');
            $table->foreignId('community_id')->nullable()->constrained('sl_communities')->nullOnDelete();
            $table->unsignedBigInteger('linked_booking_id')->nullable();
            $table->timestamps();

            $table->foreign('linked_booking_id')->references('id')->on('bookings')->nullOnDelete();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('sl_activities');
    }
};
