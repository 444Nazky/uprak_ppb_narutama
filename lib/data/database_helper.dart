import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../models/student.dart';

class DatabaseHelper {
  DatabaseHelper._();

  static final DatabaseHelper instance = DatabaseHelper._();

  static const _databaseName = 'data_siswa.db';
  static const _databaseVersion = 1;
  static const _table = 'students';

  Database? _database;

  Future<Database> get database async {
    return _database ??= await _openDatabase();
  }

  Future<Database> _openDatabase() async {
    final directory = await getDatabasesPath();
    return openDatabase(
      p.join(directory, _databaseName),
      version: _databaseVersion,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $_table (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nis TEXT NOT NULL UNIQUE,
            name TEXT NOT NULL,
            kelas TEXT NOT NULL,
            alamat TEXT NOT NULL,
            photo_path TEXT,
            created_at TEXT NOT NULL,
            updated_at TEXT NOT NULL
          )
        ''');
      },
    );
  }

  Future<List<Student>> getStudents() async {
    final db = await database;
    final rows = await db.query(
      _table,
      orderBy: 'name COLLATE NOCASE ASC',
    );
    return rows.map(Student.fromMap).toList();
  }

  Future<int> insertStudent(Student student) async {
    final db = await database;
    return db.insert(
      _table,
      student.toMap(),
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  Future<void> updateStudent(Student student) async {
    final db = await database;
    await db.update(
      _table,
      student.toMap(),
      where: 'id = ?',
      whereArgs: [student.id],
    );
  }

  Future<void> deleteStudent(int id) async {
    final db = await database;
    await db.delete(_table, where: 'id = ?', whereArgs: [id]);
  }

  Future<bool> nisExists(String nis, {int? excludeId}) async {
    final db = await database;
    final rows = await db.query(
      _table,
      columns: ['id'],
      where: excludeId == null ? 'nis = ?' : 'nis = ? AND id != ?',
      whereArgs: excludeId == null ? [nis] : [nis, excludeId],
      limit: 1,
    );
    return rows.isNotEmpty;
  }
}
