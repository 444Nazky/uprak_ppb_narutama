import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Notifikasi lokal untuk memberi tahu bahwa data siswa berhasil disimpan
/// atau dihapus. Tidak dipakai di luar Android, jadi kegagalan diabaikan.
class NotifikasiService {
  NotifikasiService._();

  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  static bool _siap = false;

  static const _kanal = AndroidNotificationDetails(
    'data_siswa',
    'Data Siswa',
    channelDescription: 'Pemberitahuan perubahan data siswa',
    importance: Importance.defaultImportance,
    priority: Priority.defaultPriority,
  );

  static Future<void> init() async {
    if (kIsWeb) return;
    try {
      await _plugin.initialize(
        settings: const InitializationSettings(
          android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        ),
      );
      await _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
      _siap = true;
    } catch (error, stack) {
      debugPrint('Notifikasi tidak aktif: $error\n$stack');
      _siap = false;
    }
  }

  static Future<void> kirim(String judul, String isi) async {
    if (!_siap || kIsWeb) return;
    try {
      await _plugin.show(
        id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
        title: judul,
        body: isi,
        notificationDetails: const NotificationDetails(android: _kanal),
      );
    } catch (error) {
      debugPrint('Gagal menampilkan notifikasi: $error');
    }
  }
}
