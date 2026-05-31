<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('venues', function (Blueprint $table) {
            $table->id();
            $table->string('name');
            $table->enum('sport_type', ['badminton', 'futsal']);
            $table->text('description')->nullable();
            $table->string('location');
            $table->decimal('price_per_hour', 12, 2);
            $table->json('facilities')->nullable();
            $table->json('photos')->nullable();
            $table->json('operating_hours')->nullable();
            $table->enum('status', ['active', 'inactive', 'maintenance'])->default('active');
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('venues');
    }
};
