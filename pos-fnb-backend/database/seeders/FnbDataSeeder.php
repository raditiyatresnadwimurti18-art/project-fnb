<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use App\Models\Menu;
use App\Models\PriceHistory;
use App\Models\InventoryBatch;
use App\Models\Promo;
use Carbon\Carbon;

class FnbDataSeeder extends Seeder
{
    public function run(): void
    {
        DB::statement('SET FOREIGN_KEY_CHECKS=0;');
        DB::table('transaction_items')->truncate();
        DB::table('transactions')->truncate();
        DB::table('promos')->truncate();
        DB::table('inventory_batches')->truncate();
        DB::table('price_histories')->truncate();
        DB::table('menus')->truncate();
        DB::statement('SET FOREIGN_KEY_CHECKS=1;');

        // 1. Create Menus
        $menus = [
            ['kode' => 'MKN-001', 'nama' => 'Nasi Goreng Spesial', 'kategori' => 'Makanan', 'price' => 25000, 'modal' => 15000, 'stock' => 50],
            ['kode' => 'MKN-002', 'nama' => 'Mie Goreng Jawa', 'kategori' => 'Makanan', 'price' => 20000, 'modal' => 12000, 'stock' => 40],
            ['kode' => 'MNM-001', 'nama' => 'Es Teh Manis', 'kategori' => 'Minuman', 'price' => 5000, 'modal' => 2000, 'stock' => 100],
            ['kode' => 'MNM-002', 'nama' => 'Es Jeruk', 'kategori' => 'Minuman', 'price' => 8000, 'modal' => 3500, 'stock' => 80],
            ['kode' => 'COF-001', 'nama' => 'Kopi Susu Gula Aren', 'kategori' => 'Coffee', 'price' => 18000, 'modal' => 8000, 'stock' => 60],
            ['kode' => 'DSS-001', 'nama' => 'Pudding Coklat', 'kategori' => 'Dessert', 'price' => 12000, 'modal' => 5000, 'stock' => 30],
        ];

        foreach ($menus as $m) {
            $menu = Menu::create([
                'kode_menu' => $m['kode'],
                'nama_menu' => $m['nama'],
                'kategori' => $m['kategori'],
                'deskripsi' => 'Deskripsi untuk ' . $m['nama'],
                'is_active' => true,
                'modal' => $m['modal'],
            ]);

            PriceHistory::create([
                'menu_id' => $menu->id,
                'old_price' => $m['price'],
                'new_price' => $m['price'],
                'effective_date' => Carbon::now(),
            ]);

            InventoryBatch::create([
                'menu_id' => $menu->id,
                'qty_purchased' => $m['stock'],
                'qty_remaining' => $m['stock'],
                'modal' => $m['modal'],
                'purchased_at' => Carbon::now()->subDays(2),
            ]);
        }

        // 2. Create Promo
        Promo::create([
            'name' => 'Diskon Opening',
            'type' => 'discount',
            'is_percentage' => true,
            'value' => 10, // 10%
            'min_purchase' => 50000,
            'max_discount' => 20000,
            'start_date' => Carbon::now()->subDays(1),
            'end_date' => Carbon::now()->addDays(30),
            'is_active' => true,
            'quota' => 100,
            'used_quota' => 0,
        ]);
    }
}
