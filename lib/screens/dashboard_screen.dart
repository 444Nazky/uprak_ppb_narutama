import 'package:data_siswa/models/siswa.dart';
import 'package:data_siswa/services/pdf_service.dart';
import 'package:data_siswa/state/app_state.dart';
import 'package:data_siswa/theme/app_theme.dart';
import 'package:data_siswa/widgets/common.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({
    super.key,
    required this.onBukaData,
    required this.onPilihKelas,
    required this.onTambah,
    required this.onUbah,
    required this.onBukaProfil,
  });

  final VoidCallback onBukaData;
  final void Function(String kelas) onPilihKelas;
  final VoidCallback onTambah;
  final Future<void> Function(Siswa siswa) onUbah;
  final VoidCallback onBukaProfil;

  Future<void> _ekspor(BuildContext context) async {
    final state = AppScope.baca(context);
    if (state.siswa.isEmpty) {
      tampilkanPesan(context, 'Belum ada data untuk diekspor.', galat: true);
      return;
    }
    try {
      await PdfService.bagikan(
        siswa: state.siswa,
        dicetakOleh: state.namaPengguna,
      );
    } catch (error) {
      if (!context.mounted) return;
      tampilkanPesan(context, 'PDF gagal dibuat: $error', galat: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final state = AppScope.of(context);
    final jumlahKelas = state.jumlahPerKelas;

    return SafeArea(
      bottom: false,
      child: RefreshIndicator(
        onRefresh: state.muatUlang,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 110),
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Selamat datang,',
                        style: tema.textTheme.bodyMedium?.copyWith(
                          color: tema.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        state.namaPengguna,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: tema.textTheme.headlineSmall,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Semantics(
                  button: true,
                  label: 'Buka profil',
                  child: InkWell(
                    onTap: onBukaProfil,
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                    child: Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: tema.colorScheme.primaryContainer,
                        shape: BoxShape.circle,
                        border: Border.all(color: tema.colorScheme.outline),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        state.inisialPengguna,
                        style: tema.textTheme.titleMedium?.copyWith(
                          color: tema.colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _KartuTotal(
              total: state.totalSiswa,
              jumlahKelas: state.totalKelas,
              onTap: onBukaData,
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _AksiCepat(
                    icon: Icons.person_add_alt_1_outlined,
                    label: 'Tambah siswa',
                    keterangan: 'Isi form data baru',
                    menonjol: true,
                    onTap: onTambah,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _AksiCepat(
                    icon: Icons.picture_as_pdf_outlined,
                    label: 'Ekspor PDF',
                    keterangan: 'Laporan siap cetak',
                    onTap: () => _ekspor(context),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 26),
            SectionTitle(
              text: 'Sebaran kelas',
              aksi: AksiTeks(
                label: 'Lihat semua',
                icon: Icons.arrow_forward_rounded,
                onPressed: onBukaData,
              ),
            ),
            if (jumlahKelas.isEmpty)
              AppCard(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                child: Row(
                  children: [
                    Icon(Icons.info_outline_rounded,
                        size: 20, color: tema.colorScheme.onSurfaceVariant),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Sebaran kelas muncul setelah ada data siswa.',
                        style: tema.textTheme.bodyMedium?.copyWith(
                          color: tema.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else
              AppCard(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Column(
                  children: [
                    for (var i = 0; i < jumlahKelas.length; i++) ...[
                      if (i > 0) const Divider(height: 1),
                      InkWell(
                        onTap: () => onPilihKelas(jumlahKelas.keys.elementAt(i)),
                        borderRadius: BorderRadius.circular(10),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  jumlahKelas.keys.elementAt(i),
                                  style: tema.textTheme.bodyLarge,
                                ),
                              ),
                              Text(
                                '${jumlahKelas.values.elementAt(i)} siswa',
                                style: tema.textTheme.bodyMedium?.copyWith(
                                  color: tema.colorScheme.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Icon(Icons.chevron_right_rounded,
                                  size: 20, color: tema.colorScheme.onSurfaceVariant),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            const SizedBox(height: 26),
            SectionTitle(
              text: 'Terakhir ditambahkan',
              aksi: state.siswa.isEmpty
                  ? null
                  : AksiTeks(
                      label: 'Semua data',
                      icon: Icons.arrow_forward_rounded,
                      onPressed: onBukaData,
                    ),
            ),
            if (state.siswa.isEmpty)
              AppCard(
                padding: EdgeInsets.zero,
                child: EmptyState(
                  ringkas: true,
                  icon: Icons.groups_outlined,
                  judul: 'Daftar siswa masih kosong',
                  pesan: 'Mulai dengan menambahkan satu siswa lewat tombol di bawah.',
                  aksi: FilledButton.icon(
                    onPressed: onTambah,
                    icon: const Icon(Icons.add_rounded, size: 20),
                    label: const Text('Tambah siswa'),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(0, 46),
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                    ),
                  ),
                ),
              )
            else
              AppCard(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                child: Column(
                  children: [
                    for (var i = 0; i < state.siswaTerbaru.length; i++) ...[
                      if (i > 0) const Divider(height: 1),
                      _BarisSiswa(
                        siswa: state.siswaTerbaru[i],
                        onTap: () => onUbah(state.siswaTerbaru[i]),
                      ),
                    ],
                  ],
                ),
              ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.cloud_done_outlined,
                    size: 14, color: tema.colorScheme.onSurfaceVariant),
                const SizedBox(width: 6),
                Text(
                  'Tersimpan di perangkat, tetap ada setelah aplikasi ditutup',
                  style: tema.textTheme.bodySmall?.copyWith(
                    color: tema.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _KartuTotal extends StatelessWidget {
  const _KartuTotal({
    required this.total,
    required this.jumlahKelas,
    required this.onTap,
  });

  final int total;
  final int jumlahKelas;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Material(
      color: AppColors.cobaltDeep,
      borderRadius: BorderRadius.circular(AppRadius.card),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Stack(
          children: [
            Positioned(
              right: -46,
              top: -58,
              child: Container(
                width: 168,
                height: 168,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.06),
                ),
              ),
            ),
            Positioned(
              right: 10,
              bottom: -70,
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withValues(alpha: 0.08), width: 1.5),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.groups_2_outlined, color: Colors.white, size: 19),
                      const SizedBox(width: 8),
                      Text(
                        'Total siswa terdaftar',
                        style: tema.textTheme.labelMedium?.copyWith(
                          color: Colors.white.withValues(alpha: 0.82),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        NumberFormat.decimalPattern('id_ID').format(total),
                        style: tema.textTheme.displaySmall?.copyWith(
                          color: Colors.white,
                          fontSize: 46,
                          height: 1,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Text(
                          'siswa',
                          style: tema.textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withValues(alpha: 0.82),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Container(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                        ),
                        child: Text(
                          '$jumlahKelas kelas aktif',
                          style: tema.textTheme.bodySmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'Kelola data',
                        style: tema.textTheme.labelMedium?.copyWith(
                          color: Colors.white.withValues(alpha: 0.92),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(Icons.arrow_forward_rounded,
                          size: 16, color: Colors.white.withValues(alpha: 0.92)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AksiCepat extends StatelessWidget {
  const _AksiCepat({
    required this.icon,
    required this.label,
    required this.keterangan,
    required this.onTap,
    this.menonjol = false,
  });

  final IconData icon;
  final String label;
  final String keterangan;
  final VoidCallback onTap;
  final bool menonjol;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final latar = menonjol
        ? tema.colorScheme.primaryContainer
        : tema.colorScheme.surface;
    final warnaIsi = menonjol
        ? tema.colorScheme.onPrimaryContainer
        : tema.colorScheme.primary;
    return Material(
      color: latar,
      borderRadius: BorderRadius.circular(AppRadius.card),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: 96,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.card),
            border: Border.all(
              color: menonjol ? Colors.transparent : tema.colorScheme.outline,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 22, color: warnaIsi),
              const Spacer(),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: tema.textTheme.titleMedium?.copyWith(fontSize: 14.5),
              ),
              const SizedBox(height: 2),
              Text(
                keterangan,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: tema.textTheme.bodySmall?.copyWith(
                  color: tema.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BarisSiswa extends StatelessWidget {
  const _BarisSiswa({required this.siswa, required this.onTap});

  final Siswa siswa;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            StudentAvatar(siswa: siswa, size: 40, radius: 12),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    siswa.nama,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: tema.textTheme.titleMedium?.copyWith(fontSize: 14.5),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${siswa.kelas}  |  ${siswa.nis}',
                    style: tema.textTheme.bodySmall?.copyWith(
                      color: tema.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                size: 20, color: tema.colorScheme.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}
