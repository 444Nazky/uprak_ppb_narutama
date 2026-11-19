import 'dart:io';

import 'package:data_siswa/app/data/siswa_repository.dart';
import 'package:data_siswa/app/models/siswa.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
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
    const contoh = [
      Siswa(
        nis: '241001',
        nama: 'Adinda Rahmawati',
        kelas: 'XI RPL 1',
        alamat: 'Jl. Meranti No. 14, Bogor',
      ),
      Siswa(
        nis: '241002',
        nama: 'Bagas Prakoso',
        kelas: 'XI RPL 2',
        alamat: 'Jl. Kenanga No. 9, Bogor',
      ),
      Siswa(
        nis: '241003',
        nama: 'Kayla Anindya Putri',
        kelas: 'XI RPL 1',
        alamat: 'Perum Griya Asri Blok C2, Cibinong',
      ),
      Siswa(
        nis: '241004',
        nama: 'Naufal Hidayat',
        kelas: 'XI RPL 2',
        alamat: 'Jl. Cempaka Raya No. 8, Bogor',
      ),
      Siswa(
        nis: '241005',
        nama: 'Rizky Maulana',
        kelas: 'XI RPL 1',
        alamat: 'Kp. Cibinong No. 21, Bogor',
      ),
      Siswa(
        nis: '241006',
        nama: 'Salsabila Nur Fadhilah',
        kelas: 'XI RPL 2',
        alamat: 'Jl. Pahlawan No. 3, Bogor',
      ),
    ];
    for (final siswa in contoh) {
      await db.insert('siswa', siswa.toMap());
    }
  }
}

/// Menyalin foto pilihan pengguna ke folder aplikasi agar tidak hilang
/// ketika cache sistem dibersihkan.
class PenyimpananFoto {
  static Future<String> simpan(File sumber) async {
    final dokumen = await getApplicationDocumentsDirectory();
    final folder = Directory(p.join(dokumen.path, 'foto_siswa'));
    if (!await folder.exists()) {
      await folder.create(recursive: true);
    }
    final namaFile =
        'foto_${DateTime.now().microsecondsSinceEpoch}${p.extension(sumber.path)}';
    final tujuan = File(p.join(folder.path, namaFile));
    await sumber.copy(tujuan.path);
    return tujuan.path;
  }

  static Future<void> hapus(String? path) async {
    if (path == null || path.isEmpty) return;
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  }
}
