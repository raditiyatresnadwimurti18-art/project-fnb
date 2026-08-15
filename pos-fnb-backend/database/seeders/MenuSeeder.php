<?php

namespace Database\Seeders;

use App\Models\Menu;
use App\Models\PriceHistory;
use Illuminate\Database\Seeder;
use Carbon\Carbon;

class MenuSeeder extends Seeder
{
    public function run(): void
    {
        $menus = [
            [
                'kode_menu' => 'MN-001',
                'nama_menu' => 'Nasi Goreng Spesial',
                'kategori' => 'Makanan',
                'deskripsi' => 'Nasi goreng dengan telur, ayam, dan udang.',
                'gambar' => 'https://images.unsplash.com/photo-1603133872878-684f208fb84b?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80',
                'price' => 25000,
            ],
            [
                'kode_menu' => 'MN-002',
                'nama_menu' => 'Mie Goreng Seafood',
                'kategori' => 'Makanan',
                'deskripsi' => 'Mie goreng dengan udang dan cumi.',
                'gambar' => 'https://images.unsplash.com/photo-1585032226651-759b368d7246?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80',
                'price' => 30000,
            ],
            [
                'kode_menu' => 'MN-003',
                'nama_menu' => 'Es Teh Manis',
                'kategori' => 'Minuman',
                'deskripsi' => 'Teh manis dingin menyegarkan.',
                'gambar' => 'https://images.unsplash.com/photo-1559839914-17aae19cb548?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80',
                'price' => 5000,
            ],
            [
                'kode_menu' => 'MN-004',
                'nama_menu' => 'Kopi Susu Gula Aren',
                'kategori' => 'Minuman',
                'deskripsi' => 'Es kopi susu dengan gula aren asli.',
                'gambar' => 'https://images.unsplash.com/photo-1572490122747-3968b75cc699?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80',
                'price' => 18000,
            ],
            [
                'kode_menu' => 'MN-005',
                'nama_menu' => 'Kentang Goreng',
                'kategori' => 'Snack',
                'deskripsi' => 'Kentang goreng renyah dengan saus.',
                'gambar' => 'https://images.unsplash.com/photo-1576107232684-1279f390859f?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80',
                'price' => 15000,
            ],
        ];

        foreach ($menus as $menuData) {
            $price = $menuData['price'];
            unset($menuData['price']);

            $menu = Menu::create($menuData);

            PriceHistory::create([
                'menu_id' => $menu->id,
                'old_price' => $price,
                'new_price' => $price,
                'effective_date' => Carbon::now()->subMonths(2),
                'user_id' => 1, // Assuming User with ID 1 will be seeded
            ]);
        }
    }
}
