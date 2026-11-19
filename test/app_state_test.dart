import 'package:data_siswa/data/session_store.dart';
import 'package:data_siswa/data/siswa_repository.dart';
import 'package:data_siswa/models/siswa.dart';
import 'package:data_siswa/state/app_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RepoPalsu implements SiswaRepository {
  RepoPalsu(List<Siswa> awal) : _data = [...awal];

  final List<Siswa> _data;
  int _idTerakhir = 100;

  @override
  Future<void> init() async {}

  @override
  Future<List<Siswa>> ambilSemua() async => [..._data];

  @override
  Future<Siswa> tambah(Siswa siswa) async {
    final baru = siswa.copyWith(id: ++_idTerakhir);
    _data.add(baru);
    return baru;
  }

  @override
  Future<void> ubah(Siswa siswa) async {
    final index = _data.indexWhere((s) => s.id == siswa.id);
    if (index >= 0) _data[index] = siswa;
  }

  @override
  Future<void> hapus(int id) async {
    _data.removeWhere((s) => s.id == id);
  }

  @override
  Future<bool> nisDipakai(String nis, {int? kecualiId}) async {
    return _data.any((s) => s.nis == nis && s.id != kecualiId);
  }
}

void main() {
  const contoh = [
    Siswa(id: 1, nis: '241001', nama: 'Adinda Rahmawati', kelas: 'XI RPL 1', alamat: 'Jl. Meranti No. 14'),
    Siswa(id: 2, nis: '241002', nama: 'Bagas Prakoso', kelas: 'XI RPL 2', alamat: 'Jl. Kenanga No. 9'),
    Siswa(id: 3, nis: '241003', nama: 'Kayla Anindya', kelas: 'XI RPL 1', alamat: 'Jl. Cempaka No. 2'),
  ];

  group('model Siswa', () {
    test('bolak balik peta database', () {
      final siswa = Siswa.fromMap(const {
        'id': 7,
        'nis': ' 241009 ',
        'nama': ' Naufal Hidayat ',
        'kelas': 'XI RPL 2',
        'alamat': 'Jl. Pahlawan No. 3',
        'foto_path': null,
      });
      expect(siswa.id, 7);
      expect(siswa.nis, '241009');
      expect(siswa.nama, 'Naufal Hidayat');
      expect(siswa.copyWith(nama: 'Naufal H.').toMap()['nama'], 'Naufal H.');
    });

    test('inisial diambil dari dua kata pertama', () {
      expect(contoh[0].inisial, 'AR');
      expect(
        const Siswa(nis: '1', nama: 'Salsabila', kelas: 'XI RPL 1', alamat: 'Bogor').inisial,
        'S',
      );
    });
  });

  group('AppState', () {
    late RepoPalsu repo;
    late AppState state;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      repo = RepoPalsu(contoh);
      state = AppState(repo, SessionStore());
      await state.init();
    });

    test('memuat data awal dan menghitung kelas', () {
      expect(state.totalSiswa, 3);
      expect(state.totalKelas, 2);
      expect(state.jumlahPerKelas['XI RPL 1'], 2);
      expect(state.memuat, isFalse);
    });

    test('pencarian mencocokkan nama, NIS, dan kelas', () {
      state.cari('bagas');
      expect(state.siswaTampil.map((s) => s.nama), ['Bagas Prakoso']);

      state.cari('241003');
      expect(state.siswaTampil.single.nama, 'Kayla Anindya');

      state.cari('');
      expect(state.siswaTampil.length, 3);
    });

    test('filter kelas digabung dengan pencarian', () {
      state.saringKelas('XI RPL 1');
      expect(state.siswaTampil.length, 2);

      state.cari('kayla');
      expect(state.siswaTampil.single.nis, '241003');
    });

    test('tambah, ubah, dan hapus memperbarui daftar', () async {
      final baru = await state.tambahSiswa(
        const Siswa(nis: '241004', nama: 'Rizky Maulana', kelas: 'XI RPL 2', alamat: 'Bogor'),
      );
      expect(state.totalSiswa, 4);
      expect(await state.nisDipakai('241004'), isTrue);
      expect(await state.nisDipakai('241004', kecualiId: baru.id), isFalse);

      await state.ubahSiswa(baru.copyWith(nama: 'Rizky M.'));
      expect(state.siswa.firstWhere((s) => s.id == baru.id).nama, 'Rizky M.');

      await state.hapusSiswa(baru);
      expect(state.totalSiswa, 3);
    });

    test('login hanya menerima akun demo dan menyimpan sesi', () async {
      expect(await state.login('admin', 'salah'), isFalse);
      expect(state.sudahLogin, isFalse);

      expect(
        await state.login(AppState.akunDemoUsername, AppState.akunDemoPassword),
        isTrue,
      );
      expect(state.sudahLogin, isTrue);
      expect(state.username, 'admin');

      await state.logout();
      expect(state.sudahLogin, isFalse);
    });

    test('pilihan tema tersimpan di penyimpanan lokal', () async {
      expect(state.tema, ThemeMode.system);
      await state.gantiTema(ThemeMode.dark);
      expect(state.tema, ThemeMode.dark);

      final stateBaru = AppState(RepoPalsu(contoh), SessionStore());
      await stateBaru.init();
      expect(stateBaru.tema, ThemeMode.dark);
    });
  });
}
