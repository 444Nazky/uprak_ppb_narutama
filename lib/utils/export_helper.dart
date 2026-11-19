import 'package:flutter/material.dart';

import '../models/student.dart';
import '../services/pdf_service.dart';

Future<void> exportStudentsPdf(
  BuildContext context,
  List<Student> students, {
  String? filterLabel,
}) async {
  final messenger = ScaffoldMessenger.of(context);
  if (students.isEmpty) {
    messenger.showSnackBar(
      const SnackBar(content: Text('Belum ada data siswa untuk diexport.')),
    );
    return;
  }

  messenger.showSnackBar(
    const SnackBar(
      content: Text('Menyiapkan PDF...'),
      duration: Duration(seconds: 2),
    ),
  );

  try {
    final file = await PdfService.export(
      students,
      filterLabel: filterLabel,
    );
    if (!context.mounted) return;
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('PDF tersimpan: ${file.uri.pathSegments.last}'),
        ),
      );
  } catch (_) {
    if (!context.mounted) return;
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text('Gagal membuat PDF. Coba lagi.'),
        ),
      );
  }
}
