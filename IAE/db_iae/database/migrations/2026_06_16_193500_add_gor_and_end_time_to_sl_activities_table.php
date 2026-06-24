<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('sl_activities', function (Blueprint $table) {
            $table->string('gor')->nullable()->after('activity_type');
            $table->string('end_time')->nullable()->after('time');
        });
    }

    public function down(): void
    {
        Schema::table('sl_activities', function (Blueprint $table) {
            $table->dropColumn(['gor', 'end_time']);
        });
    }
};
