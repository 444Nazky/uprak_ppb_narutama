// Memilih penyimpanan data sesuai platform: SQLite di Android,
// local storage (JSON) saat aplikasi dibuka di browser.
export 'sqlite_siswa_repository.dart'
    if (dart.library.js_interop) 'siswa_repository_web.dart';
