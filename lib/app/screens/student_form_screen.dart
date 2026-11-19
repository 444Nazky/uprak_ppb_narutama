import 'dart:io';

import 'package:data_siswa/app/data/sqlite_siswa_repository.dart';
import 'package:data_siswa/app/models/siswa.dart';
import 'package:data_siswa/app/services/notifikasi_service.dart';
import 'package:data_siswa/app/state/app_state.dart';
import 'package:data_siswa/app/theme/app_theme.dart';
import 'package:data_siswa/app/widgets/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

/// Form tambah dan ubah data siswa.
class StudentFormScreen extends StatefulWidget {
  const StudentFormScreen({super.key, this.siswa});

  final Siswa? siswa;

  bool get modeUbah => siswa != null;

  @override
  State<StudentFormScreen> createState() => _StudentFormScreenState();
}

class _StudentFormScreenState extends State<StudentFormScreen> {
  static const _kelasBawaan = ['XI RPL 1', 'XI RPL 2', 'XI TKJ 1', 'XI TKJ 2'];

  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nis;
  late final TextEditingController _nama;
  late final TextEditingController _alamat;

  String? _kelas;
  String? _fotoPath;
  bool _menyimpan = false;

  @override
  void initState() {
    super.initState();
    final siswa = widget.siswa;
    _nis = TextEditingController(text: siswa?.nis ?? '');
    _nama = TextEditingController(text: siswa?.nama ?? '');
    _alamat = TextEditingController(text: siswa?.alamat ?? '');
    _kelas = siswa?.kelas;
    _fotoPath = siswa?.fotoPath;
  }

  @override
  void dispose() {
    _nis.dispose();
    _nama.dispose();
    _alamat.dispose();
    super.dispose();
  }

  List<String> get _pilihanKelas {
    final state = AppScope.baca(context);
    final gabungan = <String>{..._kelasBawaan, ...state.kelasTersedia};
    final daftar = gabungan.toList()..sort();
    if (_kelas != null && !daftar.contains(_kelas)) {
      daftar.insert(0, _kelas!);
    }
    return daftar;
  }

  Future<void> _pilihFoto() async {
    final pilihan = await showModalBottomSheet<ImageSource>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        final tema = Theme.of(context);
        Widget opsi(IconData icon, String label, ImageSource sumber) {
          return ListTile(
            leading: Icon(icon, color: tema.colorScheme.primary),
            title: Text(label, style: tema.textTheme.titleMedium),
            onTap: () => Navigator.of(context).pop(sumber),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          );
        }

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                  child: Text('Foto siswa', style: tema.textTheme.titleLarge),
                ),
                opsi(
                  Icons.photo_library_outlined,
                  'Pilih dari galeri',
                  ImageSource.gallery,
                ),
                opsi(
                  Icons.photo_camera_outlined,
                  'Ambil dari kamera',
                  ImageSource.camera,
                ),
                if (_fotoPath != null)
                  ListTile(
                    leading: const Icon(
                      Icons.delete_outline_rounded,
                      color: AppColors.danger,
                    ),
                    title: Text(
                      'Hapus foto',
                      style: tema.textTheme.titleMedium?.copyWith(
                        color: AppColors.danger,
                      ),
                    ),
                    onTap: () {
                      setState(() => _fotoPath = null);
                      Navigator.of(context).pop();
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );

    if (pilihan == null) return;
    try {
      final hasil = await ImagePicker().pickImage(
        source: pilihan,
        maxWidth: 900,
        imageQuality: 80,
      );
      if (hasil == null) return;
      final path = await PenyimpananFoto.simpan(File(hasil.path));
      if (!mounted) return;
      setState(() => _fotoPath = path);
    } catch (error) {
      if (!mounted) return;
      tampilkanPesan(context, 'Foto tidak dapat dibuka: $error', galat: true);
    }
  }

  Future<void> _simpan() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    if (_kelas == null || _kelas!.isEmpty) {
      tampilkanPesan(
        context,
        'Pilih kelas siswa terlebih dahulu.',
        galat: true,
      );
      return;
    }

    setState(() => _menyimpan = true);
    final state = AppScope.baca(context);
    final nis = _nis.text.trim();

    try {
      final bentrok = await state.nisDipakai(nis, kecualiId: widget.siswa?.id);
      if (bentrok) {
        if (!mounted) return;
        setState(() => _menyimpan = false);
        tampilkanPesan(
          context,
          'NIS $nis sudah dipakai siswa lain.',
          galat: true,
        );
        return;
      }

      final data =
          (widget.siswa ??
                  const Siswa(nis: '', nama: '', kelas: '', alamat: ''))
              .copyWith(
                nis: nis,
                nama: _nama.text.trim(),
                kelas: _kelas,
                alamat: _alamat.text.trim(),
                fotoPath: _fotoPath,
              );

      if (widget.modeUbah) {
        await state.ubahSiswa(data);
      } else {
        await state.tambahSiswa(data);
      }

      if (!mounted) return;
      NotifikasiService.kirim(
        widget.modeUbah ? 'Data siswa diperbarui' : 'Data siswa ditambahkan',
        '${data.nama} (${data.kelas}) tersimpan di perangkat.',
      );
      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;
      setState(() => _menyimpan = false);
      tampilkanPesan(context, 'Gagal menyimpan data: $error', galat: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final ubah = widget.modeUbah;

    return Scaffold(
      appBar: AppBar(
        title: Text(ubah ? 'Ubah Data Siswa' : 'Tambah Data Siswa'),
      ),
      body: SafeArea(
        top: false,
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
            children: [
              Center(
                child: Column(
                  children: [
                    _FotoPicker(
                      fotoPath: _fotoPath,
                      inisial: _nama.text.trim().isEmpty
                          ? '?'
                          : _inisialDari(_nama.text),
                      onTap: _menyimpan ? null : _pilihFoto,
                    ),
                    const SizedBox(height: 10),
                    TextButton(
                      onPressed: _menyimpan ? null : _pilihFoto,
                      child: Text(
                        _fotoPath == null ? 'Tambah foto' : 'Ganti foto',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              LabeledField(
                label: 'NIS',
                wajib: true,
                bantuan:
                    'Nomor Induk Siswa, tidak boleh sama dengan siswa lain.',
                child: TextFormField(
                  controller: _nis,
                  enabled: !_menyimpan,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(20),
                  ],
                  decoration: const InputDecoration(
                    hintText: 'Contoh: 241007',
                    prefixIcon: Icon(Icons.badge_outlined, size: 20),
                  ),
                  validator: (nilai) {
                    final teks = nilai?.trim() ?? '';
                    if (teks.isEmpty) return 'NIS wajib diisi.';
                    if (teks.length < 4) return 'NIS minimal 4 digit.';
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 16),
              LabeledField(
                label: 'Nama Siswa',
                wajib: true,
                child: TextFormField(
                  controller: _nama,
                  enabled: !_menyimpan,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    hintText: 'Nama lengkap siswa',
                    prefixIcon: Icon(Icons.person_outline_rounded, size: 20),
                  ),
                  onChanged: (_) => setState(() {}),
                  validator: (nilai) {
                    final teks = nilai?.trim() ?? '';
                    if (teks.isEmpty) return 'Nama siswa wajib diisi.';
                    if (teks.length < 3) return 'Nama terlalu pendek.';
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 16),
              LabeledField(
                label: 'Kelas',
                wajib: true,
                child: DropdownButtonFormField<String>(
                  initialValue: _kelas,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    hintText: 'Pilih kelas',
                    prefixIcon: Icon(Icons.meeting_room_outlined, size: 20),
                  ),
                  items: [
                    for (final kelas in _pilihanKelas)
                      DropdownMenuItem(value: kelas, child: Text(kelas)),
                  ],
                  onChanged: _menyimpan
                      ? null
                      : (nilai) => setState(() => _kelas = nilai),
                  validator: (nilai) => nilai == null || nilai.isEmpty
                      ? 'Kelas wajib dipilih.'
                      : null,
                ),
              ),
              const SizedBox(height: 16),
              LabeledField(
                label: 'Alamat',
                wajib: true,
                child: TextFormField(
                  controller: _alamat,
                  enabled: !_menyimpan,
                  maxLines: 3,
                  minLines: 3,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    hintText: 'Jalan, nomor rumah, kelurahan',
                    alignLabelWithHint: true,
                  ),
                  validator: (nilai) {
                    final teks = nilai?.trim() ?? '';
                    if (teks.isEmpty) return 'Alamat wajib diisi.';
                    if (teks.length < 5) return 'Alamat terlalu pendek.';
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 28),
              FilledButton.icon(
                onPressed: _menyimpan ? null : _simpan,
                icon: _menyimpan
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.2,
                          color: Colors.white,
                        ),
                      )
                    : Icon(
                        ubah ? Icons.save_outlined : Icons.add_rounded,
                        size: 20,
                      ),
                label: Text(
                  _menyimpan
                      ? 'Menyimpan...'
                      : (ubah ? 'Simpan Perubahan' : 'Simpan'),
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: _menyimpan
                    ? null
                    : () => Navigator.of(context).pop(false),
                child: const Text('Batal'),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.lock_outline_rounded,
                    size: 14,
                    color: tema.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Data disimpan permanen di perangkat ini',
                    style: tema.textTheme.bodySmall?.copyWith(
                      color: tema.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _inisialDari(String nama) {
    final bagian = nama
        .trim()
        .split(RegExp(r'\s+'))
        .where((e) => e.isNotEmpty)
        .toList();
    if (bagian.isEmpty) return '?';
    if (bagian.length == 1) return bagian.first[0].toUpperCase();
    return (bagian[0][0] + bagian[1][0]).toUpperCase();
  }
}

class _FotoPicker extends StatelessWidget {
  const _FotoPicker({
    required this.fotoPath,
    required this.inisial,
    required this.onTap,
  });

  final String? fotoPath;
  final String inisial;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final adaFoto = fotoPath != null && File(fotoPath!).existsSync();
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          Container(
            width: 104,
            height: 104,
            decoration: BoxDecoration(
              color: tema.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: tema.colorScheme.outline),
              image: adaFoto
                  ? DecorationImage(
                      image: FileImage(File(fotoPath!)),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            alignment: Alignment.center,
            child: adaFoto
                ? null
                : inisial == '?'
                    ? Icon(
                        Icons.person_outline_rounded,
                        size: 42,
                        color: tema.colorScheme.onPrimaryContainer,
                      )
                    : Text(
                        inisial,
                        style: tema.textTheme.headlineMedium?.copyWith(
                          color: tema.colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
          ),
          Positioned(
            right: -2,
            bottom: -2,
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: tema.colorScheme.primary,
                shape: BoxShape.circle,
                border: Border.all(
                  color: tema.scaffoldBackgroundColor,
                  width: 2.5,
                ),
              ),
              child: Icon(
                adaFoto ? Icons.edit_outlined : Icons.add_a_photo_outlined,
                size: 16,
                color: tema.colorScheme.onPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
