import 'package:flutter/material.dart';

import '../state/app_state.dart';
import '../utils/app_constants.dart';
import '../utils/export_helper.dart';
import '../widgets/avatar_circle.dart';
import '../widgets/section_header.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key, required this.state});

  final AppState state;

  Future<void> _toggleNotifications(BuildContext context, bool value) async {
    final messenger = ScaffoldMessenger.of(context);
    final granted = await state.setNotificationsEnabled(value);
    if (!context.mounted) return;
    if (value && !granted) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text(
            'Izin notifikasi belum aktif. Buka pengaturan aplikasi untuk '
            'mengizinkannya.',
          ),
        ),
      );
    } else if (value) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Notifikasi diaktifkan.')),
      );
    }
  }

  Future<void> _logout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        final scheme = Theme.of(dialogContext).colorScheme;
        return AlertDialog(
          icon: Icon(Icons.logout_rounded, color: scheme.error, size: 28),
          title: const Text('Keluar dari akun?'),
          content: const Text(
            'Kamu perlu login lagi untuk membuka data siswa.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: FilledButton.styleFrom(
                backgroundColor: scheme.error,
                foregroundColor: scheme.onError,
                minimumSize: const Size(0, 44),
              ),
              child: const Text('Keluar'),
            ),
          ],
        );
      },
    );
    if (confirmed == true) {
      await state.logout();
    }
  }

  void _showAbout(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        final theme = Theme.of(dialogContext);
        return AlertDialog(
          icon: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.asset(
              'assets/images/app_mark.png',
              width: 56,
              height: 56,
            ),
          ),
          title: const Text(AppConstants.appName),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Versi ${AppConstants.version}',
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: 12),
              Text(
                'Aplikasi pengelolaan data siswa untuk admin sekolah. '
                'Data tersimpan lokal di perangkat.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 12),
              Text(
                AppConstants.schoolName,
                textAlign: TextAlign.center,
                style: theme.textTheme.labelMedium,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Tutup'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        children: [
          Text('Profil', style: theme.textTheme.headlineSmall),
          const SizedBox(height: 2),
          Text(
            'Akun dan preferensi aplikasi.',
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: scheme.surface,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: scheme.outlineVariant),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    AvatarCircle(
                      label: 'AS',
                      size: 64,
                      background: scheme.primaryContainer,
                      foreground: scheme.onPrimaryContainer,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            state.displayName,
                            style: theme.textTheme.titleLarge,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '@${state.username}',
                            style: theme.textTheme.bodySmall,
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: scheme.primaryContainer,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              state.role,
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: scheme.onPrimaryContainer,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Divider(color: scheme.outlineVariant),
                const SizedBox(height: 14),
                Row(
                  children: [
                    _ProfileStat(
                      value: '${state.totalStudents}',
                      label: 'Siswa',
                    ),
                    _VerticalLine(color: scheme.outlineVariant),
                    _ProfileStat(value: '${state.classCount}', label: 'Kelas'),
                    _VerticalLine(color: scheme.outlineVariant),
                    _ProfileStat(value: '${state.photoCount}', label: 'Foto'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const SectionHeader(title: 'Preferensi'),
          Container(
            decoration: BoxDecoration(
              color: scheme.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: scheme.outlineVariant),
            ),
            child: Column(
              children: [
                SwitchListTile.adaptive(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 2,
                  ),
                  secondary: _SettingIcon(
                    icon: Icons.dark_mode_outlined,
                    background: scheme.primaryContainer,
                    foreground: scheme.primary,
                  ),
                  title: Text('Mode gelap', style: theme.textTheme.titleSmall),
                  subtitle: Text(
                    'Tema gelap untuk tampilan malam',
                    style: theme.textTheme.bodySmall,
                  ),
                  value: state.isDarkMode,
                  onChanged: state.setDarkMode,
                ),
                Divider(height: 1, indent: 64, color: scheme.outlineVariant),
                SwitchListTile.adaptive(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 2,
                  ),
                  secondary: _SettingIcon(
                    icon: Icons.notifications_none_rounded,
                    background: scheme.secondaryContainer,
                    foreground: scheme.secondary,
                  ),
                  title: Text('Notifikasi', style: theme.textTheme.titleSmall),
                  subtitle: Text(
                    'Beri tahu saat data siswa berubah',
                    style: theme.textTheme.bodySmall,
                  ),
                  value: state.notificationsEnabled,
                  onChanged: (value) => _toggleNotifications(context, value),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const SectionHeader(title: 'Data dan aplikasi'),
          Container(
            decoration: BoxDecoration(
              color: scheme.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: scheme.outlineVariant),
            ),
            child: Column(
              children: [
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 2,
                  ),
                  leading: _SettingIcon(
                    icon: Icons.picture_as_pdf_outlined,
                    background: scheme.errorContainer,
                    foreground: scheme.error,
                  ),
                  title: Text(
                    'Export data siswa',
                    style: theme.textTheme.titleSmall,
                  ),
                  subtitle: Text(
                    'Buat laporan PDF dari seluruh data',
                    style: theme.textTheme.bodySmall,
                  ),
                  trailing: Icon(
                    Icons.chevron_right_rounded,
                    color: scheme.onSurfaceVariant,
                  ),
                  onTap: () => exportStudentsPdf(context, state.students),
                ),
                Divider(height: 1, indent: 64, color: scheme.outlineVariant),
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 2,
                  ),
                  leading: _SettingIcon(
                    icon: Icons.info_outline_rounded,
                    background: scheme.surfaceContainer,
                    foreground: scheme.onSurfaceVariant,
                  ),
                  title: Text(
                    'Tentang aplikasi',
                    style: theme.textTheme.titleSmall,
                  ),
                  subtitle: Text(
                    'Versi ${AppConstants.version}',
                    style: theme.textTheme.bodySmall,
                  ),
                  trailing: Icon(
                    Icons.chevron_right_rounded,
                    color: scheme.onSurfaceVariant,
                  ),
                  onTap: () => _showAbout(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const SectionHeader(title: 'Akun'),
          Container(
            decoration: BoxDecoration(
              color: scheme.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: scheme.outlineVariant),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 4,
              ),
              leading: _SettingIcon(
                icon: Icons.logout_rounded,
                background: scheme.errorContainer,
                foreground: scheme.error,
              ),
              title: Text(
                'Keluar dari akun',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: scheme.error,
                ),
              ),
              subtitle: Text(
                'Kembali ke halaman login',
                style: theme.textTheme.bodySmall,
              ),
              onTap: () => _logout(context),
            ),
          ),
          const SizedBox(height: 28),
          Center(
            child: Text(
              '${AppConstants.appName} · Versi ${AppConstants.version}',
              style: theme.textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileStat extends StatelessWidget {
  const _ProfileStat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(fontSize: 20),
          ),
          const SizedBox(height: 2),
          Text(label, style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _VerticalLine extends StatelessWidget {
  const _VerticalLine({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 32, color: color);
  }
}

class _SettingIcon extends StatelessWidget {
  const _SettingIcon({
    required this.icon,
    required this.background,
    required this.foreground,
  });

  final IconData icon;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, size: 19, color: foreground),
    );
  }
}
