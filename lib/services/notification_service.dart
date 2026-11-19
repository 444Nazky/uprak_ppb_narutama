import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _ready = false;

  Future<void> init() async {
    if (kIsWeb || !(Platform.isAndroid || Platform.isIOS)) return;
    const settings = InitializationSettings(
      android: AndroidInitializationSettings('ic_stat_data_siswa'),
      iOS: DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
    );
    try {
      await _plugin.initialize(settings: settings);
      _ready = true;
    } catch (_) {
      _ready = false;
    }
  }

  Future<bool> requestPermission() async {
    if (!_ready) return false;
    try {
      if (Platform.isAndroid) {
        final android = _plugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();
        return await android?.requestNotificationsPermission() ?? false;
      }
      if (Platform.isIOS) {
        final ios = _plugin
            .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin
            >();
        return await ios?.requestPermissions(alert: true, sound: true) ?? false;
      }
    } catch (_) {
      return false;
    }
    return false;
  }

  Future<void> showStudentSaved(String studentName) async {
    await _show(
      title: 'Data siswa tersimpan',
      body: '$studentName sudah masuk ke daftar siswa.',
      id: 1001,
    );
  }

  Future<void> showReminder(String message) async {
    await _show(
      title: 'Pengingat Data Siswa',
      body: message,
      id: 1002,
    );
  }

  Future<void> _show({
    required String title,
    required String body,
    required int id,
  }) async {
    if (!_ready) return;
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'data_siswa_updates',
        'Pembaruan Data Siswa',
        channelDescription: 'Notifikasi ketika data siswa berubah',
        importance: Importance.high,
        priority: Priority.high,
        icon: 'ic_stat_data_siswa',
      ),
      iOS: DarwinNotificationDetails(),
    );
    try {
      await _plugin.show(
        id: id,
        title: title,
        body: body,
        notificationDetails: details,
      );
    } catch (_) {
      // Notifikasi tidak boleh menghentikan alur utama aplikasi.
    }
  }
}
