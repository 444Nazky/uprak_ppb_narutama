# Product Requirements Document (PRD)
**Nama Produk:** Aplikasi Data Siswa (Manajemen Data Siswa)  
**Platform:** Android (Mobile)  
**Target Pengguna:** Admin Sekolah / Guru / Staf Tata Usaha (TU)  
**Konteks Proyek:** Asesmen Sumatif Akhir Semester Ganjil 2026-2027 (SMK Plus Pelita Nusantara Bogor - XI RPL 1 & 2)  
**Versi Dokumen:** 1.0  

---

## 1. Ringkasan Eksekutif (Overview)
**Aplikasi Data Siswa** adalah aplikasi berbasis Android yang dirancang untuk mempermudah pengelolaan data administrasi siswa di lingkungan sekolah secara digital. Aplikasi ini menyediakan antarmuka yang modern, bersih, dan mudah digunakan (user-friendly) dengan fungsionalitas utama pengolahan data berbasis **CRUD** (*Create, Read, Update, Delete*) yang tersimpan secara persisten di perangkat lokal maupun cloud.

---

## 2. Tujuan Produk (Objectives)
1. **Digitalisasi Pencatatan:** Menggantikan pencatatan data siswa manual menjadi sistem terstruktur di perangkat mobile.
2. **Efisiensi Pencarian:** Memudahkan pengguna menemukan informasi spesifik siswa (NIS, Nama, Kelas, Alamat) secara cepat.
3. **Integritas & Persistensi Data:** Memastikan data siswa tetap tersimpan aman meskipun aplikasi ditutup atau perangkat dimulai ulang.
4. **Pengalaman Pengguna Optimal:** Menyediakan antarmuka visual yang intuitif (mengacu pada referensi desain UI modern dengan *bottom navigation*, kartu statistik, dan *quick actions*).

---

## 3. Ruang Lingkup & Fitur Utama (Functional Requirements)

### 3.1. Autentikasi Pengguna (Halaman Login)
* **Input Form:** Field teks untuk `Username` dan `Password` (dengan fitur *hide/show password*).
* **Validasi Input:** 
  * Mencegah pengiriman form jika salah satu atau kedua field kosong (menampilkan pesan error/peringatan).
  * Validasi kecocokan kredensial akun (hardcoded default admin atau berbasis database).
* **Navigasi:** Tombol **Login** akan mengarahkan pengguna ke **Halaman Dashboard** jika autentikasi berhasil.

### 3.2. Halaman Dashboard
* **Header & Identitas:** Menampilkan nama aplikasi ("Aplikasi Data Siswa") serta sapaan profil pengguna yang sedang login.
* **Ringkasan Statistik (Cards):** Menampilkan jumlah total data siswa yang terdaftar secara *real-time* (dapat dikembangkan dengan rincian jumlah siswa laki-laki/perempuan atau status administrasi seperti pada referensi UI).
* **Peringatan / Pengumuman (Opsional/Referensi UI):** Kartu informasi cepat (misal: pengingat administrasi atau pengumuman sekolah/Notices).
* **Menu Navigasi:** Akses cepat ke fitur utama melalui *Quick Menu* dan *Bottom Navigation Bar* (Dashboard, Data Siswa, Tambah Data, Profil).

### 3.3. Manajemen Daftar Siswa (Halaman Data Siswa)
* **Tampilan Daftar (List/RecyclerView):** Menampilkan daftar seluruh siswa yang tersimpan dengan desain kartu (*card item*) yang rapi.
* **Informasi per Item:** Setiap baris/kartu menampilkan **Nama Siswa**, **NIS** (Nomor Induk Siswa), **Kelas**, dan **Alamat**.
* **Fitur Pencarian (Search Bar):** Kolom pencarian interaktif di bagian atas untuk memfilter daftar siswa secara *real-time* berdasarkan Nama atau NIS.
* **Aksi Cepat:** Tombol "+ Tambah Siswa" yang mudah diakses serta opsi aksi (Edit/Hapus) pada setiap item siswa.

### 3.4. Tambah Data Siswa (Halaman/Modal Tambah Data)
* **Form Input:**
  * `NIS` (Input numerik, wajib diisi, validasi unik agar tidak duplikat).
  * `Nama Siswa` (Input teks, wajib diisi).
  * `Kelas` (Input teks atau *Dropdown/Spinner* pilihan kelas, wajib diisi).
  * `Alamat` (Input teks multi-baris, wajib diisi).
* **Aksi Simpan:** Tombol **Simpan** untuk memvalidasi kelengkapan form, menyimpan data ke penyimpanan permanen, menampilkan notifikasi sukses (*Toast/Snackbar*), dan kembali ke daftar siswa.

### 3.5. Edit dan Hapus Data Siswa
* **Edit Data:** 
  * Pengguna dapat memilih salah satu data siswa untuk masuk ke mode edit.
  * Form akan terisi otomatis (*pre-filled*) dengan data siswa yang dipilih.
  * Pengguna dapat mengubah data dan menekan tombol **Simpan Perubahan/Update**.
* **Hapus Data:** 
  * Pengguna dapat menekan tombol/ikon **Hapus** pada item atau detail siswa.
  * **Konfirmasi Penghapusan:** Sistem wajib menampilkan dialog konfirmasi (*Alert Dialog*: *"Apakah Anda yakin ingin menghapus data siswa ini?"* dengan opsi **Batal** dan **Hapus**) sebelum data benar-benar dihapus.

### 3.6. Penyimpanan Data (Data Persistence)
* **Teknologi Penyimpanan:** Menggunakan database lokal **SQLite** (atau Room Database / Hive / SharedPreferences / SQLite Flutter) atau cloud **Firebase** (Firestore/Realtime Database).
* **Persistensi:** Seluruh operasi CRUD wajib langsung memperbarui penyimpanan sehingga data tidak hilang ketika aplikasi ditutup paksa (*force close*) atau perangkat di-restart.

### 3.7. Halaman Profil
* **Informasi Pengguna:** Menampilkan detail akun yang sedang login (Foto/Avatar default, Nama Lengkap, Username, Role/Jabatan).
* **Aksi Keluar:** Tombol **Logout** yang akan mengakhiri sesi pengguna (dengan konfirmasi opsional) dan mengarahkan kembali ke **Halaman Login**.

---

## 4. Fitur Pengembangan / Nilai Tambah (Optional / Bonus Features)
Untuk mencapai nilai maksimal (*Sangat Kompeten* 90–100) sesuai tantangan tambahan pada soal:
1. **Foto Profil Siswa & Upload:** Fitur memilih gambar dari galeri/kamera untuk foto profil masing-masing siswa.
2. **Filter Berdasarkan Kelas:** Tombol filter atau *chips* pada halaman Data Siswa untuk menyaring siswa berdasarkan kelas tertentu (misal: XI RPL 1, XI RPL 2).
3. **Export ke PDF:** Fitur mengunduh/mengekspor seluruh daftar data siswa menjadi file dokumen `.pdf`.
4. **Dark Mode:** Opsi tema gelap/terang pada halaman Profil atau Dashboard.
5. **Notifikasi / Pengumuman (Notices):** Halaman tambahan untuk mengelola pengumuman sekolah (sesuai tab *Notices* pada referensi gambar UI).

---

## 5. Kebutuhan Non-Fungsional & Desain (UI/UX Guidelines)
* **Gaya Visual:** Mengadopsi desain minimalis modern (*Clean UI*) dengan latar belakang terang (`#F8FAFC` / putih), kartu dengan sudut membulat (*rounded corners* `12dp–16dp`), dan bayangan halus (*soft elevation*).
* **Palet Warna Utama:** Biru primer (`#1D4ED8` / `#2563EB`) untuk tombol aksi utama dan indikator aktif, serta warna aksen semantik (Merah untuk peringatan/hapus, Hijau untuk status sukses).
* **Responsivitas:** Tata letak harus menyesuaikan berbagai ukuran layar smartphone Android tanpa elemen yang terpotong (*overflow*).
* **Performa:** Aplikasi harus berjalan stabil tanpa *crash* atau *error* saat berpindah halaman maupun memproses data.

---

## 6. Alur Pengguna (User Flow)
1. **Start App** $\rightarrow$ Masuk ke **Halaman Login**.
2. Input `Username` & `Password` $\rightarrow$ Validasi $\rightarrow$ Masuk ke **Halaman Dashboard**.
3. Di **Dashboard**, pengguna melihat total siswa $\rightarrow$ Menekan menu **Data Siswa**.
4. Di **Halaman Data Siswa**, pengguna dapat:
   * Mencari siswa melalui *Search Bar*.
   * Menekan tombol **Tambah Siswa** $\rightarrow$ Isi form $\rightarrow$ **Simpan**.
   * Memilih siswa untuk **Edit Data** $\rightarrow$ Ubah data $\rightarrow$ **Simpan**.
   * Menekan **Hapus** pada siswa $\rightarrow$ Konfirmasi Dialog **Ya** $\rightarrow$ Data terhapus.
5. Pengguna berpindah ke **Halaman Profil** $\rightarrow$ Menekan **Logout** $\rightarrow$ Kembali ke **Halaman Login**.

---

## 7. Kriteria Penerimaan & Deliverables (Sesuai Rubrik Penilaian)
Aplikasi dinyatakan selesai dan siap dikumpulkan apabila memenuhi seluruh kriteria bobot penilaian berikut:
* **UI/UX (15%):** Tampilan menarik, rapi, konsisten, dan mudah digunakan.
* **Login & Validasi (10%):** Form berfungsi dengan validasi input kosong/salah.
* **Dashboard (10%):** Menampilkan nama aplikasi, navigasi jelas, dan jumlah siswa akurat.
* **Tambah Data (15%):** Seluruh field (NIS, Nama, Kelas, Alamat) tersimpan dengan benar.
* **Tampil & Cari Data (15%):** Daftar siswa tampil lengkap dan fitur pencarian berjalan akurat.
* **Edit & Hapus Data (15%):** Perubahan data tersimpan dan penghapusan disertai dialog konfirmasi.
* **Database/Penyimpanan (10%):** Data bersifat persisten saat aplikasi ditutup dan dibuka kembali.
* **Pengujian & Deliverables (10%):**
  * Source code & file proyek lengkap.
  * File instalasi `.apk` yang siap dijalankan tanpa error.
  * Dokumentasi screenshot (Login, Dashboard, Data Siswa, Tambah/Edit Data).
  * Video demonstrasi aplikasi berdurasi 2–3 menit.