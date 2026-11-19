import 'package:data_siswa/services/notifikasi_service.dart';
import 'package:data_siswa/services/pdf_service.dart';
import 'package:data_siswa/state/app_state.dart';
import 'package:data_siswa/theme/app_theme.dart';
import 'package:data_siswa/widgets/common.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

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

  Future<void> _logout(BuildContext context) async {
    final setuju = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(
          Icons.logout_rounded,
          size: 26,
          color: AppColors.danger,
        ),
        title: const Text('Keluar dari aplikasi?'),
        content: const Text(
          'Anda akan kembali ke halaman login. Data siswa tetap tersimpan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.danger,
              minimumSize: const Size(0, 44),
              padding: const EdgeInsets.symmetric(horizontal: 20),
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
    if (setuju != true || !context.mounted) return;
    await AppScope.baca(context).logout();
  }

  void _tentang(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) {
        final tema = Theme.of(context);
        return AlertDialog(
          title: const Text('Tentang aplikasi'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Aplikasi Data Siswa v1.0.0',
                style: tema.textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Dibuat untuk tugas praktik pemrograman mobile kelas XI RPL. '
                'Data disimpan di SQLite pada perangkat, sehingga tetap ada '
                'setelah aplikasi ditutup.',
                style: tema.textTheme.bodyMedium?.copyWith(
                  color: tema.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'SMK Plus Pelita Nusantara Bogor, tahun ajaran 2026/2027.',
                style: tema.textTheme.bodySmall?.copyWith(
                  color: tema.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Tutup'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final state = AppScope.of(context);
    final gelap = tema.brightness == Brightness.dark;

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 110),
        children: [
          Text('Profil', style: tema.textTheme.headlineMedium),
          const SizedBox(height: 18),
          AppCard(
            child: Column(
              children: [
                Container(
                  width: 78,
                  height: 78,
                  decoration: BoxDecoration(
                    color: tema.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(26),
                    border: Border.all(color: tema.colorScheme.outline),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    state.inisialPengguna,
                    style: tema.textTheme.headlineMedium?.copyWith(
                      color: tema.colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  state.namaPengguna,
                  textAlign: TextAlign.center,
                  style: tema.textTheme.titleLarge,
                ),
                const SizedBox(height: 4),
                Text(
                  'Administrator Sekolah',
                  style: tema.textTheme.bodyMedium?.copyWith(
                    color: tema.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: tema.colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                  child: Text(
                    '@${state.username}',
                    style: tema.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: tema.colorScheme.onSecondaryContainer,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${state.totalSiswa}',
                        style: tema.textTheme.headlineMedium?.copyWith(
                          fontSize: 28,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Total siswa',
                        style: tema.textTheme.bodySmall?.copyWith(
                          color: tema.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${state.totalKelas}',
                        style: tema.textTheme.headlineMedium?.copyWith(
                          fontSize: 28,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Kelas aktif',
                        style: tema.textTheme.bodySmall?.copyWith(
                          color: tema.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 26),
          const SectionTitle(text: 'Pengaturan'),
          AppCard(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
            child: Column(
              children: [
                SwitchListTile.adaptive(
                  value:
                      state.tema == ThemeMode.dark ||
                      (state.tema == ThemeMode.system && gelap),
                  onChanged: (aktif) =>
                      state.gantiTema(aktif ? ThemeMode.dark : ThemeMode.light),
                  title: const Text('Mode gelap'),
                  subtitle: Text(
                    'Tampilan gelap untuk mengurangi cahaya layar',
                    style: tema.textTheme.bodySmall?.copyWith(
                      color: tema.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  secondary: Icon(
                    Icons.dark_mode_outlined,
                    color: tema.colorScheme.onSurfaceVariant,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                ),
                const Divider(height: 1, indent: 12, endIndent: 12),
                ListTile(
                  onTap: () => _ekspor(context),
                  leading: Icon(
                    Icons.picture_as_pdf_outlined,
                    color: tema.colorScheme.onSurfaceVariant,
                  ),
                  title: const Text('Ekspor data ke PDF'),
                  subtitle: Text(
                    'Bagikan atau cetak laporan seluruh siswa',
                    style: tema.textTheme.bodySmall?.copyWith(
                      color: tema.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  trailing: Icon(
                    Icons.chevron_right_rounded,
                    size: 20,
                    color: tema.colorScheme.onSurfaceVariant,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                ),
                const Divider(height: 1, indent: 12, endIndent: 12),
                ListTile(
                  onTap: () {
                    NotifikasiService.kirim(
                      'Notifikasi aktif',
                      'Aplikasi Data Siswa akan memberi tahu setiap perubahan data.',
                    );
                    tampilkanPesan(context, 'Notifikasi percobaan dikirim.');
                  },
                  leading: Icon(
                    Icons.notifications_none_rounded,
                    color: tema.colorScheme.onSurfaceVariant,
                  ),
                  title: const Text('Tes notifikasi'),
                  subtitle: Text(
                    'Kirim contoh notifikasi perubahan data',
                    style: tema.textTheme.bodySmall?.copyWith(
                      color: tema.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  trailing: Icon(
                    Icons.chevron_right_rounded,
                    size: 20,
                    color: tema.colorScheme.onSurfaceVariant,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                ),
                const Divider(height: 1, indent: 12, endIndent: 12),
                ListTile(
                  onTap: () => _tentang(context),
                  leading: Icon(
                    Icons.info_outline_rounded,
                    color: tema.colorScheme.onSurfaceVariant,
                  ),
                  title: const Text('Tentang aplikasi'),
                  subtitle: Text(
                    'Versi 1.0.0',
                    style: tema.textTheme.bodySmall?.copyWith(
                      color: tema.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  trailing: Icon(
                    Icons.chevron_right_rounded,
                    size: 20,
                    color: tema.colorScheme.onSurfaceVariant,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                ),
              ],
            ),
          ),
          const SizedBox(height: 26),
          OutlinedButton.icon(
            onPressed: () => _logout(context),
            icon: const Icon(Icons.logout_rounded, size: 19),
            label: const Text('Logout'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.danger,
              side: BorderSide(color: AppColors.danger.withValues(alpha: 0.4)),
            ),
          ),
          const SizedBox(height: 14),
          Center(
            child: Text(
              'Aplikasi Data Siswa v1.0.0',
              style: tema.textTheme.bodySmall?.copyWith(
                color: tema.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
