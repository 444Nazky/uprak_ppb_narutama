class Student {
  const Student({
    this.id,
    required this.nis,
    required this.name,
    required this.kelas,
    required this.alamat,
    this.photoPath,
    required this.createdAt,
    required this.updatedAt,
  });

  final int? id;
  final String nis;
  final String name;
  final String kelas;
  final String alamat;
  final String? photoPath;
  final DateTime createdAt;
  final DateTime updatedAt;

  String get initials {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) {
      final word = parts.first;
      return (word.length >= 2 ? word.substring(0, 2) : word).toUpperCase();
    }
    return '${parts.first[0]}${parts[1][0]}'.toUpperCase();
  }

  Student copyWith({
    int? id,
    String? nis,
    String? name,
    String? kelas,
    String? alamat,
    String? photoPath,
    bool clearPhoto = false,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Student(
      id: id ?? this.id,
      nis: nis ?? this.nis,
      name: name ?? this.name,
      kelas: kelas ?? this.kelas,
      alamat: alamat ?? this.alamat,
      photoPath: clearPhoto ? null : (photoPath ?? this.photoPath),
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, Object?> toMap() {
    return {
      if (id != null) 'id': id,
      'nis': nis,
      'name': name,
      'kelas': kelas,
      'alamat': alamat,
      'photo_path': photoPath,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory Student.fromMap(Map<String, Object?> map) {
    return Student(
      id: map['id'] as int?,
      nis: map['nis'] as String? ?? '',
      name: map['name'] as String? ?? '',
      kelas: map['kelas'] as String? ?? '',
      alamat: map['alamat'] as String? ?? '',
      photoPath: map['photo_path'] as String?,
      createdAt:
          DateTime.tryParse(map['created_at'] as String? ?? '') ??
          DateTime.now(),
      updatedAt:
          DateTime.tryParse(map['updated_at'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}
