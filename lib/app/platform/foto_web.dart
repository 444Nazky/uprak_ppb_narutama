import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';

/// Di browser tidak ada filesystem, jadi foto disimpan sebagai data URL
/// (base64) bersama data siswa di local storage.
Future<String?> simpanFoto(XFile sumber) async {
  final bytes = await sumber.readAsBytes();
  final nama = sumber.name.toLowerCase();
  final mime = nama.endsWith('.png')
      ? 'image/png'
      : nama.endsWith('.webp')
      ? 'image/webp'
      : nama.endsWith('.gif')
      ? 'image/gif'
      : 'image/jpeg';
  return 'data:$mime;base64,${base64Encode(bytes)}';
}

Future<void> hapusFoto(String? path) async {
  // Tidak ada berkas terpisah yang perlu dihapus di browser.
}

/// Gambar dari data URL, atau null bila tidak ada foto.
ImageProvider? fotoProvider(String? path) {
  if (path == null || !path.startsWith('data:image')) return null;
  final koma = path.indexOf(',');
  if (koma < 0) return null;
  try {
    return MemoryImage(base64Decode(path.substring(koma + 1)));
  } catch (_) {
    return null;
  }
}

/// Browser hanya menyediakan pemilih berkas/galeri, bukan kamera langsung.
const bool fotoDariKamera = false;
