<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('sl_communities', function (Blueprint $table) {
            $table->id();
            $table->string('name');
            $table->string('image')->nullable();
            $table->string('sport_category');
            $table->string('location')->nullable();
            $table->text('description')->nullable();
            $table->text('rules')->nullable();
            $table->enum('privacy', ['public', 'private'])->default('public');
            $table->string('activity_frequency')->nullable();
            $table->foreignId('admin_user_id')->constrained('users')->cascadeOnDelete();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('sl_communities');
    }
};
