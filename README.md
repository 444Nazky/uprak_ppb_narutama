# Aplikasi Data Siswa

Aplikasi mobile Flutter untuk mengelola data siswa sekolah: login, dashboard statistik,
CRUD data siswa, pencarian, dan profil pengguna. Seluruh data disimpan lokal di perangkat
(SQLite), sehingga tetap ada setelah aplikasi ditutup.

- **Paket aplikasi:** `com.narutama.data_siswa`
- **Versi:** 1.0.0 (versionCode 1)
- **APK siap uji:** [`apk/DataSiswa.apk`](apk/DataSiswa.apk)
- **Panduan install & pengujian:** [`dokumentasi/PANDUAN.md`](dokumentasi/PANDUAN.md)

## Akun demo

| Username | Password |
| -------- | -------- |
| `admin`  | `admin123` |

Saat instalasi pertama, database otomatis diisi 6 data siswa contoh pada kelas XI RPL 1 dan XI RPL 2.

## Fitur wajib

| Fitur | Keterangan |
| --- | --- |
| Login | Validasi kolom kosong dan kredensial salah, sesi tersimpan sampai logout |
| Dashboard | Nama aplikasi, sapaan pengguna, total siswa & kelas real-time, navigasi ke fitur utama |
| Daftar siswa | Menampilkan nama, NIS, kelas, alamat; pencarian nama/NIS/kelas |
| Tambah siswa | Form NIS, nama, kelas, alamat dengan validasi |
| Edit siswa | Form terisi data lama, perubahan langsung memperbarui daftar & statistik |
| Hapus siswa | Wajib lewat dialog konfirmasi (Batal / Hapus) |
| Penyimpanan lokal | SQLite (`sqflite`), data bertahan setelah aplikasi ditutup |
| Profil & logout | Profil pengguna, logout dengan konfirmasi, sesi dihapus |

## Fitur bonus

- Foto siswa (kamera/galeri) dengan penyimpanan file lokal.
- Filter kelas cepat di daftar siswa.
- Ekspor laporan PDF + cetak/bagikan (`pdf` + `printing`).
- Mode gelap dengan pilihan tema yang tersimpan.
- Notifikasi lokal saat data ditambah, diubah, atau dihapus.
- Desain Material 3, font Plus Jakarta Sans, tema terang & gelap.

## Menjalankan dari source

```bash
flutter pub get
flutter run                 # debug di perangkat/emulator
flutter test                # 8 unit test AppState
flutter build apk --release # menghasilkan build/app/outputs/flutter-apk/app-release.apk
```

## Struktur kode

```
lib/main.dart                      # entry point
lib/app/app.dart                   # bootstrap sesi, database, tema, routing login/shell
lib/app/data/                      # repository SQLite & penyimpanan sesi
lib/app/models/siswa.dart          # model data siswa
lib/app/state/app_state.dart       # state login, data siswa, pencarian, filter, tema
lib/app/screens/                   # login, shell (tab + FAB), dashboard, daftar, form, profil
lib/app/services/                  # notifikasi lokal dan pembuatan PDF
lib/app/theme/app_theme.dart       # tema Material 3 terang & gelap
lib/app/widgets/common.dart        # komponen bersama (card, empty state, dialog konfirmasi)
test/app_state_test.dart           # unit test logika aplikasi
```

## Dokumentasi

- `dokumentasi/PANDUAN.md` — cara install APK, alur pengujian, dan troubleshooting.
- `dokumentasi/screenshot/` — 11 tangkapan layar fitur utama.
- `dokumentasi/video/demo-aplikasi-data-siswa.mp4` — video demo alur aplikasi (±2 menit).
