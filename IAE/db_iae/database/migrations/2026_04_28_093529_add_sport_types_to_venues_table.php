<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        // MySQL requires raw SQL to alter ENUM columns
        DB::statement("ALTER TABLE venues MODIFY COLUMN sport_type ENUM('badminton', 'futsal', 'basketball', 'padel', 'volleyball') NOT NULL");
    }

    public function down(): void
    {
        DB::statement("ALTER TABLE venues MODIFY COLUMN sport_type ENUM('badminton', 'futsal') NOT NULL");
    }
};
