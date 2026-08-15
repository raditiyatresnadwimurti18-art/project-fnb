# Blueprint Aplikasi FNB (Frontend Flutter)

Dokumen ini adalah *blueprint* resmi untuk pengembangan antarmuka (frontend) aplikasi kasir dan manajemen restoran (FNB Project) menggunakan Flutter.

## 1. Arsitektur (Layer-First MVVM)

Aplikasi telah disederhanakan dari *Feature-First* menjadi *Layer-First* agar lebih ringkas dan terfokus pada peran setiap komponen:

```text
lib/
 ┣ core/              # Konfigurasi inti (Router, API config)
 ┣ models/            # Struktur Data & Entity dari JSON API
 ┣ pages/             # Tampilan halaman utama (UI)
 ┣ providers/         # Controller & State Management
 ┣ repositories/      # Pemanggilan HTTP/Network Request ke API
 ┣ widgets/           # Komponen UI independen dan reusable
 ┗ main.dart          # Konfigurasi Tema & Registrasi Provider
```

## 2. Struktur Data (Domain Layer)

Diambil dari API Postman, berikut adalah kontrak data (JSON Schema) yang akan digunakan di sisi Frontend.

### A. Menu Model (`menu_model.dart`)
Digunakan untuk halaman list menu admin dan grid menu kasir.
```json
{
    "kode_menu": "MN-006",
    "nama_menu": "Nasi Merah",
    "kategori": "Makanan",
    "deskripsi": "Nasi Merah khas dengan ayam goreng.",
    "gambar": "https://url-gambar.com/img.jpg",
    "is_active": true,
    "price": 20000
}
```

### B. Promo Model (`promo_model.dart`)
Digunakan untuk form diskon dan perhitungan subtotal di layar Kasir.
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

### C. Transaction Model (`transaction_model.dart`)
Digunakan saat kasir menekan tombol "Checkout".
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

## 3. UI/UX Guideline (Responsive Material 3)

Aplikasi dibangun dengan menggunakan standar **Material Design 3 (Google UI)** yang dirancang 100% responsif agar berjalan sempurna baik di layar Desktop (Tablet/PC) maupun Mobile (Smartphone) tanpa isu *Overflow*.

### A. Desain Sistem & Gaya UI
- **Warna & Tipografi:** Menggunakan `ColorScheme.fromSeed` (Warna utama Biru Google `#1A73E8`) dan font `GoogleFonts.inter`.
- **Bentuk (Shapes):** Menggunakan desain membulat (*rounded corners*) pada `Card`, `Dialog`, dan tombol.
- **Elevation:** Sangat minim bayangan kaku, diganti dengan border halus abu-abu dan warna permukaan (surface) cerah.

### B. Aturan Responsivitas (Desktop & Mobile)
Pengaturan antarmuka otomatis menyesuaikan berdasarkan `MediaQuery` atau `LayoutBuilder` (batas pemisah: lebar 800px atau 600px).

1. **Dashboard Admin (`admin_dashboard_page.dart`)**
   - **Desktop:** Memakai `NavigationRail` di sisi kiri layar. Konten memanjang ke samping.
   - **Mobile:** Memakai `BottomNavigationBar` di bawah layar untuk mencegah *overflow*.
2. **Dashboard Kasir (`pos_dashboard_page.dart`)**
   - **Desktop:** Layar dibagi 2 (Kiri: Grid View Menu, Kanan: Panel Keranjang Fix).
   - **Mobile:** Menampilkan Grid View Menu saja. Daftar pesanan keranjang (Cart) akan dipindahkan menggunakan tombol *Floating Action Button (FAB)* yang membuka *Bottom Sheet* berisikan daftar pesanan.
3. **Form & Dialog (Widgets)**
   - Semua form input akan menggunakan `SingleChildScrollView` dan struktur *Grid* akan menggunakan properti *crossAxisCount* yang reaktif.

## 4. Tahapan Pengembangan

1. **Fase 1:** Implementasi UI statis dengan Data Dummy (Selesai).
2. **Fase 2:** Restrukturisasi Clean Architecture dan Integrasi HTTP dengan Real Backend API (Selesai).
3. **Fase 3 (Saat ini):** Refaktor UI & UX untuk tampilan premium Material 3 yang tahan Overflow di Desktop & Mobile.
4. **Fase 4:** Fitur mencetak struk kasir (*thermal printer*).
