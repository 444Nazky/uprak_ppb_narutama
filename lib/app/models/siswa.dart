class Siswa {
  const Siswa({
    this.id,
    required this.nis,
    required this.nama,
    required this.kelas,
    required this.alamat,
    this.fotoPath,
  });

  final int? id;
  final String nis;
  final String nama;
  final String kelas;
  final String alamat;
  final String? fotoPath;

  Siswa copyWith({
    int? id,
    String? nis,
    String? nama,
    String? kelas,
    String? alamat,
    String? fotoPath,
    bool hapusFoto = false,
  }) {
    return Siswa(
      id: id ?? this.id,
      nis: nis ?? this.nis,
      nama: nama ?? this.nama,
      kelas: kelas ?? this.kelas,
      alamat: alamat ?? this.alamat,
      fotoPath: hapusFoto ? null : (fotoPath ?? this.fotoPath),
    );
  }

  Map<String, Object?> toMap() {
    return {
      if (id != null) 'id': id,
      'nis': nis,
      'nama': nama,
      'kelas': kelas,
      'alamat': alamat,
      'foto_path': fotoPath,
    };
  }

  factory Siswa.fromMap(Map<String, Object?> map) {
    return Siswa(
      id: map['id'] as int?,
      nis: (map['nis'] as String? ?? '').trim(),
      nama: (map['nama'] as String? ?? '').trim(),
      kelas: (map['kelas'] as String? ?? '').trim(),
      alamat: (map['alamat'] as String? ?? '').trim(),
      fotoPath: map['foto_path'] as String?,
    );
  }

  String get inisial {
    final bagian = nama
        .trim()
        .split(RegExp(r'\s+'))
        .where((e) => e.isNotEmpty)
        .toList();
    if (bagian.isEmpty) return '?';
    if (bagian.length == 1) return bagian.first.substring(0, 1).toUpperCase();
    return (bagian.first.substring(0, 1) + bagian[1].substring(0, 1))
        .toUpperCase();
  }
}
