<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        DB::statement("ALTER TABLE sl_activity_participants MODIFY COLUMN status ENUM('confirmed', 'waiting', 'canceled', 'invited') DEFAULT 'confirmed'");
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        DB::statement("ALTER TABLE sl_activity_participants MODIFY COLUMN status ENUM('confirmed', 'waiting', 'canceled') DEFAULT 'confirmed'");
    }
};
