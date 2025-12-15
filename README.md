# Cangijoo App

Cangijoo adalah aplikasi Content Management System (CMS) dan Manajemen Inventaris yang dibangun menggunakan Flutter. Aplikasi ini dirancang untuk membantu pengelolaan stok produk, bahan baku, dan supplier dengan mudah dan efisien.

## ✨ Fitur Utama

*   **Autentikasi Pengguna**: Login, Registrasi, dan Reset Password menggunakan Firebase Auth (termasuk Google Sign In).
*   **Dashboard**: Ringkasan status inventaris dan aktivitas terkini.
*   **Manajemen Produk**:
    *   Tambah, Edit, dan Hapus detail produk.
    *   Monitoring stok produk.
*   **Manajemen Bahan Baku**:
    *   Pengelolaan stok bahan baku.
    *   Pencatatan penggunaan dan pembelian bahan baku.
*   **Manajemen Supplier**:
    *   Database supplier untuk produk dan bahan baku.
*   **Laporan**:
    *   Fitur cetak laporan ke PDF/Printing.
*   **UI/UX Modern**: Antarmuka yang responsif dan mudah digunakan (dibangun dengan GetX Pattern).

## 🛠️ Teknologi yang Digunakan

*   **Framework**: [Flutter](https://flutter.dev/)
*   **Language**: Dart
*   **State Management**: [GetX](https://pub.dev/packages/get)
*   **Backend**: [Firebase](https://firebase.google.com/)
    *   Firebase Authentication
    *   Cloud Firestore
*   **Packages Utama**:
    *   `flutter_speed_dial`: Floating action button menu.
    *   `pdf` & `printing`: Pembuatan dan pencetakan dokumen PDF.
    *   `intl`: Format tanggal dan angka.
    *   `shared_preferences`: Penyimpanan data lokal sederhana.
    *   `flutter_svg`: Rendering aset SVG.

## 🚀 Cara Instalasi

Ikuti langkah-langkah berikut untuk menjalankan aplikasi di lokal:

1.  **Clone Repository**

    ```bash
    git clone https://github.com/shilnisid/CangijooApp.git
    cd CangijooApp
    ```

2.  **Install Dependencies**

    Pastikan Anda telah menginstal Flutter SDK.

    ```bash
    flutter pub get
    ```

3.  **Konfigurasi Firebase**

    Aplikasi ini memerlukan konfigurasi Firebase.
    *   Pastikan file `firebase_options.dart` sudah sesuai dengan project Firebase Anda.
    *   Jika belum, konfigurasikan menggunakan `flutterfire configure`.

4.  **Jalankan Aplikasi**

    ```bash
    flutter run
    ```

## 📂 Struktur Project

Project ini menggunakan arsitektur **GetX Pattern**:

```
lib/
├── app/
│   ├── modules/       # Modul fitur (Controller, View, Binding)
│   │   ├── home/
│   │   ├── login/
│   │   ├── produk_detail/
│   │   └── ...
│   └── routes/        # Definisi rute navigasi
├── main.dart          # Entry point aplikasi
└── firebase_options.dart
```




