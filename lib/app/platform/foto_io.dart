import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Foto disalin ke folder dokumen aplikasi agar tidak hilang saat cache
/// sistem dibersihkan.
Future<String?> simpanFoto(XFile sumber) async {
  final dokumen = await getApplicationDocumentsDirectory();
  final folder = Directory(p.join(dokumen.path, 'foto_siswa'));
  if (!await folder.exists()) {
    await folder.create(recursive: true);
  }
  final namaFile =
      'foto_${DateTime.now().microsecondsSinceEpoch}${p.extension(sumber.path)}';
  final tujuan = File(p.join(folder.path, namaFile));
  await sumber.saveTo(tujuan.path);
  return tujuan.path;
}

Future<void> hapusFoto(String? path) async {
  if (path == null || path.isEmpty) return;
  final file = File(path);
  if (await file.exists()) {
    await file.delete();
  }
}

/// Gambar lokal untuk ditampilkan, atau null bila foto tidak ada.
ImageProvider? fotoProvider(String? path) {
  if (path == null || path.isEmpty) return null;
  final file = File(path);
  if (!file.existsSync()) return null;
  return FileImage(file);
}

/// Pada Android foto bisa dipilih dari kamera maupun galeri.
const bool fotoDariKamera = true;
