import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Menyimpan sesi login dan pilihan tema di penyimpanan lokal.
class SessionStore {
  static const _kLogin = 'sesi_login';
  static const _kUsername = 'sesi_username';
  static const _kTema = 'tema';
  static const _kNama = 'sesi_nama';

  SharedPreferences? _prefs;

  Future<SharedPreferences> get _store async {
    return _prefs ??= await SharedPreferences.getInstance();
  }

  Future<void> muat() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<bool> ambilLogin() async => (await _store).getBool(_kLogin) ?? false;

  Future<String?> ambilUsername() async => (await _store).getString(_kUsername);

  Future<String?> ambilNama() async => (await _store).getString(_kNama);

  Future<ThemeMode> ambilTema() async {
    final nilai = (await _store).getString(_kTema);
    return switch (nilai) {
      'gelap' => ThemeMode.dark,
      'terang' => ThemeMode.light,
      _ => ThemeMode.system,
    };
  }

  Future<void> simpanLogin({required String username, required String nama}) async {
    final store = await _store;
    await store.setBool(_kLogin, true);
    await store.setString(_kUsername, username);
    await store.setString(_kNama, nama);
  }

  Future<void> hapusLogin() async {
    final store = await _store;
    await store.setBool(_kLogin, false);
    await store.remove(_kUsername);
    await store.remove(_kNama);
  }

  Future<void> simpanTema(ThemeMode mode) async {
    final nilai = switch (mode) {
      ThemeMode.dark => 'gelap',
      ThemeMode.light => 'terang',
      ThemeMode.system => 'sistem',
    };
    await (await _store).setString(_kTema, nilai);
  }
}
