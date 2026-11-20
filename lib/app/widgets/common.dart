import 'package:data_siswa/app/platform/foto.dart';

import 'package:data_siswa/app/models/siswa.dart';
import 'package:data_siswa/app/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// Kartu dasar dengan satu garis tipis dan radius 18.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.color,
    this.onTap,
  });

  final Widget child;
  final EdgeInsets padding;
  final Color? color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final isi = Padding(padding: padding, child: child);
    return Material(
      color: color ?? tema.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.card),
        side: BorderSide(color: tema.colorScheme.outline),
      ),
      clipBehavior: Clip.antiAlias,
      child: onTap == null
          ? isi
          : InkWell(
              onTap: onTap,
              splashColor: tema.colorScheme.primary.withValues(alpha: 0.06),
              highlightColor: tema.colorScheme.primary.withValues(alpha: 0.04),
              child: isi,
            ),
    );
  }
}

/// Judul bagian dengan aksi opsional di kanan.
class SectionTitle extends StatelessWidget {
  const SectionTitle({super.key, required this.text, this.aksi});

  final String text;
  final Widget? aksi;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(text, style: Theme.of(context).textTheme.titleLarge),
          ),
          ?aksi,
        ],
      ),
    );
  }
}

/// Foto siswa bila ada, selain itu inisial nama.
class StudentAvatar extends StatelessWidget {
  const StudentAvatar({
    super.key,
    required this.siswa,
    this.size = 46,
    this.radius = 14,
  });

  final Siswa siswa;
  final double size;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final path = siswa.fotoPath;
    final gambar = fotoProvider(path);
    final punyaFoto = gambar != null;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: tema.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(radius),
        image: punyaFoto
            ? DecorationImage(image: gambar, fit: BoxFit.cover)
            : null,
      ),
      alignment: Alignment.center,
      child: punyaFoto
          ? null
          : Text(
              siswa.inisial,
              style: TextStyle(
                fontSize: size * 0.36,
                fontWeight: FontWeight.w700,
                color: tema.colorScheme.onPrimaryContainer,
              ),
            ),
    );
  }
}

/// Tampilan saat daftar kosong atau pencarian tidak menemukan hasil.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.judul,
    required this.pesan,
    this.aksi,
    this.ringkas = false,
  });

  final IconData icon;
  final String judul;
  final String pesan;
  final Widget? aksi;
  final bool ringkas;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 24,
          vertical: ringkas ? 20 : 40,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: tema.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                icon,
                size: 28,
                color: tema.colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              judul,
              textAlign: TextAlign.center,
              style: tema.textTheme.titleMedium,
            ),
            const SizedBox(height: 6),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 320),
              child: Text(
                pesan,
                textAlign: TextAlign.center,
                style: tema.textTheme.bodyMedium?.copyWith(
                  color: tema.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            if (aksi != null) ...[const SizedBox(height: 18), aksi!],
          ],
        ),
      ),
    );
  }
}

/// Label di atas input, sesuai pola form yang dipakai di seluruh aplikasi.
class LabeledField extends StatelessWidget {
  const LabeledField({
    super.key,
    required this.label,
    required this.child,
    this.wajib = false,
    this.bantuan,
    this.jarakAtas = 0,
  });

  final String label;
  final Widget child;
  final bool wajib;
  final String? bantuan;
  final double jarakAtas;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Padding(
      padding: EdgeInsets.only(top: jarakAtas),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                label,
                style: tema.textTheme.labelMedium?.copyWith(
                  color: tema.colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (wajib)
                Text(
                  ' *',
                  style: tema.textTheme.labelMedium?.copyWith(
                    color: tema.colorScheme.error,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          child,
          if (bantuan != null) ...[
            const SizedBox(height: 6),
            Text(
              bantuan!,
              style: tema.textTheme.bodySmall?.copyWith(
                color: tema.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Dialog konfirmasi sebelum data dihapus.
Future<bool> konfirmasiHapus(
  BuildContext context, {
  required String nama,
}) async {
  final hasil = await showDialog<bool>(
    context: context,
    builder: (context) {
      final tema = Theme.of(context);
      return AlertDialog(
        icon: Center(
          child: Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.dangerSoft,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.delete_outline_rounded,
              color: AppColors.danger,
              size: 26,
            ),
          ),
        ),
        title: const Text('Hapus data siswa?'),
        content: Text(
          'Data $nama akan dihapus permanen dan tidak bisa dikembalikan.',
        ),
        actionsAlignment: MainAxisAlignment.end,
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            style: TextButton.styleFrom(
              foregroundColor: tema.colorScheme.onSurfaceVariant,
            ),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.danger,
              minimumSize: const Size(0, 44),
              padding: const EdgeInsets.symmetric(horizontal: 20),
            ),
            child: const Text('Hapus'),
          ),
        ],
      );
    },
  );
  return hasil ?? false;
}

void tampilkanPesan(BuildContext context, String pesan, {bool galat = false}) {
  final tema = Theme.of(context);
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              galat
                  ? Icons.error_outline_rounded
                  : Icons.check_circle_outline_rounded,
              color: galat ? AppColors.dangerSoft : Colors.white,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(child: Text(pesan)),
          ],
        ),
        backgroundColor: galat
            ? AppColors.danger
            : tema.snackBarTheme.backgroundColor,
      ),
    );
}

/// Tombol kecil berbentuk teks dengan ikon untuk aksi sekunder.
class AksiTeks extends StatelessWidget {
  const AksiTeks({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.warna,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Color? warna;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final color = warna ?? tema.colorScheme.primary;
    return TextButton.icon(
      onPressed: onPressed,
      icon: icon == null
          ? const SizedBox.shrink()
          : Icon(icon, size: 18, color: color),
      label: Text(
        label,
        style: tema.textTheme.labelMedium?.copyWith(color: color),
      ),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        minimumSize: const Size(0, 34),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }
}
