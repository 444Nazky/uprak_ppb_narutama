import 'package:data_siswa/models/siswa.dart';

/// Kontrak penyimpanan data siswa. Implementasi utama memakai SQLite,
/// versi palsu dipakai pada pengujian.
abstract class SiswaRepository {
  Future<void> init();

  Future<List<Siswa>> ambilSemua();

  Future<Siswa> tambah(Siswa siswa);

  Future<void> ubah(Siswa siswa);

  Future<void> hapus(int id);

  Future<bool> nisDipakai(String nis, {int? kecualiId});
}
