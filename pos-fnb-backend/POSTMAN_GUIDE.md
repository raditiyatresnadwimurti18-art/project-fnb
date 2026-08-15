# 🚀 Panduan Dasar Postman untuk Pemula

Jangan khawatir, kebingungan di awal belajar RESTful API adalah hal yang sangat wajar! Anggap saja Postman adalah "kurir" yang mengantarkan pesan dari Anda (pengguna) ke pelayan restoran (API Laravel Anda), lalu membawa kembali jawabannya.

## 1. Konsep Dasar Method HTTP

Pilih *Method* (Metode) sesuai dengan tujuan apa yang ingin Anda lakukan terhadap data:

- 🟢 **GET** : Digunakan hanya untuk **MENGAMBIL/MELIHAT** data. *(Contoh: Melihat daftar menu)*.
- 🟡 **POST** : Digunakan untuk **MENAMBAHKAN/MENGIRIM** data baru. *(Contoh: Menyimpan menu baru, mengirim data belanjaan)*.
- 🟠 **PUT** (atau **PATCH**) : Digunakan untuk **MENGUBAH/MENGEDIT** data yang sudah ada. *(Contoh: Mengganti nama menu)*.
- 🔴 **DELETE** : Digunakan untuk **MENGHAPUS** data.

> [!IMPORTANT]
> **Aturan Wajib Postman untuk API Laravel:**
> Setiap kali Anda membuat *Request* baru di Postman, selalu buka tab **Headers** dan tambahkan baris berikut agar Laravel tahu kita sedang berkomunikasi menggunakan bahasa API (bukan website biasa):
> - **Key:** `Accept`
> - **Value:** `application/json`

---

## 2. Praktik Langsung dengan API Proyek Anda

Pastikan server Anda sudah menyala (`php artisan serve`). Semua *request* diarahkan ke `http://127.0.0.1:8000/api/...`.

### A. Modul Menu (CRUD)

#### 1. Melihat Semua Menu
- **Method:** `GET`
- **URL:** `http://127.0.0.1:8000/api/menus`
- **Body:** *(Kosongkan saja)*
- **Klik Send!**

#### 2. Menambah Menu Baru
- **Method:** `POST`
- **URL:** `http://127.0.0.1:8000/api/menus`
- **Body:** Buka tab **Body** ➡️ pilih **raw** ➡️ ujung kanan ganti *Text* menjadi **JSON**.
- Ketik (atau *copy-paste*) data berikut:
  ```json
  {
      "kode_menu": "MN-006",
      "nama_menu": "Es Jeruk Peras",
      "kategori": "Minuman",
      "deskripsi": "Jeruk peras murni pakai es.",
      "gambar": "https://images.unsplash.com/photo-1600271886742-f049cd451bba",
      "price": 12000
  }
  ```
- **Klik Send!** *(Anda baru saja menambahkan menu baru!)*

#### 3. Mengubah/Mengedit Menu
Katakanlah kita ingin mengubah nama "Es Jeruk Peras" (yang baru dibuat dengan ID 6) menjadi "Es Jeruk Nipis".
- **Method:** `PUT`
- **URL:** `http://127.0.0.1:8000/api/menus/6` *(Angka 6 adalah ID menunya)*
- **Body:** (Pilih raw -> JSON)
  ```json
  {
      "nama_menu": "Es Jeruk Nipis"
  }
  ```
- **Klik Send!**

#### 4. Menghapus Menu
- **Method:** `DELETE`
- **URL:** `http://127.0.0.1:8000/api/menus/6`
- **Body:** *(Kosongkan saja)*
- **Klik Send!**

---

### B. Modul Transaksi Kasir (Kalkulator & Pembayaran)

#### 1. Simulasi Hitung Diskon (Kalkulator Cart)
Misalkan pelanggan ingin beli "Nasi Goreng" (ID:1) sebanyak 2 porsi, dan "Kopi" (ID:4) sebanyak 1 porsi, lalu menggunakan Promo "Diskon 20%" (ID:1).
- **Method:** `POST`
- **URL:** `http://127.0.0.1:8000/api/transactions/calculate`
- **Body:** (Pilih raw -> JSON)
  ```json
  {
      "items": [
          { "menu_id": 1, "qty": 2 },
          { "menu_id": 4, "qty": 1 }
      ],
      "promo_id": 1
  }
  ```
- **Klik Send!** *(API tidak akan menyimpan transaksi, hanya mengembalikan JSON total harga dan potongan diskonnya agar bisa ditampilkan di layar HP kasir).*

#### 2. Checkout / Bayar
Pelanggan jadi beli dan membayar dengan uang Rp 100.000.
- **Method:** `POST`
- **URL:** `http://127.0.0.1:8000/api/transactions`
- **Body:** (Pilih raw -> JSON)
  ```json
  {
      "items": [
          { "menu_id": 1, "qty": 2 },
          { "menu_id": 4, "qty": 1 }
      ],
      "promo_id": 1,
      "payment_amount": 100000
  }
  ```
- **Klik Send!** *(API akan menyimpan transaksi ke database, memotong kuota promo, menghitung kembalian, dan membuat Nomor Nota (Invoice)).*

---
> [!TIP]
> **Tips Praktis:** Setiap kali aplikasi Flutter Anda ingin **menyimpan/memproses data**, Flutter akan mengirimkan HTTP Request berbentuk `POST` atau `PUT` dengan sisipan *Body* (payload) berformat JSON seperti contoh di atas. Jika hanya ingin **membaca data** untuk ditampilkan di layar, Flutter akan menggunakan `GET`.
