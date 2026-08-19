# Blueprint Backend API POS F&B

Dokumen ini merupakan kerangka dasar (blueprint) arsitektur Fase 1 untuk RESTful API Aplikasi Point of Sale (POS) Food & Beverage.

## 1. Kerangka Entity Relationship Diagram (ERD)

### `menus` (Mendukung Soft Deletes)
- `id` (PK, BigInt, Unsigned)
- `kode_menu` (String, Unique) - *Kode unik menu*
- `nama_menu` (String) - *Nama makanan/minuman*
- `kategori` (String) - *Kategori (contoh: Makanan, Minuman, Snack)*
- `deskripsi` (Text, Nullable)
- `gambar` (String, Nullable) - *Menyimpan link/URL gambar dari internet*
- `price` (Decimal) - *Harga jual menu saat ini*
- `modal` (Decimal) - *Modal/HPP per satuan*
- `is_active` (Computed) - *Otomatis true jika total_stock > 0*
- `deleted_at` (Timestamp, Nullable) - *Untuk fitur SoftDeletes*
- `created_at`, `updated_at` (Timestamps)

### `inventory_batches` (Inventory / Stok FIFO)
- `id` (PK, BigInt, Unsigned)
- `menu_id` (FK -> `menus.id`)
- `qty_purchased` (Integer) - *Jumlah yang dibeli*
- `qty_remaining` (Integer) - *Sisa stok di batch ini*
- `modal` (Decimal) - *Modal per satuan*
- `purchased_at` (DateTime) - *Tanggal pembelian*
- `created_at`, `updated_at` (Timestamps)

> **Catatan:** Harga jual menu disimpan langsung di kolom `price` pada tabel `menus`. Sistem `price_histories` sudah tidak digunakan.

### `promos` (Manajemen Promo)
- `id` (PK, BigInt, Unsigned)
- `name` (String) - *Nama promo (contoh: Diskon Kemerdekaan)*
- `type` (Enum: 'discount', 'bogo') - *Tipe: Diskon atau Buy 1 Get 1*
- `value` (Decimal, Nullable) - *Nilai diskon (bisa dalam persen atau nominal)*
- `is_percentage` (Boolean, Default: false) - *True jika nilainya persen*
- `max_discount` (Decimal, Nullable) - *Batas maksimal diskon jika memakai persen*
- `min_purchase` (Decimal, Nullable) - *Minimal belanja untuk bisa pakai promo*
- `buy_qty` (Integer, Nullable) - *Untuk BOGO: Syarat jumlah beli*
- `free_qty` (Integer, Nullable) - *Untuk BOGO: Jumlah gratis yang didapat*
- `apply_multiple` (Boolean, Default: false) - *Untuk BOGO: Berlaku kelipatan atau tidak*
- `start_date` (DateTime) - *Tanggal mulai promo*
- `end_date` (DateTime) - *Tanggal berakhir promo*
- `quota` (Integer, Nullable) - *Batas maksimal penggunaan promo*
- `used_quota` (Integer, Default: 0) - *Jumlah promo yang sudah dipakai*
- `is_active` (Boolean, Default: true)
- `created_at`, `updated_at` (Timestamps)

### `transactions` (Transaksi POS Kasir)
- `id` (PK, BigInt, Unsigned)
- `invoice_number` (String, Unique) - *Nomor nota / struk yang unik*
- `subtotal` (Decimal) - *Total harga semua item sebelum diskon*
- `discount_amount` (Decimal, Default: 0) - *Total potongan harga dari promo*
- `total_amount` (Decimal) - *Total akhir yang harus dibayar (subtotal - diskon)*
- `payment_amount` (Decimal) - *Jumlah uang yang dibayarkan pelanggan*
- `change_amount` (Decimal) - *Jumlah kembalian (uang bayar - total akhir)*
- `promo_id` (FK -> `promos.id`, Nullable) - *Promo yang digunakan pada transaksi*
- `user_id` (FK -> `users.id`, Nullable) - *Kasir yang melayani*
- `created_at`, `updated_at` (Timestamps)

### `transaction_items` (Item Transaksi)
- `id` (PK, BigInt, Unsigned)
- `transaction_id` (FK -> `transactions.id`)
- `menu_id` (FK -> `menus.id`)
- `qty` (Integer) - *Jumlah porsi yang dibeli*
- `price` (Decimal) - *Harga item saat transaksi (terkunci, tidak terpengaruh harga master)*
- `subtotal` (Decimal) - *Subtotal per item (qty x price)*
- `created_at`, `updated_at` (Timestamps)

---

## 2. Struktur Folder & Arsitektur

Menggunakan pola **Clean Architecture** (Service Layer Pattern) agar Controllers tetap bersih dan hanya berfokus pada penerimaan HTTP request. Logika bisnis dan perhitungan diletakkan di dalam Services.

```text
app/
├── Http/
│   ├── Controllers/
│   │   └── Api/
│   │       ├── AuthController.php
│   │       ├── InventoryController.php
│   │       ├── KasirController.php
│   │       ├── MenuController.php
│   │       ├── PromoController.php
│   │       ├── ReportController.php
│   │       └── TransactionController.php
│   └── Requests/ (Validasi Input Form — flat structure)
│       ├── CalculateTransactionRequest.php
│       ├── StoreInventoryBatchRequest.php
│       ├── StoreMenuRequest.php
│       ├── StorePromoRequest.php
│       ├── StoreTransactionRequest.php
│       └── UpdateMenuRequest.php
├── Models/
│   ├── InventoryBatch.php
│   ├── Menu.php
│   ├── Promo.php
│   ├── Transaction.php
│   ├── TransactionItem.php
│   └── User.php
└── Services/
    ├── PromoCalculationService.php   (Menangani logika rumit perhitungan Diskon & BOGO)
    └── TransactionService.php        (Menangani proses checkout, pembayaran, potong kuota)
```

---

## 3. Tabel API Endpoints

Semua endpoint memiliki awalan `/api`. Response dikembalikan murni dalam bentuk **JSON**.

| Method | URI | Auth | Deskripsi |
|---|---|---|---|
| **Modul 0: Autentikasi** | | | |
| POST | `/login` | ❌ | Login & dapatkan token. |
| POST | `/logout` | 🔒 | Logout & hapus token saat ini. |
| GET | `/user` | 🔒 | Data user yang sedang login. |
| **Modul 0.5: Manajemen Kasir** | | | |
| GET | `/kasir` | 🔒👑 | Menampilkan semua kasir. |
| POST | `/kasir` | 🔒👑 | Menambah kasir baru. |
| GET | `/kasir/{id}` | 🔒 | Detail kasir (Admin / self). |
| PUT | `/kasir/{id}` | 🔒 | Edit kasir (Admin / self). |
| DELETE | `/kasir/{id}` | 🔒👑 | Hapus akun kasir. |
| **Modul 1: Manajemen Menu** | | | |
| GET | `/categories` | ❌ | Daftar kategori (public). |
| GET | `/menus` | 🔒 | Menampilkan semua menu (beserta total_stock & is_active). |
| POST | `/menus` | 🔒 | Membuat menu baru (kode_menu auto-generate). |
| GET | `/menus/{id}` | 🔒 | Mengambil detail spesifik dari satu menu. |
| PUT | `/menus/{id}` | 🔒 | Mengubah data menu. |
| DELETE | `/menus/{id}` | 🔒 | Soft Delete menu + hapus inventory batch terkait. |
| **Modul 3: Manajemen Promo** | | | |
| GET | `/promos` | 🔒 | Menampilkan semua daftar promo. |
| POST | `/promos` | 🔒 | Membuat promo baru (Tipe Diskon atau BOGO). |
| GET | `/promos/{id}` | 🔒 | Mengambil detail sebuah promo. |
| PUT | `/promos/{id}` | 🔒 | Mengubah data promo. |
| DELETE | `/promos/{id}` | 🔒 | Menghapus promo. |
| **Modul 4: Transaksi POS (Kasir)** | | | |
| POST | `/transactions/calculate` | 🔒 | **Engine Kalkulasi:** Preview total pesanan & diskon tanpa menyimpan (untuk *Live Cart Preview* di Flutter). |
| POST | `/transactions` | 🔒 | **Checkout:** Proses pembayaran, simpan data, potong kuota promo, hitung kembalian, buat invoice. |
| GET | `/transactions/{invoice_number}` | 🔒 | Menampilkan ulang struk transaksi berdasarkan nomor nota. |
| **Modul 5: Laporan** | | | |
| GET | `/reports/sales` | 🔒 | Laporan penjualan (summary, per menu, per kasir, per promo). |
| **Modul 6: Inventory** | | | |
| GET | `/inventory` | 🔒 | Lihat semua inventory batch (summary + detail). |
| GET | `/inventory/{menuId}` | 🔒 | Lihat inventory per menu. |
| POST | `/inventory/add-stock` | 🔒 | Tambah stok (pembelian batch baru). |
| POST | `/inventory/adjust-stock` | 🔒 | Kurangi stok / penyesuaian (FIFO). |

> **Legenda:** ❌ = Public, 🔒 = Auth Required, 👑 = Admin Only

---

## 4. Catatan Penting

- **Soft Delete Menu:** Saat menu dihapus (`DELETE /menus/{id}`), seluruh `inventory_batches` terkait juga dihapus secara manual di controller, karena SoftDeletes tidak memicu `cascadeOnDelete` pada level database.
- **Modul Harga:** Sistem `price_histories` sudah dihapus. Harga jual disimpan langsung di kolom `price` pada tabel `menus`.
- **Kode Menu:** Auto-generate berdasarkan kategori: `MKN-xxx`, `MNM-xxx`, `DSS-xxx`, `COF-xxx`, `OTH-xxx`.
- **is_active:** Computed attribute dari `total_stock > 0`, tidak ada di database.

---

## 5. Update VPS (Linux)

```bash
jika ingin meng update seed baru (php artisan migrate:fresh --seed)
cd /var/www/folder_project/pos-fnb-backend
sudo ./update.sh
```

