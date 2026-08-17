# 📚 Dokumentasi Lengkap API POS F&B

Gunakan daftar ini sebagai referensi utama saat Anda menguji di Postman atau menghubungkannya dengan aplikasi Flutter Anda.

> **PENTING:** Selalu tambahkan Header `Accept: application/json` pada setiap *request*.
> **Base URL:** `http://127.0.0.1:8000/api`
> **Base URL Online** `https://potato-das-random-annual.trycloudflare.com/api`
---

## 🔐 Modul 0: Autentikasi & Akun

### 1. Login (Mendapatkan Token)
- **URL:** `/login`
- **Method:** `POST`
- **Body (JSON):**
  ```json
  {
      "username": "admin123",
      "password": "admin123"
  }
  ```
- **Response (Sukses):**
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

### 2. Logout (Menghapus Token Saat Ini)
- **URL:** `/logout`
- **Method:** `POST`
- **Header:** `Authorization: Bearer <token>`
- **Body:** *(Kosong)*
- **Response (Sukses):**
  ```json
  {
      "message": "Logged out successfully"
  }
  ```

---

## 👥 Modul 0.5: Manajemen Kasir (Hanya Admin)

> **Catatan:** Semua endpoint di bawah ini membutuhkan login dengan akun yang memiliki `role` = `admin`.

### 3. Lihat Semua Kasir
- **URL:** `/kasir`
- **Method:** `GET`
- **Header:** `Authorization: Bearer <admin_token>`
- **Response (Sukses):**
  ```json
  {
      "data": [
          {
              "id": 3,
              "name": "Budi Kasir",
              "username": "budikasir",
              "email": "budi@kasir.com",
              "role": "kasir",
              "created_at": "2026-08-15T00:00:00.000000Z"
          }
      ]
  }
  ```

### 4. Tambah Kasir Baru
- **URL:** `/kasir`
- **Method:** `POST`
- **Header:** `Authorization: Bearer <admin_token>`
- **Body (JSON):**
  ```json
  {
      "name": "Budi Kasir",
      "username": "budikasir",
      "email": "budi@kasir.com",
      "password": "password123"
  }
  ```
- **Response (Sukses 201 Created):**
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

### 5. Lihat Detail Kasir
- **URL:** `/kasir/{id}`
- **Method:** `GET`
- **Header:** `Authorization: Bearer <token_admin_atau_kasir>` *(Kasir hanya bisa melihat ID-nya sendiri)*
- **Response (Sukses):**
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

### 6. Edit Data Kasir
- **URL:** `/kasir/{id}`
- **Method:** `PUT`
- **Header:** `Authorization: Bearer <token_admin_atau_kasir>` *(Kasir hanya bisa mengubah ID-nya sendiri)*
- **Body (JSON):** 
  *(Semua field bersifat opsional, hanya kirim yang ingin diubah)*
  ```json
  {
      "name": "Budi Kasir Updated",
      "username": "budikasir",
      "email": "budi_baru@kasir.com",
      "password": "passwordBaru123"
  }
  ```
- **Response (Sukses):**
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

### 7. Hapus Akun Kasir
- **URL:** `/kasir/{id}`
- **Method:** `DELETE`
- **Response (Sukses):**
  ```json
  {
      "message": "Kasir deleted successfully"
  }
  ```

---

## 🍽️ Modul 1: Menu Management

### 8. Lihat Semua Menu
- **URL:** `/menus`
- **Method:** `GET`
- **Response (Sukses):**
  ```json
  {
      "data": [
          {
              "id": 5,
              "kode_menu": "mk1",
              "nama_menu": "Nasi Goreng",
              "kategori": "Makanan",
              "modal": "15000.00",
              "price": "25000.00",
              "gambar": "menus/image_name.jpg"
          }
      ]
  }
  ```

### 8.5 Lihat Detail 1 Menu
- **URL:** `/menus/{id}`
- **Method:** `GET`
- **Response (Sukses):**
  ```json
  {
      "data": {
          "id": 5,
          "kode_menu": "mk1",
          "nama_menu": "Nasi Goreng",
          "kategori": "Makanan",
          "modal": "15000.00",
          "price": "25000.00",
          "gambar": "menus/image_name.jpg"
      }
  }
  ```

### 9. Lihat Daftar Kategori (Untuk Dropdown Frontend)
- **URL:** `/categories`
- **Method:** `GET`
- **Response (Sukses):**
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

### 10. Tambah Menu Baru (Dengan Upload File Gambar)
- **URL:** `/menus`
- **Method:** `POST`
- **Header:** `Content-Type: multipart/form-data`
- **Body (Format JSON - *Catatan: Wajib gunakan tab form-data jika ingin meng-upload gambar*):**
  ```json
  {
      "nama_menu": "Nasi Goreng",
      "kategori": "Makanan",
      "deskripsi": "Nasi goreng spesial",
      "modal": 15000,
      "price": 25000,
      "is_active": 1,
      "gambar": "LinkUrl"
  }
  ```
- **Response (Sukses 201 Created):**
  ```json
  {
      "data": {
          "id": 5,
          "kode_menu": "mk1",
          "nama_menu": "Nasi Goreng",
          "kategori": "Makanan",
          "modal": "15000.00",
          "gambar": "LinkUrl"
      }
  }
  ```
  *(Catatan: `kode_menu` tidak perlu dikirim karena akan di-generate otomatis oleh sistem)*

### 11. Ubah / Edit Menu
- **URL:** `/menus/{id}`
- **Method:** `PUT`
- **Body (Format JSON):**
  ```json
  {
      "nama_menu": "Nasi Goreng Spesial",
      "kategori": "Makanan",
      "deskripsi": "Nasi goreng ekstra telur",
      "modal": 16000,
      "price": 27000,
      "is_active": 1,
      "gambar": "LinkUrl"
  }
  ```
- **Response (Sukses):**
  ```json
  {
      "data": {
          "id": 5,
          "kode_menu": "mk1",
          "nama_menu": "Nasi Goreng Spesial",
          "kategori": "Makanan",
          "modal": "16000.00",
          "gambar": "LinkUrl"
      }
  }
  ```

### 12. Hapus Menu
- **URL:** `/menus/{id}`
- **Method:** `DELETE`
- **Response (Sukses):**
  ```json
  {
      "message": "Menu deleted successfully"
  }
  ```

---

## 💰 Modul 2: Price Management (Riwayat Harga)

### 13. Lihat Riwayat Harga Menu
- **URL:** `/menus/{menu_id}/prices`
- **Method:** `GET`
- **Response (Sukses):**
  ```json
  {
      "data": [
          {
              "id": 1,
              "menu_id": 1,
              "old_price": "20000.00",
              "new_price": "25000.00",
              "effective_date": "2026-08-01 00:00:00"
          }
      ]
  }
  ```

### 13. Tambah Riwayat / Ubah Harga Menu
- **URL:** `/menus/{menu_id}/prices`
- **Method:** `POST`
- **Body (JSON):**
  ```json
  {
      "new_price": 27000,
      "effective_date": "2026-08-15 08:00:00"
  }
  ```
- **Response (Sukses 201 Created):**
  ```json
  {
      "message": "Price updated successfully",
      "data": {
          "id": 10,
          "menu_id": 1,
          "old_price": "25000.00",
          "new_price": "27000.00",
          "effective_date": "2026-08-15 08:00:00"
      }
  }
  ```

---

## 🎟️ Modul 3: Promo Management

### 14. Lihat Seluruh Promo
- **URL:** `/promos`
- **Method:** `GET`
- **Response (Sukses):**
  ```json
  {
      "data": [
          {
              "id": 1,
              "name": "Diskon Spesial Nasi Goreng",
              "type": "discount",
              "value": "15.00",
              "is_percentage": 1,
              "min_purchase": "50000.00",
              "start_date": "2026-08-15 00:00:00",
              "end_date": "2026-08-20 23:59:59",
              "menu_id": 1 
          }
      ]
  }
  ```

### 15. Lihat Detail 1 Promo
- **URL:** `/promos/{id}`
- **Method:** `GET`
- **Response (Sukses):**
  *(Sama seperti di atas, tapi hanya 1 objek data)*

### 16. Buat Promo Baru (Bisa Spesifik per Item)
- **URL:** `/promos`
- **Method:** `POST`
- **Body (JSON):**
  ```json
  {
      "name": "Diskon Spesial Nasi Goreng",
      "type": "discount",
      "value": 15,
      "is_percentage": true,
      "min_purchase": 50000,
      "start_date": "2026-08-15 00:00:00",
      "end_date": "2026-08-20 23:59:59",
      "menu_id": 1 
  }
  ```
  *(Catatan: Field `menu_id` opsional. Jika diisi ID menu, maka promo diskon/BOGO HANYA akan berlaku untuk item menu tersebut saat dikalkulasi di kasir).*
- **Response (Sukses 201 Created):**
  *(Data promo yang baru dibuat akan dikembalikan)*

### 17. Ubah / Edit Promo
- **URL:** `/promos/{id}`
- **Method:** `PUT`
- **Body (JSON):** *(Kirimkan data yang ingin diubah saja)*
  ```json
  {
      "value": 20
  }
  ```
- **Response (Sukses):**
  *(Data promo yang sudah di-update akan dikembalikan)*

### 18. Hapus Promo
- **URL:** `/promos/{id}`
- **Method:** `DELETE`
- **Response (Sukses):**
  ```json
  {
      "message": "Promo deleted successfully"
  }
  ```

---

## 🧾 Modul 4: Transaksi (Kasir)

### 19. Kalkulasi Keranjang
- **URL:** `/transactions/calculate`
- **Method:** `POST`
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
- **Response (Sukses):**
  ```json
  {
      "subtotal": 50000,
      "discount_amount": 10000,
      "total_amount": 40000,
      "items": [
          {
              "menu_id": 1,
              "qty": 2,
              "price": 25000,
              "subtotal": 50000,
              "modal": "15000.00"
          }
      ],
      "promo_id": 1
  }
  ```

### 20. Checkout / Simpan Transaksi & Bayar
- **URL:** `/transactions`
- **Method:** `POST`
- **Header:** `Authorization: Bearer <token_kasir>` *(ID Kasir akan otomatis tercatat dari token ini)*
- **Body (JSON):**
  ```json
  {
      "items": [
          { "menu_id": 1, "qty": 2 }
      ],
      "promo_id": 1,
      "payment_amount": 150000,
      "payment_method": "QRIS"
  }
  ```
  *(Catatan: Field `payment_method` bersifat opsional, defaultnya "Cash")*
- **Response (Sukses):**
  ```json
  {
      "message": "Checkout successful",
      "transaction": {
          "id": 1,
          "invoice_number": "INV-202608151230-5521",
          "total_amount": "40000.00",
          "payment_amount": "150000.00",
          "change_amount": "110000.00",
          "payment_method": "QRIS",
          "user_id": 2,
          "created_at": "2026-08-16T12:00:00.000000Z"
      }
  }
  ```

### 21. Lihat Detail / Invoice Transaksi
- **URL:** `/transactions/{invoice_number}`
- **Method:** `GET`
- **Response (Sukses):**
  ```json
  {
      "data": {
          "invoice_number": "INV-202608151230-5521",
          "total_amount": "40000.00",
          "items": [
              {
                  "menu_id": 1,
                  "qty": 2,
                  "price": "25000.00",
                  "subtotal": "50000.00"
              }
          ]
      }
  }
  ```

---

## 📊 Modul 5: Laporan & Analisis Data (History Perdagangan)

### 22. Laporan Penjualan (Harian & Kasir)
- **URL:** `/reports/sales?start_date=2026-08-01&end_date=2026-08-31`
- **Method:** `GET`
- **Header:** `Authorization: Bearer <token_admin>` *(Wajib disertakan untuk menghindari error 401 Unauthorized)*
- **Deskripsi:** Menghasilkan rangkuman jumlah transaksi, pendapatan kotor (Revenue), Total Modal (COGS), dan Laba Kotor (Gross Profit), serta rekap pendapatan yang dihasilkan oleh masing-masing kasir.
  - **Parameter Opsional:** Anda bisa secara dinamis menambahkan `?start_date=YYYY-MM-DD&end_date=YYYY-MM-DD` di ujung URL untuk memilih rentang waktu tertentu (misal: satu bulan, satu tahun, atau satu minggu).
  - **Default:** Jika Anda tidak mengirimkan parameter tanggal sama sekali (hanya memanggil `/reports/sales`), maka *Backend* secara otomatis akan merangkum **data penjualan khusus untuk HARI INI saja**.
- **Response (Sukses):**
  ```json
  {
      "data": {
          "period": {
              "start": "2026-08-01",
              "end": "2026-08-31"
          },
          "summary": {
              "total_transactions": 150,
              "total_revenue": 7500000,
              "total_cogs": 4000000,
              "gross_profit": 3500000
          },
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
