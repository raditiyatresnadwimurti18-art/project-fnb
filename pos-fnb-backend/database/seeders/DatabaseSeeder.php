<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;

class DatabaseSeeder extends Seeder
{
    public function run(): void
    {
        $this->call([
            UserSeeder::class,
            MenuSeeder::class, // Also seeds PriceHistory
            PromoSeeder::class,
            // Skipping transactions since they should be created via API
        ]);
    }
}
