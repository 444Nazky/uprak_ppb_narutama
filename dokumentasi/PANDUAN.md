# Panduan Install & Pengujian — Aplikasi Data Siswa

## 1. Menyiapkan APK

File APK: **`apk/DataSiswa.apk`** (54 MB, release build, sudah ditandatangani debug key Flutter).

Persyaratan perangkat:

- Android 7.0 (API 24) atau lebih baru.
- Ruang penyimpanan kosong ± 120 MB (APK + data aplikasi).
- Izin "Instal aplikasi tidak dikenal" aktif untuk aplikasi yang dipakai memasang APK.

## 2. Cara memasang

### A. Langsung di HP (tanpa komputer)

1. Salin `apk/DataSiswa.apk` ke HP (kabel USB, Google Drive, atau chat ke diri sendiri).
2. Buka file manager, ketuk file APK.
3. Jika muncul peringatan, pilih **Setelan → Izinkan dari sumber ini**.
4. Ketuk **Instal** → **Buka**.

### B. Lewat komputer dengan ADB

```bash
adb install -r apk/DataSiswa.apk
adb shell am start -n com.narutama.data_siswa/.MainActivity
```

Untuk memasang ulang dari nol (data contoh kembali seperti awal):

```bash
adb uninstall com.narutama.data_siswa
adb install apk/DataSiswa.apk
```

## 3. Akun demo

| Username | Password |
| -------- | -------- |
| `admin`  | `admin123` |

Kredensial juga ditampilkan di bagian bawah layar login.

## 4. Alur pengujian yang disarankan

| No | Langkah | Hasil yang diharapkan |
| --- | --- | --- |
| 1 | Buka aplikasi, izinkan notifikasi | Muncul layar login "Aplikasi Data Siswa" |
| 2 | Tekan **Login** dengan kolom kosong | Muncul pesan kolom wajib diisi |
| 3 | Isi `admin` / `salah123` lalu Login | Muncul pesan "Username atau password tidak sesuai" |
| 4 | Login `admin` / `admin123` | Masuk ke dashboard, total siswa 6, 2 kelas aktif |
| 5 | Ketuk **Tambah siswa** (kartu atau FAB) | Form tambah terbuka |
| 6 | Isi NIS `241007`, nama, kelas, alamat lalu Simpan | Kembali ke daftar, total siswa bertambah jadi 7 |
| 7 | Ketuk kartu siswa | Form ubah terbuka dengan data terisi |
| 8 | Ubah alamat lalu Simpan | Daftar dan statistik langsung berubah |
| 9 | Ketuk ikon titik tiga → **Hapus** | Dialog konfirmasi muncul, pilih **Batal** data tetap ada |
| 10 | Ulangi Hapus lalu pilih **Hapus** | Data terhapus, total siswa berkurang |
| 11 | Ketik "Kayla" di kolom pencarian | Daftar hanya menampilkan siswa yang cocok |
| 12 | Ketuk chip **XI RPL 1** | Daftar hanya menampilkan siswa kelas tersebut |
| 13 | Dashboard → **Ekspor PDF** | Pratinjau laporan 1 halaman, bisa dibagikan/dicetak |
| 14 | Tutup aplikasi (force close), buka lagi | Tetap login, data terakhir masih ada |
| 15 | Tab **Profil** → aktifkan **Mode gelap** | Seluruh aplikasi berganti tema gelap |
| 16 | Tab **Profil** → **Logout** → konfirmasi | Kembali ke layar login |

Catatan: setelah login, tutup aplikasi lewat recent apps atau force stop; saat dibuka kembali
aplikasi langsung menampilkan dashboard karena sesi disimpan di `shared_preferences`.

## 5. Fitur bonus yang bisa dicoba

- **Foto siswa:** pada form tambah/ubah, ketuk **Tambah foto** → pilih kamera atau galeri.
- **Notifikasi:** setelah menambah, mengubah, atau menghapus data, muncul notifikasi
  "Data siswa diperbarui". Jika notifikasi tidak tampil, aktifkan izin
  **Setelan → Aplikasi → Data Siswa → Notifikasi**.
- **Mode gelap:** pilihan tema tersimpan, jadi tetap gelap setelah aplikasi dibuka ulang.

## 6. Troubleshooting

| Masalah | Penyebab & solusi |
| --- | --- |
| "Aplikasi tidak terpasang" | Versi aplikasi dengan paket sama sudah ada dengan tanda tangan berbeda. Copot dulu aplikasi lama, lalu pasang ulang. |
| "Blokir oleh Play Protect" | Pilih **Instal tetap** / **Tetap instal**; APK ini ditandatangani dengan kunci pengembangan, bukan Play Store. |
| Data tidak muncul setelah instal | Pastikan aplikasi dibuka sekali sampai dashboard, karena data contoh dibuat saat database pertama kali dibuka. |
| Ekspor PDF gagal | Pastikan aplikasi PDF viewer tersedia; laporan disimpan di folder cache aplikasi lalu dibagikan lewat dialog sistem. |
| Lupa akun demo | Gunakan `admin` / `admin123`; akun ini bawaan aplikasi dan tidak bisa diubah. |

## 7. Build ulang dari source

```bash
flutter pub get
flutter test
flutter build apk --release
# hasil: build/app/outputs/flutter-apk/app-release.apk
```

Spesifikasi build: Flutter stable, `compileSdk 37`, `minSdk 24`, `targetSdk 36`,
desugaring 2.1.4, font Plus Jakarta Sans dibundel di `assets/fonts`.

## 8. Lampiran

- `dokumentasi/screenshot/01-login.png` … `11-ekspor-pdf.png`
- `dokumentasi/video/demo-aplikasi-data-siswa.mp4`
