<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('sl_chat_messages', function (Blueprint $table) {
            $table->id();
            $table->foreignId('sender_id')->constrained('users')->cascadeOnDelete();
            $table->foreignId('receiver_id')->nullable()->constrained('users')->nullOnDelete();
            $table->foreignId('group_id')->nullable()->constrained('sl_communities')->nullOnDelete();
            $table->text('message');
            $table->string('type')->default('text'); // text, activity_invite, event_reminder, image
            $table->unsignedBigInteger('linked_activity_id')->nullable();
            $table->timestamps();

            $table->foreign('linked_activity_id')->references('id')->on('sl_activities')->nullOnDelete();
            $table->index(['sender_id', 'receiver_id']);
            $table->index(['group_id', 'created_at']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('sl_chat_messages');
    }
};
