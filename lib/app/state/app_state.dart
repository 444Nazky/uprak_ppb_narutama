import 'package:data_siswa/app/data/session_store.dart';
import 'package:data_siswa/app/data/siswa_repository.dart';
import 'package:data_siswa/app/models/siswa.dart';
import 'package:flutter/material.dart';

/// Sumber kebenaran tunggal untuk sesi, tema, dan daftar siswa.
class AppState extends ChangeNotifier {
  AppState(this._repo, this._sesi);

  /// Akun demo untuk keperluan tugas. Ganti dengan autentikasi server
  /// bila aplikasi dipakai di sekolah sungguhan.
  static const akunDemoUsername = 'admin';
  static const akunDemoPassword = 'admin123';

  final SiswaRepository _repo;
  final SessionStore _sesi;

  List<Siswa> _siswa = const [];
  bool _memuat = true;
  String _pencarian = '';
  String? _filterKelas;
  bool _login = false;
  String _username = '';
  String _nama = 'Administrator';
  ThemeMode _tema = ThemeMode.system;

  List<Siswa> get siswa => _siswa;
  bool get memuat => _memuat;
  bool get sudahLogin => _login;
  String get username => _username;
  String get namaPengguna => _nama;
  ThemeMode get tema => _tema;
  String get pencarian => _pencarian;
  String? get filterKelas => _filterKelas;

  int get totalSiswa => _siswa.length;

  int get totalKelas => kelasTersedia.length;

  List<String> get kelasTersedia {
    final set = <String>{for (final s in _siswa) s.kelas};
    final daftar = set.where((e) => e.isNotEmpty).toList()..sort();
    return daftar;
  }

  /// Daftar yang sudah difilter pencarian dan kelas, dipakai halaman Data Siswa.
  List<Siswa> get siswaTampil {
    final kunci = _pencarian.trim().toLowerCase();
    return _siswa
        .where((s) {
          final cocokKelas = _filterKelas == null || s.kelas == _filterKelas;
          if (!cocokKelas) return false;
          if (kunci.isEmpty) return true;
          return s.nama.toLowerCase().contains(kunci) ||
              s.nis.toLowerCase().contains(kunci) ||
              s.kelas.toLowerCase().contains(kunci);
        })
        .toList(growable: false);
  }

  List<Siswa> get siswaTerbaru {
    final urut = [..._siswa]..sort((a, b) => (b.id ?? 0).compareTo(a.id ?? 0));
    return urut.take(3).toList(growable: false);
  }

  Map<String, int> get jumlahPerKelas {
    final hasil = <String, int>{};
    for (final kelas in kelasTersedia) {
      hasil[kelas] = _siswa.where((s) => s.kelas == kelas).length;
    }
    return hasil;
  }

  String get inisialPengguna {
    final bagian = _nama.trim().split(RegExp(r'\s+'));
    if (bagian.isEmpty || bagian.first.isEmpty) return 'A';
    if (bagian.length == 1) return bagian.first[0].toUpperCase();
    return (bagian.first[0] + bagian[1][0]).toUpperCase();
  }

  Future<void> init() async {
    await _sesi.muat();
    _login = await _sesi.ambilLogin();
    _username = await _sesi.ambilUsername() ?? '';
    _nama = await _sesi.ambilNama() ?? 'Administrator';
    _tema = await _sesi.ambilTema();
    await _repo.init();
    _siswa = await _repo.ambilSemua();
    _memuat = false;
    notifyListeners();
  }

  Future<bool> login(String username, String password) async {
    final cocok =
        username.trim() == akunDemoUsername && password == akunDemoPassword;
    if (!cocok) return false;
    _login = true;
    _username = akunDemoUsername;
    _nama = 'Administrator Sekolah';
    await _sesi.simpanLogin(username: _username, nama: _nama);
    notifyListeners();
    return true;
  }

  Future<void> logout() async {
    _login = false;
    _username = '';
    _nama = 'Administrator';
    await _sesi.hapusLogin();
    notifyListeners();
  }

  Future<void> gantiTema(ThemeMode mode) async {
    _tema = mode;
    await _sesi.simpanTema(mode);
    notifyListeners();
  }

  void cari(String kata) {
    if (_pencarian == kata) return;
    _pencarian = kata;
    notifyListeners();
  }

  void saringKelas(String? kelas) {
    if (_filterKelas == kelas) return;
    _filterKelas = kelas;
    notifyListeners();
  }

  Future<bool> nisDipakai(String nis, {int? kecualiId}) {
    return _repo.nisDipakai(nis.trim(), kecualiId: kecualiId);
  }

  Future<void> muatUlang() async {
    _memuat = true;
    notifyListeners();
    _siswa = await _repo.ambilSemua();
    _memuat = false;
    notifyListeners();
  }

  Future<Siswa> tambahSiswa(Siswa siswa) async {
    final tersimpan = await _repo.tambah(siswa);
    _siswa = [..._siswa, tersimpan]..sort(_urutNama);
    notifyListeners();
    return tersimpan;
  }

  Future<void> ubahSiswa(Siswa siswa) async {
    await _repo.ubah(siswa);
    _siswa = _siswa.map((s) => s.id == siswa.id ? siswa : s).toList()
      ..sort(_urutNama);
    notifyListeners();
  }

  Future<void> hapusSiswa(Siswa siswa) async {
    final id = siswa.id;
    if (id == null) return;
    await _repo.hapus(id);
    _siswa = _siswa.where((s) => s.id != id).toList(growable: false);
    notifyListeners();
  }

  static int _urutNama(Siswa a, Siswa b) =>
      a.nama.toLowerCase().compareTo(b.nama.toLowerCase());
}

/// Menyediakan [AppState] ke seluruh pohon widget.
class AppScope extends InheritedNotifier<AppState> {
  const AppScope({super.key, required AppState state, required super.child})
    : super(notifier: state);

  static AppState of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope tidak ditemukan di atas widget ini.');
    return scope!.notifier!;
  }

  /// Membaca state tanpa ikut membangun ulang saat data berubah.
  static AppState baca(BuildContext context) {
    final scope = context.getInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope tidak ditemukan di atas widget ini.');
    return scope!.notifier!;
  }
}
