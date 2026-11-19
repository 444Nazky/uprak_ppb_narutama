import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

abstract final class PhotoService {
  static Future<String> persist(String sourcePath) async {
    final documents = await getApplicationDocumentsDirectory();
    final folder = Directory(p.join(documents.path, 'student_photos'));
    if (!await folder.exists()) {
      await folder.create(recursive: true);
    }
    final extension = p.extension(sourcePath).isEmpty
        ? '.jpg'
        : p.extension(sourcePath).toLowerCase();
    final target = p.join(
      folder.path,
      'siswa_${DateTime.now().millisecondsSinceEpoch}$extension',
    );
    await File(sourcePath).copy(target);
    return target;
  }

  static Future<void> delete(String? path) async {
    if (path == null || path.isEmpty) return;
    try {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (_) {
      // File foto yang gagal dihapus tidak boleh menghentikan alur data.
    }
  }
}
