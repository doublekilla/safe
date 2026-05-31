<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('payments', function (Blueprint $table) {
            $table->string('snap_token')->nullable()->after('transaction_id');
            $table->string('midtrans_transaction_id')->nullable()->after('snap_token');
            $table->string('midtrans_payment_type')->nullable()->after('midtrans_transaction_id');
            $table->json('midtrans_response')->nullable()->after('midtrans_payment_type');

            $table->index('snap_token');
            $table->index('midtrans_transaction_id');
        });
    }

    public function down(): void
    {
        Schema::table('payments', function (Blueprint $table) {
            $table->dropIndex(['snap_token']);
            $table->dropIndex(['midtrans_transaction_id']);
            $table->dropColumn([
                'snap_token',
                'midtrans_transaction_id',
                'midtrans_payment_type',
                'midtrans_response',
            ]);
        });
    }
};
