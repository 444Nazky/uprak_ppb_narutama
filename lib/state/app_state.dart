import 'package:flutter/material.dart';

import '../data/database_helper.dart';
import '../models/student.dart';
import '../services/app_preferences.dart';
import '../services/auth_service.dart';
import '../services/notification_service.dart';
import '../services/photo_service.dart';

class AppState extends ChangeNotifier {
  AppState({
    DatabaseHelper? database,
    AppPreferences? preferences,
    AuthService? auth,
    NotificationService? notifications,
  }) : _database = database ?? DatabaseHelper.instance,
       _preferences = preferences ?? AppPreferences.instance,
       _auth = auth ?? AuthService(),
       _notifications = notifications ?? NotificationService();

  final DatabaseHelper _database;
  final AppPreferences _preferences;
  final AuthService _auth;
  final NotificationService _notifications;

  List<Student> _students = [];
  bool _loading = true;
  bool _authenticated = false;
  String? _username;
  ThemeMode _themeMode = ThemeMode.light;
  bool _notificationsEnabled = true;

  bool get isLoading => _loading;
  bool get isAuthenticated => _authenticated;
  bool get isDarkMode => _themeMode == ThemeMode.dark;
  ThemeMode get themeMode => _themeMode;
  bool get notificationsEnabled => _notificationsEnabled;
  String get displayName => AuthService.displayName;
  String get role => AuthService.role;
  String get username => _username ?? AuthService.usernameLabel;

  List<Student> get students => List<Student>.unmodifiable(_students);
  int get totalStudents => _students.length;

  int get classCount => _students.map((student) => student.kelas).toSet().length;

  int get photoCount =>
      _students.where((student) => student.photoPath != null).length;

  List<String> get classes {
    final values = _students.map((student) => student.kelas).toSet().toList()
      ..sort();
    return values;
  }

  List<Student> get recentStudents {
    final sorted = [..._students]
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sorted;
  }

  Future<void> bootstrap() async {
    try {
      _themeMode = await _preferences.isDarkMode()
          ? ThemeMode.dark
          : ThemeMode.light;
      _notificationsEnabled = await _preferences.notificationsEnabled();
      _username = await _auth.restoreSession();
      _authenticated = _username != null;
      _students = await _database.getStudents();
      await _notifications.init();
    } catch (_) {
      _students = [];
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> login(String username, String password) async {
    final success = await _auth.signIn(username, password);
    if (success) {
      _authenticated = true;
      _username = username.trim().toLowerCase();
      notifyListeners();
    }
    return success;
  }

  Future<void> logout() async {
    await _auth.signOut();
    _authenticated = false;
    _username = null;
    notifyListeners();
  }

  Future<bool> isNisTaken(String nis, {int? excludeId}) {
    return _database.nisExists(nis.trim(), excludeId: excludeId);
  }

  Future<Student> saveStudent({
    Student? existing,
    required String nis,
    required String name,
    required String kelas,
    required String alamat,
    String? photoPath,
    bool clearPhoto = false,
  }) async {
    final now = DateTime.now();
    late Student saved;

    if (existing == null) {
      final student = Student(
        nis: nis.trim(),
        name: name.trim(),
        kelas: kelas,
        alamat: alamat.trim(),
        photoPath: clearPhoto ? null : photoPath,
        createdAt: now,
        updatedAt: now,
      );
      final id = await _database.insertStudent(student);
      saved = student.copyWith(id: id);
    } else {
      final updated = existing.copyWith(
        nis: nis.trim(),
        name: name.trim(),
        kelas: kelas,
        alamat: alamat.trim(),
        photoPath: photoPath,
        clearPhoto: clearPhoto,
        updatedAt: now,
      );
      await _database.updateStudent(updated);
      if (existing.photoPath != null &&
          existing.photoPath != updated.photoPath) {
        await PhotoService.delete(existing.photoPath);
      }
      saved = updated;
    }

    await _reloadStudents();
    if (_notificationsEnabled) {
      await _notifications.showStudentSaved(saved.name);
    }
    notifyListeners();
    return saved;
  }

  Future<void> deleteStudent(Student student) async {
    if (student.id == null) return;
    await _database.deleteStudent(student.id!);
    await PhotoService.delete(student.photoPath);
    await _reloadStudents();
    notifyListeners();
  }

  Future<void> seedSampleData() async {
    if (_students.isNotEmpty) return;
    final now = DateTime.now();
    final samples = <List<String>>[
      ['2024001', 'Aditya Pratama', 'XI RPL 1', 'Jl. Merdeka No. 12, Bogor'],
      ['2024002', 'Bunga Lestari', 'XI RPL 2', 'Jl. Pajajaran No. 8, Bogor'],
      ['2024003', 'Citra Ayu Ningsih', 'XI RPL 1', 'Jl. Sudirman No. 45, Bogor'],
      ['2024004', 'Dimas Saputra', 'XI RPL 2', 'Jl. Raya Tajur No. 21, Bogor'],
      ['2024005', 'Eka Ramadhani', 'XI RPL 1', 'Jl. Cimahpar No. 7, Bogor'],
      ['2024006', 'Fajar Nugroho', 'XI RPL 2', 'Jl. Bogor Baru No. 3, Bogor'],
      ['2024007', 'Gita Permata', 'XI TKJ 1', 'Jl. Pahlawan No. 18, Bogor'],
      ['2024008', 'Hendra Wijaya', 'XI TKJ 2', 'Jl. Ahmad Yani No. 30, Bogor'],
    ];

    for (var index = 0; index < samples.length; index++) {
      final item = samples[index];
      final created = now.subtract(Duration(hours: index * 6));
      await _database.insertStudent(
        Student(
          nis: item[0],
          name: item[1],
          kelas: item[2],
          alamat: item[3],
          createdAt: created,
          updatedAt: created,
        ),
      );
    }

    await _reloadStudents();
    notifyListeners();
  }

  Future<void> setDarkMode(bool value) async {
    _themeMode = value ? ThemeMode.dark : ThemeMode.light;
    await _preferences.setDarkMode(value);
    notifyListeners();
  }

  Future<bool> setNotificationsEnabled(bool value) async {
    var granted = true;
    if (value) {
      granted = await _notifications.requestPermission();
      if (granted) {
        await _notifications.showReminder(
          'Notifikasi aktif. Kamu akan diberi tahu setiap data siswa berubah.',
        );
      }
    }
    _notificationsEnabled = value;
    await _preferences.setNotificationsEnabled(value);
    notifyListeners();
    return granted;
  }

  Future<void> _reloadStudents() async {
    _students = await _database.getStudents();
  }
}
