<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('sl_user_profiles', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->unique()->constrained('users')->cascadeOnDelete();
            $table->string('location')->nullable();
            $table->json('favorite_sports')->nullable();
            $table->string('skill_level')->nullable(); // beginner, intermediate, advanced
            $table->json('availability')->nullable();
            $table->json('joining_purpose')->nullable();
            $table->text('bio')->nullable();
            $table->integer('age')->nullable();
            $table->string('gender', 20)->nullable();
            $table->string('profile_image')->nullable();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('sl_user_profiles');
    }
};
