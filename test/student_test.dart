import 'package:data_siswa/models/student.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Student', () {
    test('initials memakai dua kata pertama', () {
      final student = Student(
        nis: '2024001',
        name: 'Aditya Pratama',
        kelas: 'XI RPL 1',
        alamat: 'Bogor',
        createdAt: DateTime(2026),
        updatedAt: DateTime(2026),
      );

      expect(student.initials, 'AP');
    });

    test('initials menangani nama satu kata', () {
      final student = Student(
        nis: '2024002',
        name: 'Bunga',
        kelas: 'XI RPL 2',
        alamat: 'Bogor',
        createdAt: DateTime(2026),
        updatedAt: DateTime(2026),
      );

      expect(student.initials, 'BU');
    });

    test('toMap dan fromMap menghasilkan data yang sama', () {
      final createdAt = DateTime(2026, 1, 2, 3, 4, 5);
      final student = Student(
        id: 7,
        nis: '2024003',
        name: 'Citra Ayu',
        kelas: 'XI RPL 1',
        alamat: 'Jl. Sudirman No. 45',
        photoPath: '/tmp/foto.jpg',
        createdAt: createdAt,
        updatedAt: createdAt,
      );

      final restored = Student.fromMap(student.toMap());

      expect(restored.id, 7);
      expect(restored.nis, '2024003');
      expect(restored.name, 'Citra Ayu');
      expect(restored.kelas, 'XI RPL 1');
      expect(restored.alamat, 'Jl. Sudirman No. 45');
      expect(restored.photoPath, '/tmp/foto.jpg');
      expect(restored.createdAt, createdAt);
    });

    test('copyWith clearPhoto menghapus path foto', () {
      final student = Student(
        nis: '2024004',
        name: 'Dimas Saputra',
        kelas: 'XI RPL 2',
        alamat: 'Bogor',
        photoPath: '/tmp/foto.jpg',
        createdAt: DateTime(2026),
        updatedAt: DateTime(2026),
      );

      final updated = student.copyWith(clearPhoto: true);

      expect(updated.photoPath, isNull);
    });
  });
}
