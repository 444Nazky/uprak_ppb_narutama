import 'dart:convert';

import 'package:data_siswa/app/data/contoh_siswa.dart';
import 'package:data_siswa/app/data/siswa_repository.dart';
import 'package:data_siswa/app/models/siswa.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Penyimpanan data siswa untuk versi web (Chrome). SQLite tidak tersedia di
/// browser, jadi data disimpan sebagai JSON di local storage lewat
/// `shared_preferences`. Data tetap ada setelah tab ditutup.
SiswaRepository buatSiswaRepository() => PrefsSiswaRepository();

class PrefsSiswaRepository implements SiswaRepository {
  static const _kunci = 'siswa_web_v1';

  List<Siswa> _data = const [];
  int _idTerakhir = 0;

  @override
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final teks = prefs.getString(_kunci);
    if (teks == null) {
      var id = 0;
      _data = [for (final siswa in contohSiswa) siswa.copyWith(id: ++id)];
      _idTerakhir = id;
      await _simpan();
      return;
    }
    final daftar = (jsonDecode(teks) as List)
        .map((e) => Siswa.fromMap(Map<String, Object?>.from(e as Map)))
        .toList();
    _data = daftar;
    _idTerakhir = daftar.fold(0, (maks, s) => s.id! > maks ? s.id! : maks);
  }

  Future<void> _simpan() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _kunci,
      jsonEncode([for (final siswa in _data) siswa.toMap()]),
    );
  }

  @override
  Future<List<Siswa>> ambilSemua() async {
    final hasil = [..._data]
      ..sort((a, b) => a.nama.toLowerCase().compareTo(b.nama.toLowerCase()));
    return List.unmodifiable(hasil);
  }

  @override
  Future<Siswa> tambah(Siswa siswa) async {
    final baru = siswa.copyWith(id: ++_idTerakhir);
    _data = [..._data, baru];
    await _simpan();
    return baru;
  }

  @override
  Future<void> ubah(Siswa siswa) async {
    final id = siswa.id;
    if (id == null) {
      throw ArgumentError('Data siswa tanpa id tidak dapat diubah.');
    }
    _data = [for (final s in _data) s.id == id ? siswa : s];
    await _simpan();
  }

  @override
  Future<void> hapus(int id) async {
    _data = [..._data.where((s) => s.id != id)];
    await _simpan();
  }

  @override
  Future<bool> nisDipakai(String nis, {int? kecualiId}) async {
    return _data.any(
      (s) => s.nis.toLowerCase() == nis.toLowerCase() && s.id != kecualiId,
    );
  }
}
