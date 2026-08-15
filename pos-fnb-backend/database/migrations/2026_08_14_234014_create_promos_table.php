<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('promos', function (Blueprint $table) {
            $table->id();
            $table->string('name');
            $table->enum('type', ['discount', 'bogo']);
            $table->decimal('value', 15, 2)->nullable();
            $table->boolean('is_percentage')->default(false);
            $table->decimal('max_discount', 15, 2)->nullable();
            $table->decimal('min_purchase', 15, 2)->nullable();
            $table->integer('buy_qty')->nullable();
            $table->integer('free_qty')->nullable();
            $table->boolean('apply_multiple')->default(false);
            $table->dateTime('start_date');
            $table->dateTime('end_date');
            $table->integer('quota')->nullable();
            $table->integer('used_quota')->default(0);
            $table->boolean('is_active')->default(true);
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('promos');
    }
};
