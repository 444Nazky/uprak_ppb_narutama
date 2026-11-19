import 'package:data_siswa/models/siswa.dart';
import 'package:data_siswa/services/notifikasi_service.dart';
import 'package:data_siswa/state/app_state.dart';
import 'package:data_siswa/theme/app_theme.dart';
import 'package:data_siswa/widgets/common.dart';
import 'package:flutter/material.dart';

class StudentListScreen extends StatefulWidget {
  const StudentListScreen({
    super.key,
    required this.onTambah,
    required this.onUbah,
  });

  final VoidCallback onTambah;
  final Future<void> Function(Siswa siswa) onUbah;

  @override
  State<StudentListScreen> createState() => _StudentListScreenState();
}

class _StudentListScreenState extends State<StudentListScreen> {
  final _pencarian = TextEditingController();

  @override
  void dispose() {
    _pencarian.dispose();
    super.dispose();
  }

  Future<void> _hapus(Siswa siswa) async {
    final setuju = await konfirmasiHapus(context, nama: siswa.nama);
    if (!setuju || !mounted) return;
    final state = AppScope.baca(context);
    final nama = siswa.nama;
    await state.hapusSiswa(siswa);
    if (!mounted) return;
    NotifikasiService.kirim(
      'Data siswa dihapus',
      '$nama sudah dihapus dari daftar siswa.',
    );
    tampilkanPesan(context, 'Data $nama dihapus.');
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final state = AppScope.of(context);
    final daftar = state.siswaTampil;
    final adaPencarian =
        state.pencarian.trim().isNotEmpty || state.filterKelas != null;

    return SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Data Siswa', style: tema.textTheme.headlineMedium),
                      const SizedBox(height: 4),
                      Text(
                        '${state.totalSiswa} siswa terdaftar di ${state.totalKelas} kelas',
                        style: tema.textTheme.bodyMedium?.copyWith(
                          color: tema.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: TextField(
              controller: _pencarian,
              textInputAction: TextInputAction.search,
              onChanged: state.cari,
              decoration: InputDecoration(
                hintText: 'Cari nama, NIS, atau kelas',
                prefixIcon: const Icon(Icons.search_rounded, size: 21),
                suffixIcon: _pencarian.text.isEmpty
                    ? null
                    : IconButton(
                        tooltip: 'Hapus pencarian',
                        icon: const Icon(Icons.close_rounded, size: 19),
                        onPressed: () {
                          _pencarian.clear();
                          state.cari('');
                          setState(() {});
                        },
                      ),
              ),
            ),
          ),
          SizedBox(
            height: 54,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              children: [
                _FilterChip(
                  label: 'Semua kelas',
                  aktif: state.filterKelas == null,
                  onTap: () => state.saringKelas(null),
                ),
                for (final kelas in state.kelasTersedia) ...[
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: kelas,
                    aktif: state.filterKelas == kelas,
                    onTap: () => state.saringKelas(kelas),
                  ),
                ],
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: state.muatUlang,
              child: daftar.isEmpty
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.only(top: 40),
                      children: [
                        adaPencarian
                            ? EmptyState(
                                icon: Icons.search_off_rounded,
                                judul: 'Siswa tidak ditemukan',
                                pesan: 'Tidak ada data yang cocok dengan pencarian atau filter kelas yang dipilih.',
                                aksi: OutlinedButton(
                                  onPressed: () {
                                    _pencarian.clear();
                                    state.cari('');
                                    state.saringKelas(null);
                                    setState(() {});
                                  },
                                  child: const Text('Reset pencarian'),
                                ),
                              )
                            : EmptyState(
                                icon: Icons.groups_outlined,
                                judul: 'Belum ada data siswa',
                                pesan: 'Tambahkan siswa pertama untuk mulai mengelola data di aplikasi ini.',
                                aksi: FilledButton.icon(
                                  onPressed: widget.onTambah,
                                  icon: const Icon(Icons.add_rounded, size: 20),
                                  label: const Text('Tambah siswa'),
                                  style: FilledButton.styleFrom(
                                    minimumSize: const Size(0, 48),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                    ),
                                  ),
                                ),
                              ),
                      ],
                    )
                  : ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
                      itemCount: daftar.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final siswa = daftar[index];
                        return _KartuSiswa(
                          siswa: siswa,
                          onUbah: () => widget.onUbah(siswa),
                          onHapus: () => _hapus(siswa),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.aktif,
    required this.onTap,
  });

  final String label;
  final bool aktif;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return ChoiceChip(
      label: Text(label),
      selected: aktif,
      onSelected: (_) => onTap(),
      showCheckmark: false,
      labelStyle: tema.textTheme.labelMedium?.copyWith(
        color: aktif
            ? tema.colorScheme.onPrimary
            : tema.colorScheme.onSurfaceVariant,
        fontWeight: aktif ? FontWeight.w700 : FontWeight.w500,
      ),
      side: BorderSide(
        color: aktif ? Colors.transparent : tema.colorScheme.outline,
      ),
      backgroundColor: tema.colorScheme.surface,
      selectedColor: tema.colorScheme.primary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    );
  }
}

class _KartuSiswa extends StatelessWidget {
  const _KartuSiswa({
    required this.siswa,
    required this.onUbah,
    required this.onHapus,
  });

  final Siswa siswa;
  final VoidCallback onUbah;
  final VoidCallback onHapus;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return AppCard(
      padding: const EdgeInsets.fromLTRB(14, 14, 8, 14),
      onTap: onUbah,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StudentAvatar(siswa: siswa, size: 48),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  siswa.nama,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: tema.textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.badge_outlined,
                      size: 13,
                      color: tema.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      siswa.nis,
                      style: tema.textTheme.bodySmall?.copyWith(
                        color: tema.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: tema.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                      ),
                      child: Text(
                        siswa.kelas,
                        style: tema.textTheme.bodySmall?.copyWith(
                          color: tema.colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.w600,
                          fontSize: 11.5,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 1),
                      child: Icon(
                        Icons.place_outlined,
                        size: 13,
                        color: tema.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        siswa.alamat,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: tema.textTheme.bodySmall?.copyWith(
                          color: tema.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            tooltip: 'Aksi data siswa',
            icon: Icon(
              Icons.more_vert_rounded,
              size: 20,
              color: tema.colorScheme.onSurfaceVariant,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            onSelected: (nilai) {
              if (nilai == 'ubah') onUbah();
              if (nilai == 'hapus') onHapus();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'ubah',
                child: Row(
                  children: [
                    Icon(Icons.edit_outlined, size: 18),
                    SizedBox(width: 10),
                    Text('Ubah data'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'hapus',
                child: Row(
                  children: [
                    Icon(
                      Icons.delete_outline_rounded,
                      size: 18,
                      color: AppColors.danger,
                    ),
                    SizedBox(width: 10),
                    Text('Hapus', style: TextStyle(color: AppColors.danger)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
