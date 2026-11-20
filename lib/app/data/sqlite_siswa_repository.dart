import 'package:data_siswa/app/data/contoh_siswa.dart';
import 'package:data_siswa/app/data/siswa_repository.dart';
import 'package:data_siswa/app/models/siswa.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

/// Penyimpanan permanen memakai SQLite. Data tetap ada setelah aplikasi
/// ditutup, karena file database ditulis ke direktori aplikasi.
class SqliteSiswaRepository implements SiswaRepository {
  Database? _db;

  @override
  Future<void> init() async {
    if (_db != null) return;
    final folder = await getDatabasesPath();
    final lokasi = p.join(folder, 'data_siswa.db');
    _db = await openDatabase(
      lokasi,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE siswa (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nis TEXT NOT NULL UNIQUE,
            nama TEXT NOT NULL,
            kelas TEXT NOT NULL,
            alamat TEXT NOT NULL DEFAULT '',
            foto_path TEXT
          )
        ''');
        await _isiContoh(db);
      },
    );
  }

  Database get _database {
    final db = _db;
    if (db == null) {
      throw StateError('Database belum dibuka. Panggil init() lebih dulu.');
    }
    return db;
  }

  @override
  Future<List<Siswa>> ambilSemua() async {
    final rows = await _database.query(
      'siswa',
      orderBy: 'nama COLLATE NOCASE ASC',
    );
    return rows.map(Siswa.fromMap).toList(growable: false);
  }

  @override
  Future<Siswa> tambah(Siswa siswa) async {
    final id = await _database.insert('siswa', siswa.toMap());
    return siswa.copyWith(id: id);
  }

  @override
  Future<void> ubah(Siswa siswa) async {
    final id = siswa.id;
    if (id == null) {
      throw ArgumentError('Data siswa tanpa id tidak dapat diubah.');
    }
    await _database.update(
      'siswa',
      siswa.toMap(),
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<void> hapus(int id) async {
    await _database.delete('siswa', where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<bool> nisDipakai(String nis, {int? kecualiId}) async {
    final rows = await _database.query(
      'siswa',
      columns: ['id'],
      where: kecualiId == null ? 'nis = ?' : 'nis = ? AND id != ?',
      whereArgs: kecualiId == null ? [nis] : [nis, kecualiId],
      limit: 1,
    );
    return rows.isNotEmpty;
  }

  /// Enam data contoh supaya daftar tidak kosong saat aplikasi pertama dibuka.
  /// Data ini bisa dihapus lewat menu hapus seperti data biasa.
  Future<void> _isiContoh(Database db) async {
    for (final siswa in contohSiswa) {
      await db.insert('siswa', siswa.toMap());
    }
  }
}

/// Membuat penyimpanan data siswa sesuai platform yang sedang berjalan.
SiswaRepository buatSiswaRepository() => SqliteSiswaRepository();
