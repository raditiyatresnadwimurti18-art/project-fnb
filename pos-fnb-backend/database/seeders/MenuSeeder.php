<?php

namespace Database\Seeders;

use App\Models\Menu;
use App\Models\InventoryBatch;
use Illuminate\Database\Seeder;
use Carbon\Carbon;

class MenuSeeder extends Seeder
{
    public function run(): void
    {
        $menus = [
            // Makanan Utama
            [
                'kode_menu' => 'MN-001',
                'nama_menu' => 'Nasi Goreng Spesial',
                'kategori' => 'Makanan',
                'deskripsi' => 'Nasi goreng dengan telur, ayam, dan udang.',
                'gambar' => 'https://images.unsplash.com/photo-1603133872878-684f208fb84b?auto=format&fit=crop&w=500&q=80',
                'price' => 25000,
                'modal' => 15000,
                'stock' => 50,
            ],
            [
                'kode_menu' => 'MN-002',
                'nama_menu' => 'Mie Goreng Seafood',
                'kategori' => 'Makanan',
                'deskripsi' => 'Mie goreng kenyal dengan udang, cumi, dan bakso ikan.',
                'gambar' => 'https://images.unsplash.com/photo-1585032226651-759b368d7246?auto=format&fit=crop&w=500&q=80',
                'price' => 30000,
                'modal' => 18000,
                'stock' => 40,
            ],
            [
                'kode_menu' => 'MN-003',
                'nama_menu' => 'Ayam Geprek Sambal Bawang',
                'kategori' => 'Makanan',
                'deskripsi' => 'Ayam goreng crispy digeprek dengan sambal bawang super pedas.',
                'gambar' => 'https://images.unsplash.com/photo-1626804475297-41609ea2649f?auto=format&fit=crop&w=500&q=80',
                'price' => 22000,
                'modal' => 12000,
                'stock' => 60,
            ],
            [
                'kode_menu' => 'MN-004',
                'nama_menu' => 'Sate Ayam Madura',
                'kategori' => 'Makanan',
                'deskripsi' => '10 Tusuk sate ayam dengan bumbu kacang kental.',
                'gambar' => 'https://images.unsplash.com/photo-1555126634-323283e090f4?auto=format&fit=crop&w=500&q=80',
                'price' => 28000,
                'modal' => 16000,
                'stock' => 35,
            ],
            
            // Minuman
            [
                'kode_menu' => 'MN-005',
                'nama_menu' => 'Es Teh Manis',
                'kategori' => 'Minuman',
                'deskripsi' => 'Teh manis dingin menyegarkan, seduhan daun teh pilihan.',
                'gambar' => 'https://images.unsplash.com/photo-1559839914-17aae19cb548?auto=format&fit=crop&w=500&q=80',
                'price' => 5000,
                'modal' => 1500,
                'stock' => 150,
            ],
            [
                'kode_menu' => 'MN-006',
                'nama_menu' => 'Es Jeruk Peras',
                'kategori' => 'Minuman',
                'deskripsi' => 'Perasan jeruk segar asli dengan gula cair alami.',
                'gambar' => 'https://images.unsplash.com/photo-1622483767028-3f66f32aef97?auto=format&fit=crop&w=500&q=80',
                'price' => 8000,
                'modal' => 3000,
                'stock' => 80,
            ],
            [
                'kode_menu' => 'MN-007',
                'nama_menu' => 'Matcha Latte Ice',
                'kategori' => 'Minuman',
                'deskripsi' => 'Susu segar berpadu dengan bubuk matcha jepang asli.',
                'gambar' => 'https://images.unsplash.com/photo-1515823662972-da6a2e4d3002?auto=format&fit=crop&w=500&q=80',
                'price' => 20000,
                'modal' => 9000,
                'stock' => 50,
            ],

            // Coffee
            [
                'kode_menu' => 'MN-008',
                'nama_menu' => 'Kopi Susu Gula Aren',
                'kategori' => 'Coffee',
                'deskripsi' => 'Es kopi susu espresso dengan gula aren nusantara.',
                'gambar' => 'https://images.unsplash.com/photo-1572490122747-3968b75cc699?auto=format&fit=crop&w=500&q=80',
                'price' => 18000,
                'modal' => 7500,
                'stock' => 75,
            ],
            [
                'kode_menu' => 'MN-009',
                'nama_menu' => 'Americano Dingin',
                'kategori' => 'Coffee',
                'deskripsi' => 'Single shot espresso dicampur dengan air es.',
                'gambar' => 'https://images.unsplash.com/photo-1551030173-122aabc4489c?auto=format&fit=crop&w=500&q=80',
                'price' => 15000,
                'modal' => 5000,
                'stock' => 100,
            ],
            [
                'kode_menu' => 'MN-010',
                'nama_menu' => 'Caramel Macchiato',
                'kategori' => 'Coffee',
                'deskripsi' => 'Paduan susu, vanilla, espresso, dan saus karamel di atasnya.',
                'gambar' => 'https://images.unsplash.com/photo-1485808191679-5f86510681a2?auto=format&fit=crop&w=500&q=80',
                'price' => 24000,
                'modal' => 11000,
                'stock' => 45,
            ],

            // Snack
            [
                'kode_menu' => 'MN-011',
                'nama_menu' => 'Kentang Goreng',
                'kategori' => 'Snack',
                'deskripsi' => 'Kentang goreng renyah (French Fries) dengan saus sambal.',
                'gambar' => 'https://images.unsplash.com/photo-1576107232684-1279f390859f?auto=format&fit=crop&w=500&q=80',
                'price' => 15000,
                'modal' => 6000,
                'stock' => 90,
            ],
            [
                'kode_menu' => 'MN-012',
                'nama_menu' => 'Dimsum Siomay Ayam',
                'kategori' => 'Snack',
                'deskripsi' => 'Dimsum ayam lezat kukus isi 4 potong.',
                'gambar' => 'https://images.unsplash.com/photo-1563245372-f21724e3856d?auto=format&fit=crop&w=500&q=80',
                'price' => 18000,
                'modal' => 10000,
                'stock' => 50,
            ],
            [
                'kode_menu' => 'MN-013',
                'nama_menu' => 'Mendoan Purwokerto',
                'kategori' => 'Snack',
                'deskripsi' => 'Tempe tepung goreng setengah matang khas Purwokerto (Isi 3).',
                'gambar' => 'https://images.unsplash.com/photo-1621379766946-b072da34f4ba?auto=format&fit=crop&w=500&q=80',
                'price' => 12000,
                'modal' => 4000,
                'stock' => 70,
            ],

            // Desert
            [
                'kode_menu' => 'MN-014',
                'nama_menu' => 'Pancake Maple Syrup',
                'kategori' => 'Desert',
                'deskripsi' => '3 Lapis pancake hangat dengan mentega dan sirup maple.',
                'gambar' => 'https://images.unsplash.com/photo-1528207776546-365bb710ee93?auto=format&fit=crop&w=500&q=80',
                'price' => 20000,
                'modal' => 8000,
                'stock' => 40,
            ],
            [
                'kode_menu' => 'MN-015',
                'nama_menu' => 'Es Teler Sultan',
                'kategori' => 'Desert',
                'deskripsi' => 'Campuran alpukat, nangka, kelapa muda dengan susu kental.',
                'gambar' => 'https://images.unsplash.com/photo-1596660634674-325fc04d9095?auto=format&fit=crop&w=500&q=80',
                'price' => 22000,
                'modal' => 12000,
                'stock' => 45,
            ]
        ];

        foreach ($menus as $menuData) {
            $stock = $menuData['stock'];
            unset($menuData['stock']);

            $menu = Menu::create($menuData);

            InventoryBatch::create([
                'menu_id' => $menu->id,
                'qty_purchased' => $stock,
                'qty_remaining' => $stock,
                'modal' => $menu->modal,
                'purchased_at' => Carbon::now(),
            ]);
        }
    }
}
