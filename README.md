# RentStuff - Flutter App

Marketplace mobile berbasis Flutter untuk sewa-menyewa alat hobi.

---

## 🏗️ Struktur Project

```
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
    │   │   ├── repositories/
    │   │   │   └── auth_repository.dart  # Abstract interface
    │   │   └── usecases/              # (implementasikan sesuai kebutuhan)
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

---

## 🚀 Setup & Instalasi

### 1. Clone & Install Dependencies
```bash
flutter pub get
```

### 2. Setup Firebase
```bash
dart pub global activate flutterfire_cli
flutterfire configure
```
Pilih platform Android dan/atau iOS sesuai kebutuhan.

### 3. Generate Kode (json_serializable + riverpod_generator)
```bash
dart run build_runner build --delete-conflicting-outputs
```

### 4. Konfigurasi API URL
Edit `lib/core/constants/app_constants.dart`:
```dart
static const String baseUrl = 'https://YOUR_LARAVEL_API_URL/api';
```

### 5. Jalankan App
```bash
flutter run
```

---

## 🔑 Arsitektur: Clean Architecture + Riverpod

```
UI (Pages/Widgets)
      ↕
Providers (Riverpod Notifiers)
      ↕
Repository Interface (domain)
      ↕
Repository Implementation (data)
      ↕
Remote DataSource (Dio) + Firebase
```

### Pattern yang digunakan:
- **State Management**: Riverpod 2 (`AsyncNotifier`, `StateNotifier`, `Provider`)
- **Navigation**: GoRouter dengan redirect berbasis auth state
- **HTTP**: Dio + interceptor untuk Bearer Token (Laravel Sanctum)
- **Realtime Chat**: Firebase Firestore stream langsung dari Flutter
- **Error Handling**: `Either<Failure, T>` dari package `dartz`
- **Serialization**: `json_serializable` + code generation

---

## 👥 Role & Navigasi

| Role      | Landing Page         | Akses Fitur                                  |
|-----------|---------------------|----------------------------------------------|
| Borrower  | `/borrower`         | Search, detail, booking, orders, chat        |
| Lender    | `/lender`           | Dashboard, add listing, booking management   |
| Admin     | Web App Laravel     | Kategori, verifikasi, dispute, denda         |

---

## 📋 TODO (Langkah Selanjutnya)

- [ ] Implement `ListingRepository` + API datasource
- [ ] Implement `BookingRepository` + submit booking API
- [ ] Upload foto listing ke Laravel Storage / Cloudinary
- [ ] Push notification via Firebase FCM
- [ ] Rating & review dialog setelah sewa selesai
- [ ] Upload bukti pembayaran (transfer manual)
- [ ] Profile page (edit profil, riwayat rating)
- [ ] Dispute submission form
- [ ] Unit test untuk providers dan repositories

---

## 📦 Dependencies Utama

| Package               | Versi   | Fungsi                         |
|-----------------------|---------|--------------------------------|
| flutter_riverpod      | ^2.5.1  | State management               |
| go_router             | ^13.2.0 | Navigation                     |
| dio                   | ^5.4.3  | HTTP Client                    |
| firebase_core         | ^2.31.1 | Firebase setup                 |
| cloud_firestore       | ^4.17.4 | Realtime chat                  |
| firebase_messaging    | ^14.9.3 | Push notification              |
| table_calendar        | ^3.1.2  | Calendar booking picker        |
| flutter_secure_storage| ^9.0.0  | Simpan token dengan aman       |
| dartz                 | ^0.10.1 | Either type untuk error        |
| cached_network_image  | ^3.3.1  | Load gambar dari URL           |
