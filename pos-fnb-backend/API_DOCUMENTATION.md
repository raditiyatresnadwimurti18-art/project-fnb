# 📚 Dokumentasi Lengkap API POS F&B

Gunakan daftar ini sebagai referensi utama saat Anda menguji di Postman atau menghubungkannya dengan aplikasi Flutter Anda.

> **PENTING:** Selalu tambahkan Header `Accept: application/json` pada setiap *request*.
> **Base URL:** `http://127.0.0.1:8000/api`

> [!WARNING]
> Semua endpoint kecuali **Login** dan **Categories** memerlukan autentikasi. Sertakan header:
> ```
> Authorization: Bearer <token>
> ```
> Jika tidak, Anda akan mendapat response `401 Unauthenticated`:
> ```json
> {
>     "message": "Unauthenticated. Silakan login dan masukkan Token di tab Authorization."
> }
> ```

---

## 🔐 Modul 1: Autentikasi & Akun

### 1. Login (Mendapatkan Token)
- **URL:** `POST /login`
- **Auth:** ❌ Tidak perlu
- **Body (JSON):**
  ```json
  {
      "username": "admin123",
      "password": "admin123"
  }
  ```
- **Response Sukses (200):**
  ```json
  {
      "message": "Login successful",
      "access_token": "1|ZcQVYWy2pZwQ9ydDAmIdjUFufTkWj2kpL1qCvcBIc729df84",
      "token_type": "Bearer",
      "user": {
          "id": 2,
          "name": "Administrator",
          "username": "admin123",
          "email": "admin@example.com",
          "email_verified_at": null,
          "role": "admin",
          "created_at": "2026-08-16T05:21:37.000000Z",
          "updated_at": "2026-08-16T05:21:37.000000Z"
      }
  }
  ```
- **Response Gagal (401):**
  ```json
  {
      "message": "Invalid login credentials"
  }
  ```

> [!NOTE]
> Saat login, semua token lama milik user akan dihapus (single-device login). Hanya token terbaru yang aktif.

### 2. Logout (Menghapus Token Saat Ini)
- **URL:** `POST /logout`
- **Auth:** 🔒 Bearer Token
- **Body:** *(Kosong)*
- **Response Sukses (200):**
  ```json
  {
      "message": "Logged out successfully"
  }
  ```

### 3. Lihat Data User Saat Ini
- **URL:** `GET /user`
- **Auth:** 🔒 Bearer Token
- **Response Sukses (200):**
  ```json
  {
      "id": 2,
      "name": "Administrator",
      "username": "admin123",
      "email": "admin@example.com",
      "role": "admin"
  }
  ```

---

## 👥 Modul 2: Manajemen Kasir (Hanya Admin)

> **Catatan Hak Akses:**
> - `index`, `store`, `destroy` → Hanya **Admin**
> - `show`, `update` → Admin boleh semua, Kasir hanya untuk **ID-nya sendiri**

### 4. Lihat Semua Kasir
- **URL:** `GET /kasir`
- **Auth:** 🔒 Bearer Token (Admin)
- **Response Sukses (200):**
  ```json
  {
      "data": [
          {
              "id": 3,
              "name": "Budi Kasir",
              "username": "budikasir",
              "email": "budi@kasir.com",
              "role": "kasir",
              "created_at": "2026-08-15T00:00:00.000000Z",
              "updated_at": "2026-08-15T00:00:00.000000Z"
          }
      ]
  }
  ```

### 5. Tambah Kasir Baru
- **URL:** `POST /kasir`
- **Auth:** 🔒 Bearer Token (Admin)
- **Body (JSON):**
  ```json
  {
      "name": "Budi Kasir",
      "username": "budikasir",
      "email": "budi@kasir.com",
      "password": "password123"
  }
  ```

  | Field      | Type   | Wajib | Keterangan              |
  | ---------- | ------ | ----- | ----------------------- |
  | `name`     | string | ✅    | Nama lengkap            |
  | `username` | string | ✅    | Harus unik              |
  | `email`    | string | ❌    | Opsional, harus unik    |
  | `password` | string | ✅    | Minimal 6 karakter      |

- **Response Sukses (201):**
  ```json
  {
      "message": "Kasir created successfully",
      "data": {
          "id": 3,
          "name": "Budi Kasir",
          "username": "budikasir",
          "email": "budi@kasir.com",
          "role": "kasir",
          "created_at": "2026-08-16T10:00:00.000000Z",
          "updated_at": "2026-08-16T10:00:00.000000Z"
      }
  }
  ```

### 6. Lihat Detail Kasir
- **URL:** `GET /kasir/{id}`
- **Auth:** 🔒 Bearer Token (Admin atau Kasir pemilik ID)
- **Response Sukses (200):**
  ```json
  {
      "data": {
          "id": 3,
          "name": "Budi Kasir",
          "username": "budikasir",
          "email": "budi@kasir.com",
          "role": "kasir"
      }
  }
  ```

### 7. Edit Data Kasir
- **URL:** `PUT /kasir/{id}`
- **Auth:** 🔒 Bearer Token (Admin atau Kasir pemilik ID)
- **Body (JSON):** *(Semua field opsional, kirim yang ingin diubah saja)*
  ```json
  {
      "name": "Budi Kasir Updated",
      "password": "passwordBaru123"
  }
  ```
- **Response Sukses (200):**
  ```json
  {
      "message": "Kasir updated successfully",
      "data": {
          "id": 3,
          "name": "Budi Kasir Updated",
          "username": "budikasir"
      }
  }
  ```

### 8. Hapus Akun Kasir
- **URL:** `DELETE /kasir/{id}`
- **Auth:** 🔒 Bearer Token (Admin)
- **Response Sukses (200):**
  ```json
  {
      "message": "Kasir deleted successfully"
  }
  ```

---

## 🍽️ Modul 3: Menu Management

> **Catatan:** Semua endpoint menu memerlukan autentikasi.

### 9. Lihat Daftar Kategori (Untuk Dropdown)
- **URL:** `GET /categories`
- **Auth:** ❌ Tidak perlu (public)
- **Response Sukses (200):**
  ```json
  {
      "data": [
          { "id": "Makanan", "name": "Makanan" },
          { "id": "Minuman", "name": "Minuman" },
          { "id": "Desert", "name": "Desert" },
          { "id": "Coffee", "name": "Coffee" }
      ]
  }
  ```

### 10. Lihat Semua Menu
- **URL:** `GET /menus`
- **Auth:** 🔒 Bearer Token
- **Response Sukses (200):**
  ```json
  {
      "data": [
          {
              "id": 1,
              "kode_menu": "MKN-001",
              "nama_menu": "Nasi Goreng",
              "kategori": "Makanan",
              "deskripsi": "Nasi goreng spesial",
              "price": "25000.00",
              "gambar": "https://link-gambar.com/nasi-goreng.jpg",
              "modal": "15000.00",
              "deleted_at": null,
              "created_at": "2026-08-16T10:00:00.000000Z",
              "updated_at": "2026-08-16T10:00:00.000000Z",
              "total_stock": 75,
              "is_active": true
          }
      ]
  }
  ```

> [!NOTE]
> - `kode_menu` di-generate otomatis oleh sistem berdasarkan kategori: `MKN-001`, `MNM-001`, `DSS-001`, `COF-001`, `OTH-001`.
> - `total_stock` dan `is_active` adalah **computed attribute** — tidak ada di database, dihitung dari sisa stok inventory.
> - Menu dengan `total_stock = 0` akan otomatis memiliki `is_active = false`.

### 11. Lihat Detail 1 Menu
- **URL:** `GET /menus/{id}`
- **Auth:** 🔒 Bearer Token
- **Response Sukses (200):**
  ```json
  {
      "data": {
          "id": 1,
          "kode_menu": "MKN-001",
          "nama_menu": "Nasi Goreng",
          "kategori": "Makanan",
          "deskripsi": "Nasi goreng spesial",
          "price": "25000.00",
          "gambar": "https://link-gambar.com/nasi-goreng.jpg",
          "modal": "15000.00",
          "deleted_at": null,
          "created_at": "2026-08-16T10:00:00.000000Z",
          "updated_at": "2026-08-16T10:00:00.000000Z",
          "total_stock": 75,
          "is_active": true
      }
  }
  ```

### 12. Tambah Menu Baru
- **URL:** `POST /menus`
- **Auth:** 🔒 Bearer Token
- **Body (JSON):**
  ```json
  {
      "nama_menu": "Nasi Goreng",
      "kategori": "Makanan",
      "deskripsi": "Nasi goreng spesial",
      "modal": 15000,
      "price": 25000,
      "gambar": "https://link-gambar.com/nasi-goreng.jpg"
  }
  ```

  | Field       | Type   | Wajib | Keterangan                     |
  | ----------- | ------ | ----- | ------------------------------ |
  | `nama_menu` | string | ✅    | Nama menu                      |
  | `kategori`  | string | ✅    | Makanan / Minuman / Desert / Coffee |
  | `deskripsi` | string | ❌    | Deskripsi menu                 |
  | `modal`     | number | ✅    | Harga modal per unit           |
  | `price`     | number | ✅    | Harga jual                     |
  | `gambar`    | string | ❌    | URL gambar                     |

> [!IMPORTANT]
> - **Jangan kirim** `kode_menu` — otomatis di-generate oleh sistem.
> - **Jangan kirim** `is_active` — ditentukan otomatis dari stok inventory.

- **Response Sukses (201):**
  ```json
  {
      "message": "Menu created successfully",
      "data": {
          "id": 5,
          "kode_menu": "MKN-001",
          "nama_menu": "Nasi Goreng",
          "kategori": "Makanan",
          "deskripsi": "Nasi goreng spesial",
          "modal": "15000.00",
          "price": "25000.00",
          "gambar": "https://link-gambar.com/nasi-goreng.jpg",
          "total_stock": 0,
          "is_active": false
      }
  }
  ```

### 13. Edit Menu
- **URL:** `PUT /menus/{id}`
- **Auth:** 🔒 Bearer Token
- **Body (JSON):** *(Semua field opsional, kirim yang ingin diubah)*
  ```json
  {
      "nama_menu": "Nasi Goreng Spesial",
      "price": 27000
  }
  ```
- **Response Sukses (200):**
  ```json
  {
      "message": "Menu updated successfully",
      "data": {
          "id": 5,
          "kode_menu": "MKN-001",
          "nama_menu": "Nasi Goreng Spesial",
          "price": "27000.00"
      }
  }
  ```

### 14. Hapus Menu (Soft Delete + Hapus Inventory)
- **URL:** `DELETE /menus/{id}`
- **Auth:** 🔒 Bearer Token
- **Response Sukses (200):**
  ```json
  {
      "message": "Menu deleted successfully"
  }
  ```

> [!NOTE]
> Menu yang dihapus di-soft delete (kolom `deleted_at` diisi). Data tetap tersimpan untuk riwayat transaksi.
> **Seluruh `inventory_batches` terkait menu ini juga akan dihapus secara otomatis**, karena SoftDeletes tidak memicu `cascadeOnDelete` di level database.

---

## 🎟️ Modul 4: Promo Management

> **Catatan:** Semua endpoint promo memerlukan autentikasi.

### 15. Lihat Seluruh Promo
- **URL:** `GET /promos`
- **Auth:** 🔒 Bearer Token
- **Response Sukses (200):**
  ```json
  {
      "data": [
          {
              "id": 1,
              "menu_id": 1,
              "name": "Diskon Spesial Nasi Goreng",
              "type": "discount",
              "value": "15.00",
              "is_percentage": true,
              "max_discount": "10000.00",
              "min_purchase": "50000.00",
              "buy_qty": null,
              "free_qty": null,
              "apply_multiple": false,
              "start_date": "2026-08-15T00:00:00.000000Z",
              "end_date": "2026-08-20T23:59:59.000000Z",
              "quota": 50,
              "used_quota": 3,
              "is_active": true,
              "created_at": "2026-08-16T10:00:00.000000Z",
              "updated_at": "2026-08-16T10:00:00.000000Z"
          }
      ]
  }
  ```

### 16. Lihat Detail 1 Promo
- **URL:** `GET /promos/{id}`
- **Auth:** 🔒 Bearer Token
- **Response Sukses (200):** *(Sama seperti di atas, 1 objek data)*

### 17. Buat Promo Baru
- **URL:** `POST /promos`
- **Auth:** 🔒 Bearer Token
- **Body (JSON) — Contoh Promo Diskon:**
  ```json
  {
      "name": "Diskon Spesial Nasi Goreng",
      "type": "discount",
      "value": 15,
      "is_percentage": true,
      "max_discount": 10000,
      "min_purchase": 50000,
      "start_date": "2026-08-15 00:00:00",
      "end_date": "2026-08-20 23:59:59",
      "quota": 50,
      "menu_id": 1
  }
  ```
- **Body (JSON) — Contoh Promo BOGO (Beli X Gratis Y):**
  ```json
  {
      "name": "Beli 3 Gratis 1 Es Teh",
      "type": "bogo",
      "buy_qty": 3,
      "free_qty": 1,
      "apply_multiple": true,
      "start_date": "2026-08-15 00:00:00",
      "end_date": "2026-08-30 23:59:59",
      "menu_id": 5
  }
  ```

  | Field            | Type    | Wajib                   | Keterangan                                 |
  | ---------------- | ------- | ----------------------- | ------------------------------------------ |
  | `name`           | string  | ✅                       | Nama promo                                 |
  | `type`           | string  | ✅                       | `"discount"` atau `"bogo"`                 |
  | `value`          | number  | ✅ (jika type=discount) | Nilai diskon (nominal atau persen)          |
  | `is_percentage`  | boolean | ❌                       | `true` = persen, `false` = nominal          |
  | `max_discount`   | number  | ❌                       | Batas maksimum diskon (untuk persen)        |
  | `min_purchase`   | number  | ❌                       | Minimum belanja untuk aktivasi              |
  | `buy_qty`        | integer | ✅ (jika type=bogo)     | Jumlah beli minimal                         |
  | `free_qty`       | integer | ✅ (jika type=bogo)     | Jumlah gratis                               |
  | `apply_multiple` | boolean | ❌                       | Berlaku kelipatan (beli 6 = 2x gratis)      |
  | `start_date`     | date    | ✅                       | Tanggal mulai promo                         |
  | `end_date`       | date    | ✅                       | Tanggal selesai (harus ≥ start_date)        |
  | `quota`          | integer | ❌                       | Kuota penggunaan (null = unlimited)          |
  | `is_active`      | boolean | ❌                       | Default: true                                |
  | `menu_id`        | integer | ❌                       | Jika diisi, promo hanya berlaku untuk menu ini |

- **Response Sukses (201):**
  ```json
  {
      "message": "Promo created successfully",
      "data": { "..." }
  }
  ```

### 18. Edit Promo
- **URL:** `PUT /promos/{id}`
- **Auth:** 🔒 Bearer Token
- **Body (JSON):** *(Kirim field yang ingin diubah saja)*
  ```json
  {
      "value": 20,
      "is_active": false
  }
  ```

> [!CAUTION]
> Field `quota` dan `used_quota` **tidak bisa diubah** melalui endpoint ini. Kedua field tersebut dikelola secara otomatis oleh sistem saat transaksi checkout.

- **Response Sukses (200):**
  ```json
  {
      "message": "Promo updated successfully",
      "data": { "..." }
  }
  ```

### 19. Hapus Promo
- **URL:** `DELETE /promos/{id}`
- **Auth:** 🔒 Bearer Token
- **Response Sukses (200):**
  ```json
  {
      "message": "Promo deleted successfully"
  }
  ```

---

## 🧾 Modul 5: Transaksi (Kasir / POS)

> **Catatan Teknis:**
> - Semua endpoint transaksi memerlukan autentikasi.
> - Harga diambil langsung dari kolom `price` pada tabel `menus`.
> - Stok dikurangi secara otomatis dari inventory batch menggunakan metode **FIFO**.
> - Jika stok tidak cukup, checkout akan ditolak (400).

### 20. Kalkulasi Keranjang (Preview)
- **URL:** `POST /transactions/calculate`
- **Auth:** 🔒 Bearer Token
- **Body (JSON):**
  ```json
  {
      "items": [
          { "menu_id": 1, "qty": 2 },
          { "menu_id": 3, "qty": 4 }
      ],
      "promo_id": 1
  }
  ```

  | Field      | Type    | Wajib | Keterangan              |
  | ---------- | ------- | ----- | ----------------------- |
  | `items`    | array   | ✅    | Minimal 1 item          |
  | `items.*.menu_id` | integer | ✅ | ID menu yang dipesan |
  | `items.*.qty`     | integer | ✅ | Jumlah pesanan (min: 1) |
  | `promo_id` | integer | ❌    | ID promo yang digunakan  |

- **Response Sukses (200):**
  ```json
  {
      "data": {
          "subtotal": 130000,
          "discount_amount": 10000,
          "total_amount": 120000,
          "items": [
              {
                  "menu_id": 1,
                  "qty": 2,
                  "price": 25000,
                  "subtotal": 50000,
                  "modal": "15000.00"
              },
              {
                  "menu_id": 3,
                  "qty": 4,
                  "price": 20000,
                  "subtotal": 80000,
                  "modal": "12000.00"
              }
          ],
          "promo_id": 1
      }
  }
  ```
- **Response Gagal — Promo Tidak Memenuhi Syarat (400):**
  ```json
  {
      "message": "Anda belum memenuhi syarat promo. Tambah pesanan Rp 5.000 lagi untuk menggunakan promo ini."
  }
  ```
- **Response Gagal — Promo Tidak Aktif (400):**
  ```json
  {
      "message": "Promo ini sudah tidak aktif."
  }
  ```
- **Response Gagal — Kuota Habis (400):**
  ```json
  {
      "message": "Kuota promo ini sudah habis."
  }
  ```

### 21. Checkout / Simpan Transaksi & Bayar
- **URL:** `POST /transactions`
- **Auth:** 🔒 Bearer Token
- **Body (JSON):**
  ```json
  {
      "items": [
          { "menu_id": 1, "qty": 2 }
      ],
      "promo_id": 1,
      "payment_amount": 150000,
      "payment_method": "QRIS",
      "user_id": 2
  }
  ```

  | Field            | Type    | Wajib | Keterangan                            |
  | ---------------- | ------- | ----- | ------------------------------------- |
  | `items`          | array   | ✅    | Minimal 1 item                         |
  | `items.*.menu_id`| integer | ✅    | ID menu yang dipesan                   |
  | `items.*.qty`    | integer | ✅    | Jumlah pesanan (min: 1)                |
  | `payment_amount` | number  | ✅    | Jumlah pembayaran (harus ≥ total)      |
  | `user_id`        | integer | ✅    | ID kasir yang melayani                 |
  | `promo_id`       | integer | ❌    | ID promo yang digunakan                |
  | `payment_method` | string  | ❌    | Default: `"Cash"` (contoh: `"QRIS"`)  |

- **Response Sukses (201):**
  ```json
  {
      "message": "Transaction successful",
      "data": {
          "id": 1,
          "invoice_number": "INV-20260815-A7BX3K",
          "subtotal": "50000.00",
          "discount_amount": "7500.00",
          "total_amount": "42500.00",
          "payment_amount": "150000.00",
          "change_amount": "107500.00",
          "payment_method": "QRIS",
          "promo_id": 1,
          "user_id": 2,
          "created_at": "2026-08-16T12:00:00.000000Z",
          "updated_at": "2026-08-16T12:00:00.000000Z",
          "items": [
              {
                  "id": 1,
                  "transaction_id": 1,
                  "menu_id": 1,
                  "qty": 2,
                  "price": "25000.00",
                  "modal_saat_ini": "30000.00",
                  "subtotal": "50000.00",
                  "menu": {
                      "id": 1,
                      "kode_menu": "MKN-001",
                      "nama_menu": "Nasi Goreng"
                  }
              }
          ],
          "promo": {
              "id": 1,
              "name": "Diskon Spesial Nasi Goreng"
          },
          "user": {
              "id": 2,
              "name": "Administrator",
              "username": "admin123"
          }
      }
  }
  ```

> [!NOTE]
> - `invoice_number` format: `INV-YYYYMMDD-XXXXXX` (6 karakter acak alfanumerik). Dijamin unik.
> - `modal_saat_ini` pada setiap item menunjukkan **total COGS** (Harga Pokok Penjualan) berdasarkan metode FIFO.
> - Stok inventory otomatis berkurang saat checkout berhasil.
> - Kuota promo (`quota`) otomatis berkurang dan `used_quota` bertambah.

- **Response Gagal — Pembayaran Kurang (400):**
  ```json
  {
      "message": "Payment amount is less than the total amount."
  }
  ```
- **Response Gagal — Stok Tidak Cukup (400):**
  ```json
  {
      "message": "Stok menu Nasi Goreng tidak mencukupi. Kurang 5 porsi."
  }
  ```

### 22. Lihat Detail / Invoice Transaksi
- **URL:** `GET /transactions/{invoice_number}`
- **Auth:** 🔒 Bearer Token
- **Response Sukses (200):**
  ```json
  {
      "data": {
          "id": 1,
          "invoice_number": "INV-20260815-A7BX3K",
          "subtotal": "50000.00",
          "discount_amount": "7500.00",
          "total_amount": "42500.00",
          "payment_amount": "150000.00",
          "change_amount": "107500.00",
          "payment_method": "QRIS",
          "promo_id": 1,
          "user_id": 2,
          "created_at": "2026-08-16T12:00:00.000000Z",
          "items": [
              {
                  "id": 1,
                  "menu_id": 1,
                  "qty": 2,
                  "price": "25000.00",
                  "modal_saat_ini": "30000.00",
                  "subtotal": "50000.00",
                  "menu": {
                      "id": 1,
                      "kode_menu": "MKN-001",
                      "nama_menu": "Nasi Goreng"
                  }
              }
          ],
          "promo": {
              "id": 1,
              "name": "Diskon Spesial Nasi Goreng"
          },
          "user": {
              "id": 2,
              "name": "Administrator",
              "username": "admin123"
          }
      }
  }
  ```

---

## 📊 Modul 6: Laporan & Analisis Data

### 23. Laporan Penjualan (Sales Summary)
- **URL:** `GET /reports/sales`
- **Auth:** 🔒 Bearer Token
- **Query Params (opsional):**

  | Parameter    | Type   | Default    | Keterangan          |
  | ------------ | ------ | ---------- | ------------------- |
  | `start_date` | string | Hari ini   | Format: `YYYY-MM-DD`|
  | `end_date`   | string | Hari ini   | Format: `YYYY-MM-DD`|

- **Contoh:** `GET /reports/sales?start_date=2026-08-01&end_date=2026-08-31`

> [!NOTE]
> Jika tidak mengirim parameter tanggal, laporan hanya menampilkan data **hari ini**.

- **Response Sukses (200):**
  ```json
  {
      "data": {
          "period": {
              "start": "2026-08-01",
              "end": "2026-08-31"
          },
          "summary": {
              "total_transactions": 150,
              "gross_revenue": 7600000,
              "total_discount": 100000,
              "net_revenue": 7500000,
              "total_cogs": 4000000,
              "gross_profit": 3500000,
              "total_inventory_asset": 1500000
          },
          "sales_by_menu": [
              {
                  "menu_id": 1,
                  "menu_name": "Nasi Goreng Spesial",
                  "qty_sold": 50,
                  "gross_revenue": 1250000,
                  "cogs": 750000
              }
          ],
          "promo_analytics": [
              {
                  "promo_id": 2,
                  "promo_name": "Diskon Akhir Pekan",
                  "times_used": 10,
                  "total_discount_given": 100000
              }
          ],
          "sales_by_kasir": [
              {
                  "user_id": 2,
                  "total_transactions": 80,
                  "total_revenue": "4500000",
                  "user": {
                      "id": 2,
                      "name": "Budi Kasir",
                      "username": "budikasir"
                  }
              }
          ]
      }
  }
  ```

  **Penjelasan field `summary`:**

  | Field              | Keterangan                                    |
  | ------------------ | --------------------------------------------- |
  | `total_transactions` | Jumlah transaksi dalam periode              |
  | `gross_revenue`    | Total pendapatan kotor (sebelum diskon)         |
  | `total_discount`   | Total potongan dari promo                       |
  | `net_revenue`      | Pendapatan bersih (`gross_revenue - discount`)  |
  | `total_cogs`       | Total Harga Pokok Penjualan (modal via FIFO)    |
  | `gross_profit`     | Laba Kotor (`net_revenue - total_cogs`)         |
  | `total_inventory_asset` | Total nilai persediaan barang yang belum terjual |

---

## 📦 Modul 7: Inventory (Persediaan / Stok)

Sistem menggunakan metode **FIFO (First In First Out)** untuk perhitungan stok dan modal (HPP / COGS).
Setiap pembelian stok dicatat sebagai *Batch*. Saat checkout, stok dikurangi dari batch terlama terlebih dahulu.

> **Catatan Keamanan:** Semua endpoint inventory memerlukan autentikasi.

### 24. Lihat Semua Inventory Batch
- **URL:** `GET /inventory`
- **Auth:** 🔒 Bearer Token
- **Query Params (opsional):**

  | Parameter     | Type    | Keterangan                             |
  | ------------- | ------- | -------------------------------------- |
  | `menu_id`     | integer | Filter berdasarkan menu tertentu        |
  | `active_only` | boolean | `true` = hanya batch yang masih ada stok|

- **Response Sukses (200):**
  ```json
  {
      "message": "Inventory batches retrieved successfully",
      "summary": [
          {
              "menu_id": 1,
              "menu": {
                  "id": 1,
                  "nama_menu": "Nasi Goreng Spesial",
                  "kategori": "Makanan",
                  "price": "25000.00"
              },
              "total_purchased": 100,
              "total_remaining": 75,
              "avg_modal": 11500.00,
              "batch_count": 3,
              "active_batch_count": 2
          }
      ],
      "batches": [
          {
              "id": 3,
              "menu_id": 1,
              "qty_purchased": 50,
              "qty_remaining": 45,
              "modal": "12000.00",
              "purchased_at": "2026-08-17T12:00:00.000000Z",
              "created_at": "2026-08-17T12:00:00.000000Z",
              "updated_at": "2026-08-17T12:00:00.000000Z",
              "menu": {
                  "id": 1,
                  "nama_menu": "Nasi Goreng Spesial",
                  "kategori": "Makanan",
                  "price": "25000.00"
              }
          }
      ]
  }
  ```

  **Penjelasan field `summary`:**

  | Field                | Keterangan                                            |
  | -------------------- | ----------------------------------------------------- |
  | `total_purchased`    | Total unit yang pernah dibeli untuk menu ini           |
  | `total_remaining`    | Total sisa stok yang tersedia                          |
  | `avg_modal`          | Rata-rata modal tertimbang (weighted average dari batch aktif) |
  | `batch_count`        | Jumlah batch (semua)                                   |
  | `active_batch_count` | Jumlah batch yang masih punya stok                     |

### 25. Lihat Inventory per Menu
- **URL:** `GET /inventory/{menuId}`
- **Auth:** 🔒 Bearer Token
- **Response Sukses (200):**
  ```json
  {
      "message": "Inventory detail retrieved successfully",
      "data": {
          "menu": {
              "id": 1,
              "nama_menu": "Nasi Goreng Spesial",
              "kategori": "Makanan",
              "price": "25000.00"
          },
          "total_purchased": 100,
          "total_remaining": 75,
          "avg_modal": 11500.00,
          "batch_count": 3,
          "active_batch_count": 2,
          "batches": [
              {
                  "id": 3,
                  "menu_id": 1,
                  "qty_purchased": 50,
                  "qty_remaining": 45,
                  "modal": "12000.00",
                  "purchased_at": "2026-08-17T12:00:00.000000Z"
              },
              {
                  "id": 1,
                  "menu_id": 1,
                  "qty_purchased": 50,
                  "qty_remaining": 30,
                  "modal": "10000.00",
                  "purchased_at": "2026-08-15T08:00:00.000000Z"
              }
          ]
      }
  }
  ```

### 26. Tambah Stok (Pembelian Inventory)
- **URL:** `POST /inventory/add-stock`
- **Auth:** 🔒 Bearer Token
- **Body (JSON):**
  ```json
  {
      "menu_id": 1,
      "qty": 50,
      "modal": 12000
  }
  ```

  | Field     | Type    | Wajib | Keterangan                  |
  | --------- | ------- | ----- | --------------------------- |
  | `menu_id` | integer | ✅    | ID menu yang ditambah stok  |
  | `qty`     | integer | ✅    | Jumlah unit dibeli (min: 1) |
  | `modal`   | number  | ✅    | Harga modal **per unit**    |

- **Response Sukses (201):**
  ```json
  {
      "message": "Stock added successfully",
      "data": {
          "id": 4,
          "menu_id": 1,
          "qty_purchased": 50,
          "qty_remaining": 50,
          "modal": "12000.00",
          "purchased_at": "2026-08-17T12:00:00.000000Z",
          "created_at": "2026-08-17T12:00:00.000000Z",
          "updated_at": "2026-08-17T12:00:00.000000Z"
      }
  }
  ```

### 27. Kurangi Stok / Penyesuaian (Adjust Inventory)
- **URL:** `POST /inventory/adjust-stock`
- **Auth:** 🔒 Bearer Token
- **Body (JSON):**
  ```json
  {
      "menu_id": 1,
      "qty": 5
  }
  ```

  | Field     | Type    | Wajib | Keterangan                     |
  | --------- | ------- | ----- | ------------------------------ |
  | `menu_id` | integer | ✅    | ID menu yang dikurangi stok    |
  | `qty`     | integer | ✅    | Jumlah unit dikurangi (min: 1) |

> [!NOTE]
> Digunakan untuk barang rusak, expired, atau penyesuaian stok. Sistem mengurangi dari batch terlama (FIFO). Jika stok tidak mencukupi, **seluruh operasi dibatalkan** (rollback) — tidak ada stok yang terpotong sebagian.

- **Response Sukses (200):**
  ```json
  {
      "message": "Stock adjusted successfully"
  }
  ```
- **Response Gagal — Stok Tidak Cukup (400):**
  ```json
  {
      "message": "Stok total tidak mencukupi untuk dikurangi. Tersedia: 3, dibutuhkan: 5."
  }
  ```

---

## 📋 Ringkasan Endpoint

| #  | Method   | URL                             | Auth | Deskripsi                       |
| -- | -------- | ------------------------------- | ---- | ------------------------------- |
| 1  | `POST`   | `/login`                        | ❌   | Login & dapatkan token          |
| 2  | `POST`   | `/logout`                       | 🔒   | Logout & hapus token            |
| 3  | `GET`    | `/user`                         | 🔒   | Data user saat ini              |
| 4  | `GET`    | `/kasir`                        | 🔒👑 | List semua kasir                |
| 5  | `POST`   | `/kasir`                        | 🔒👑 | Tambah kasir baru               |
| 6  | `GET`    | `/kasir/{id}`                   | 🔒   | Detail kasir                    |
| 7  | `PUT`    | `/kasir/{id}`                   | 🔒   | Edit kasir                      |
| 8  | `DELETE` | `/kasir/{id}`                   | 🔒👑 | Hapus kasir                     |
| 9  | `GET`    | `/categories`                   | ❌   | List kategori menu              |
| 10 | `GET`    | `/menus`                        | 🔒   | List semua menu                 |
| 11 | `GET`    | `/menus/{id}`                   | 🔒   | Detail menu                     |
| 12 | `POST`   | `/menus`                        | 🔒   | Tambah menu baru                |
| 13 | `PUT`    | `/menus/{id}`                   | 🔒   | Edit menu                       |
| 14 | `DELETE` | `/menus/{id}`                   | 🔒   | Hapus menu (soft delete + hapus inventory) |
| 15 | `GET`    | `/promos`                       | 🔒   | List semua promo                |
| 16 | `GET`    | `/promos/{id}`                  | 🔒   | Detail promo                    |
| 17 | `POST`   | `/promos`                       | 🔒   | Tambah promo baru               |
| 18 | `PUT`    | `/promos/{id}`                  | 🔒   | Edit promo                      |
| 19 | `DELETE` | `/promos/{id}`                  | 🔒   | Hapus promo                     |
| 20 | `POST`   | `/transactions/calculate`       | 🔒   | Preview kalkulasi keranjang     |
| 21 | `POST`   | `/transactions`                 | 🔒   | Checkout & bayar                |
| 22 | `GET`    | `/transactions/{invoice}`       | 🔒   | Detail invoice transaksi        |
| 23 | `GET`    | `/reports/sales`                | 🔒   | Laporan penjualan               |
| 24 | `GET`    | `/inventory`                    | 🔒   | List semua inventory batch      |
| 25 | `GET`    | `/inventory/{menuId}`           | 🔒   | Inventory per menu              |
| 26 | `POST`   | `/inventory/add-stock`          | 🔒   | Tambah stok                     |
| 27 | `POST`   | `/inventory/adjust-stock`       | 🔒   | Kurangi stok (adjust)           |

> **Legenda:** ❌ = Public, 🔒 = Auth Required, 👑 = Admin Only
