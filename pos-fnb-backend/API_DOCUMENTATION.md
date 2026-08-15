# 📚 Dokumentasi Lengkap API POS F&B

Gunakan daftar ini sebagai referensi utama saat Anda menguji di Postman atau menghubungkannya dengan aplikasi Flutter Anda.

> **PENTING:** Selalu tambahkan Header `Accept: application/json` pada setiap *request*.
> **Base URL:** `http://127.0.0.1:8000/api`

---

## 🍽️ Modul 1: Menu Management

### 1. Lihat Semua Menu
- **URL:** `/menus`
- **Method:** `GET`
- **Body:** *(Kosong)*

### 2. Lihat Detail Satu Menu
- **URL:** `/menus/{id}` *(Contoh: `/menus/1`)*
- **Method:** `GET`
- **Body:** *(Kosong)*

### 3. Tambah Menu Baru
- **URL:** `/menus`
- **Method:** `POST`
- **Body (JSON):**
  ```json
  {
      "kode_menu": "MN-006",
      "nama_menu": "Nasi Kuning",
      "kategori": "Makanan",
      "deskripsi": "Nasi kuning khas dengan ayam goreng.",
      "gambar": "https://images.unsplash.com/photo-1603133872878-684f208fb84b",
      "is_active": true,
      "price": 20000
  }
  ```

### 4. Ubah / Edit Menu
- **URL:** `/menus/{id}` *(Contoh: `/menus/1`)*
- **Method:** `PUT`
- **Body (JSON):** *(Anda cukup mengirim data yang ingin diubah saja)*
  ```json
  {
      "nama_menu": "Nasi Goreng Super Spesial",
      "is_active": false
  }
  ```

### 5. Hapus Menu (Soft Delete)
- **URL:** `/menus/{id}` *(Contoh: `/menus/1`)*
- **Method:** `DELETE`
- **Body:** *(Kosong)*

---

## 💰 Modul 2: Price Management (Harga)

### 6. Lihat Riwayat Harga Menu
- **URL:** `/menus/{menu_id}/prices` *(Contoh: `/menus/1/prices`)*
- **Method:** `GET`
- **Body:** *(Kosong)*

### 7. Ubah Harga Menu (Mencatat Riwayat Baru)
- **URL:** `/menus/{menu_id}/prices` *(Contoh: `/menus/1/prices`)*
- **Method:** `POST`
- **Body (JSON):**
  ```json
  {
      "new_price": 27000,
      "effective_date": "2026-08-15 08:00:00",
      "user_id": 1 
  }
  ```
  *(Catatan: `user_id` opsional)*

---

## 🎟️ Modul 3: Promo Management

### 8. Lihat Semua Promo
- **URL:** `/promos`
- **Method:** `GET`
- **Body:** *(Kosong)*

### 9. Lihat Detail Satu Promo
- **URL:** `/promos/{id}` *(Contoh: `/promos/1`)*
- **Method:** `GET`
- **Body:** *(Kosong)*

### 10. Buat Promo Baru (Tipe: Diskon)
- **URL:** `/promos`
- **Method:** `POST`
- **Body (JSON):**
  ```json
  {
      "name": "Diskon Akhir Pekan",
      "type": "discount",
      "value": 15,
      "is_percentage": true,
      "max_discount": 20000,
      "min_purchase": 100000,
      "start_date": "2026-08-15 00:00:00",
      "end_date": "2026-08-20 23:59:59",
      "quota": 50,
      "is_active": true
  }
  ```

### 11. Buat Promo Baru (Tipe: Buy 1 Get 1 / BOGO)
- **URL:** `/promos`
- **Method:** `POST`
- **Body (JSON):**
  ```json
  {
      "name": "Beli 2 Gratis 1 Minuman",
      "type": "bogo",
      "buy_qty": 2,
      "free_qty": 1,
      "apply_multiple": true,
      "start_date": "2026-08-15 00:00:00",
      "end_date": "2026-08-20 23:59:59",
      "quota": 100,
      "is_active": true
  }
  ```

### 12. Ubah / Edit Promo
- **URL:** `/promos/{id}` *(Contoh: `/promos/1`)*
- **Method:** `PUT`
- **Body (JSON):**
  ```json
  {
      "is_active": false,
      "quota": 200
  }
  ```

### 13. Hapus Promo
- **URL:** `/promos/{id}` *(Contoh: `/promos/1`)*
- **Method:** `DELETE`
- **Body:** *(Kosong)*

---

## 🧾 Modul 4: Transaksi (Kasir)

### 14. Kalkulasi Keranjang (Simulasi Hitung Total & Diskon)
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
  *(Catatan: `promo_id` bersifat opsional, hilangkan jika tidak pakai promo).*

### 15. Checkout / Simpan Transaksi & Bayar
- **URL:** `/transactions`
- **Method:** `POST`
- **Body (JSON):**
  ```json
  {
      "items": [
          { "menu_id": 1, "qty": 2 },
          { "menu_id": 3, "qty": 4 }
      ],
      "promo_id": 1,
      "payment_amount": 150000,
      "user_id": 1
  }
  ```

### 16. Lihat / Cetak Ulang Struk (Invoice)
- **URL:** `/transactions/{invoice_number}` *(Contoh: `/transactions/INV-202608151230-5521`)*
- **Method:** `GET`
- **Body:** *(Kosong)*
