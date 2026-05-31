<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('sl_feed_posts', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained('users')->cascadeOnDelete();
            $table->foreignId('community_id')->nullable()->constrained('sl_communities')->nullOnDelete();
            $table->text('text');
            $table->string('image')->nullable();
            $table->string('tag')->nullable(); // match_result, announcement, training, fun_moment
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('sl_feed_posts');
    }
};
