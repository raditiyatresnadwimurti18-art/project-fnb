<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     * - Add unique index to kode_menu to prevent duplicate codes
     * - Drop redundant is_active column (now computed from inventory_batches stock)
     */
    public function up(): void
    {
        Schema::table('menus', function (Blueprint $table) {
            $table->unique('kode_menu');
            $table->dropColumn('is_active');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('menus', function (Blueprint $table) {
            $table->dropUnique(['kode_menu']);
            $table->boolean('is_active')->default(true)->after('gambar');
        });
    }
};
