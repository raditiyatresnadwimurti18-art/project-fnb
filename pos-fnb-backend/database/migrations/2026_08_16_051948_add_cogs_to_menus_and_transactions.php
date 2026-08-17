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
        Schema::table('menus', function (Blueprint $table) {
            $table->decimal('modal', 15, 2)->default(0)->after('is_active');
        });

        Schema::table('transactions', function (Blueprint $table) {
            $table->string('payment_method')->default('Cash')->after('change_amount');
        });

        Schema::table('transaction_items', function (Blueprint $table) {
            $table->decimal('modal_saat_ini', 15, 2)->default(0)->after('price');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('menus', function (Blueprint $table) {
            $table->dropColumn('modal');
        });

        Schema::table('transactions', function (Blueprint $table) {
            $table->dropColumn('payment_method');
        });

        Schema::table('transaction_items', function (Blueprint $table) {
            $table->dropColumn('modal_saat_ini');
        });
    }
};
