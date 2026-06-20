# RentStuff - Aplikasi Marketplace Sewa Alat Hobi (Flutter)

RentStuff adalah aplikasi marketplace mobile berbasis Flutter yang mempertemukan pemilik barang (Lender) dengan penyewa (Borrower) untuk transaksi sewa-menyewa alat hobi dan perlengkapan lainnya secara aman dan transparan.

---

### Role & Navigasi

| Role | Landing Page | Akses Fitur |
| :--- | :---: | :--- |
| `Borrower` | `/borrower` | Search, detail, booking, orders, chat |
| `lender` | `/lender` | Dashboard, add listing, booking management |
| `admin` | `Web App Laravel` | Kategori, verifikasi, dispute, denda |


##  Fitur Utama (Highlight)
- **Sistem Kalender Pemesanan (Booking):** Pemilihan tanggal sewa yang intuitif dengan validasi batas maksimal peminjaman (durasi dibatasi oleh *Lender*).
- **Perhitungan Biaya Otomatis & Transparan:** Kalkulasi total sewa yang otomatis mencakup Diskon Sewa (untuk peminjaman 7+ hari), Ongkos Kirim, dan Deposit Jaminan sebelum checkout.
- **Profil & Skor Kepercayaan (Trust Score):** Halaman profil peminjam menampilkan secara *real-time* jumlah barang yang sedang dipinjam, total riwayat pinjaman, dan Rata-rata Rating dari *Lender*.
- **Real-time Database:** Menggunakan Firebase Firestore untuk sinkronisasi status pesanan dan fitur *Live Chat* antar pengguna.

## Cara Menjalankan Aplikasi
1. Clone repository ini: `git clone https://github.com/username/rentstuff.git`
2. Masuk ke folder proyek: `cd rentstuff`
3. Unduh dependensi: `flutter pub get`
4. Jalankan aplikasi: `flutter run`

---

### Dependencies Utama

| Package | Versi | Fungsi |
| :--- | :---: | :--- |
| `flutter_riverpod` | `^2.5.1` | State management |
| `go_router` | `^13.2.0` | Navigation |
| `dio` | `^5.4.3` | HTTP Client |
| `firebase_core` | `^2.32.0` | Firebase setup |
| `cloud_firestore` | `^4.17.5` | Realtime chat |
| `firebase_messaging` | `^14.9.3` | Push notification |
| `table_calendar` | `^3.1.2` | Calendar booking picker |
| `flutter_secure_storage` | `^9.0.0` | Simpan token dengan aman |
| `dartz` | `^0.10.1` | Either type untuk error |
| `cached_network_image` | `^3.3.1` | Load gambar dari URL |

## Struktur Project (Clean Architecture)

```text
lib/
├── main.dart                          # Entry point
├── core/
│   ├── constants/
│   │   └── app_constants.dart         # Konstanta global (API URL, keys, dll)
│   ├── theme/
│   │   └── app_theme.dart             # Tema & warna aplikasi
│   ├── network/
│   │   └── dio_client.dart            # HTTP client dengan auth interceptor
│   └── utils/
│       ├── failures.dart              # Error types (ServerFailure, dll)
│       └── app_router.dart            # GoRouter navigation
│
└── features/
    ├── auth/
    │   ├── data/
    │   │   ├── datasources/
    │   │   │   └── auth_remote_datasource.dart
    │   │   ├── models/
    │   │   │   └── user_model.dart     # JSON serializable model
    │   │   └── repositories/
    │   │       └── auth_repository_impl.dart
    │   ├── domain/
    │   │   ├── entities/
    │   │   │   └── user_entity.dart    # Pure domain object
    │   │   └── repositories/
    │   │       └── auth_repository.dart  # Abstract interface
    │   │   
    │   └── presentation/
    │       ├── pages/
    │       │   ├── login_page.dart
    │       │   └── register_page.dart
    │       └── providers/
    │           └── auth_provider.dart  # Riverpod AuthNotifier
    │
    ├── borrower/
    │   ├── domain/entities/
    │   │   └── listing_entity.dart     # ListingEntity + BookingEntity
    │   └── presentation/
    │       ├── pages/
    │       │   ├── borrower_home_page.dart   # Home + search + filter
    │       │   ├── listing_detail_page.dart  # Detail barang
    │       │   ├── booking_page.dart         # Calendar picker + konfirmasi
    │       │   └── borrower_orders_page.dart # Daftar pesanan
    │       ├── providers/
    │       │   └── listing_provider.dart     # Filter + listings state
    │       └── widgets/
    │           ├── listing_card.dart         # Kartu barang
    │           └── category_chip.dart        # Chip filter kategori
    │
    ├── lender/
    │   └── presentation/pages/
    │       ├── lender_dashboard_page.dart    # Dashboard + statistik
    │       ├── add_listing_page.dart         # Form tambah/edit barang
    │       └── lender_bookings_page.dart     # Manajemen permintaan booking
    │
    └── chat/
        └── presentation/pages/
            ├── chat_list_page.dart           # Daftar percakapan
            └── chat_room_page.dart           # Chat realtime (Firestore)
```

## Preview Aplikasi (Screenshots)

*Catatan: Berikut adalah antarmuka utama dari aplikasi RentStuff.*

**--Borrower--**

<p align="center">
  <img src="Screenshots/Borrower/Home%20Page_Borrower.png" width="220" />
  <img src="Screenshots/Borrower/History%20Page_Borrower.png" width="220" />
  <img src="Screenshots/Borrower/Chat%20Page_Borrower.png" width="220" />
</p>

<p align="center">
  <img src="Screenshots/Borrower/Profile%20Page_Borrower.png" width="220" />
  <img src="Screenshots/Borrower/Home%20Dark_Borrower.png" width="220" />
  <img src="Screenshots/Borrower/Profile%20Dark_Borrower.png" width="220" />
</p>

<p align="center">
  <img src="Screenshots/Borrower/Product_Borrower.png" width="220" />
  <img src="Screenshots/Borrower/Product%20Dark_Borrower.png" width="220" />
</p>

---

**--Lender--**

