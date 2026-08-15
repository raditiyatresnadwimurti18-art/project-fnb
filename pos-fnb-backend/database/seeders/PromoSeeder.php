<?php

namespace Database\Seeders;

use App\Models\Promo;
use Illuminate\Database\Seeder;
use Carbon\Carbon;

class PromoSeeder extends Seeder
{
    public function run(): void
    {
        // 1. Discount Promo: 20% Off up to 10k, min purchase 50k
        Promo::create([
            'name' => 'Diskon Merdeka 20%',
            'type' => 'discount',
            'value' => 20,
            'is_percentage' => true,
            'max_discount' => 10000,
            'min_purchase' => 50000,
            'buy_qty' => null,
            'free_qty' => null,
            'apply_multiple' => false,
            'start_date' => Carbon::now()->subDays(1),
            'end_date' => Carbon::now()->addDays(30),
            'quota' => 100,
            'used_quota' => 0,
            'is_active' => true,
        ]);

        // 2. Discount Promo: 15k Off nominal, min purchase 100k
        Promo::create([
            'name' => 'Potongan 15Ribu',
            'type' => 'discount',
            'value' => 15000,
            'is_percentage' => false,
            'max_discount' => null,
            'min_purchase' => 100000,
            'buy_qty' => null,
            'free_qty' => null,
            'apply_multiple' => false,
            'start_date' => Carbon::now()->subDays(5),
            'end_date' => Carbon::now()->addDays(15),
            'quota' => 50,
            'used_quota' => 0,
            'is_active' => true,
        ]);

        // 3. BOGO Promo: Buy 2 Get 1 Free (Multiple allowed)
        Promo::create([
            'name' => 'Beli 2 Gratis 1 Es Teh',
            'type' => 'bogo',
            'value' => null,
            'is_percentage' => false,
            'max_discount' => null,
            'min_purchase' => null,
            'buy_qty' => 2,
            'free_qty' => 1,
            'apply_multiple' => true,
            'start_date' => Carbon::now()->subDays(2),
            'end_date' => Carbon::now()->addDays(20),
            'quota' => 200,
            'used_quota' => 0,
            'is_active' => true,
        ]);
    }
}
