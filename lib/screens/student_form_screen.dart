import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../models/student.dart';
import '../services/photo_service.dart';
import '../state/app_state.dart';
import '../utils/app_constants.dart';
import '../widgets/avatar_circle.dart';

class StudentFormScreen extends StatefulWidget {
  const StudentFormScreen({super.key, required this.state, this.student});

  final AppState state;
  final Student? student;

  @override
  State<StudentFormScreen> createState() => _StudentFormScreenState();
}

class _StudentFormScreenState extends State<StudentFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nisController;
  late final TextEditingController _nameController;
  late final TextEditingController _alamatController;

  String? _kelas;
  String? _existingPhotoPath;
  XFile? _pickedPhoto;
  bool _removePhoto = false;
  bool _saving = false;
  String? _nisError;

  bool get _isEditing => widget.student != null;

  @override
  void initState() {
    super.initState();
    final student = widget.student;
    _nisController = TextEditingController(text: student?.nis ?? '');
    _nameController = TextEditingController(text: student?.name ?? '');
    _alamatController = TextEditingController(text: student?.alamat ?? '');
    _kelas = student?.kelas;
    _existingPhotoPath = student?.photoPath;
  }

  @override
  void dispose() {
    _nisController.dispose();
    _nameController.dispose();
    _alamatController.dispose();
    super.dispose();
  }

  List<String> get _classOptions {
    final values = <String>{
      ...AppConstants.classOptions,
      ...widget.state.classes,
      if (_kelas != null) _kelas!,
    };
    return values.toList();
  }

  File? get _previewFile {
    if (_pickedPhoto != null) return File(_pickedPhoto!.path);
    if (_removePhoto) return null;
    final path = _existingPhotoPath;
    if (path == null || path.isEmpty) return null;
    return File(path);
  }

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    try {
      final picked = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1200,
        imageQuality: 85,
      );
      if (picked == null) return;
      setState(() {
        _pickedPhoto = picked;
        _removePhoto = false;
      });
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal membuka galeri. Coba lagi.')),
      );
    }
  }

  void _removeSelectedPhoto() {
    setState(() {
      _pickedPhoto = null;
      _removePhoto = true;
    });
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    setState(() => _nisError = null);
    if (!_formKey.currentState!.validate()) return;

    final nis = _nisController.text.trim();
    setState(() => _saving = true);

    try {
      final duplicate = await widget.state.isNisTaken(
        nis,
        excludeId: widget.student?.id,
      );
      if (duplicate) {
        if (!mounted) return;
        setState(() {
          _nisError = 'NIS sudah dipakai siswa lain.';
          _saving = false;
        });
        _formKey.currentState!.validate();
        return;
      }

      String? persistedPhoto;
      var clearPhoto = false;
      if (_pickedPhoto != null) {
        persistedPhoto = await PhotoService.persist(_pickedPhoto!.path);
      } else if (_removePhoto) {
        clearPhoto = true;
      }

      await widget.state.saveStudent(
        existing: widget.student,
        nis: nis,
        name: _nameController.text,
        kelas: _kelas!,
        alamat: _alamatController.text,
        photoPath: persistedPhoto,
        clearPhoto: clearPhoto,
      );

      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal menyimpan data siswa. Coba lagi.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Edit Siswa' : 'Tambah Siswa')),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          border: Border(top: BorderSide(color: scheme.outlineVariant)),
        ),
        child: SafeArea(
          minimum: const EdgeInsets.fromLTRB(20, 10, 20, 16),
          child: FilledButton.icon(
            onPressed: _saving ? null : _save,
            icon: _saving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.check_rounded, size: 20),
            label: Text(
              _saving
                  ? 'Menyimpan...'
                  : _isEditing
                  ? 'Simpan Perubahan'
                  : 'Simpan Data',
            ),
          ),
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
            children: [
              _PhotoCard(
                preview: _previewFile,
                initials: widget.student?.initials ?? '?',
                hasPhoto: _previewFile != null,
                onPick: _pickPhoto,
                onRemove: _previewFile == null ? null : _removeSelectedPhoto,
              ),
              const SizedBox(height: 24),
              Text('Informasi siswa', style: theme.textTheme.titleMedium),
              const SizedBox(height: 4),
              Text(
                'Isi data sesuai kartu pelajar. NIS harus unik.',
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nisController,
                enabled: !_saving,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(20),
                ],
                decoration: InputDecoration(
                  labelText: 'NIS',
                  hintText: 'Contoh: 2024009',
                  prefixIcon: const Icon(Icons.badge_outlined),
                  errorText: _nisError,
                ),
                onChanged: (_) {
                  if (_nisError != null) {
                    setState(() => _nisError = null);
                  }
                },
                validator: (value) {
                  final text = value?.trim() ?? '';
                  if (text.isEmpty) return 'NIS wajib diisi.';
                  if (text.length < 3) return 'NIS minimal 3 digit.';
                  return null;
                },
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _nameController,
                enabled: !_saving,
                textInputAction: TextInputAction.next,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Nama Siswa',
                  hintText: 'Nama lengkap siswa',
                  prefixIcon: Icon(Icons.person_outline_rounded),
                ),
                validator: (value) {
                  final text = value?.trim() ?? '';
                  if (text.isEmpty) return 'Nama siswa wajib diisi.';
                  if (text.length < 3) return 'Nama terlalu pendek.';
                  return null;
                },
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                initialValue: _kelas,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Kelas',
                  prefixIcon: Icon(Icons.school_outlined),
                ),
                hint: const Text('Pilih kelas'),
                items: _classOptions
                    .map(
                      (kelas) =>
                          DropdownMenuItem(value: kelas, child: Text(kelas)),
                    )
                    .toList(),
                onChanged: _saving
                    ? null
                    : (value) => setState(() => _kelas = value),
                validator: (value) =>
                    value == null ? 'Kelas wajib dipilih.' : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _alamatController,
                enabled: !_saving,
                minLines: 3,
                maxLines: 4,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Alamat',
                  hintText: 'Jalan, nomor, kelurahan, kota',
                  prefixIcon: Padding(
                    padding: EdgeInsets.only(bottom: 40),
                    child: Icon(Icons.location_on_outlined),
                  ),
                  alignLabelWithHint: true,
                ),
                validator: (value) {
                  final text = value?.trim() ?? '';
                  if (text.isEmpty) return 'Alamat wajib diisi.';
                  if (text.length < 5) return 'Alamat terlalu pendek.';
                  return null;
                },
              ),
              const SizedBox(height: 22),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: scheme.outlineVariant),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.shield_outlined,
                      size: 18,
                      color: scheme.primary,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Data disimpan di database perangkat dan tetap ada '
                        'walau aplikasi ditutup.',
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PhotoCard extends StatelessWidget {
  const _PhotoCard({
    required this.preview,
    required this.initials,
    required this.hasPhoto,
    required this.onPick,
    required this.onRemove,
  });

  final File? preview;
  final String initials;
  final bool hasPhoto;
  final VoidCallback onPick;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _preview(size: 64),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Foto siswa', style: theme.textTheme.titleSmall),
                    const SizedBox(height: 3),
                    Text(
                      'Opsional, pilih dari galeri.',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onPick,
                  icon: const Icon(Icons.photo_library_outlined, size: 18),
                  label: Text(hasPhoto ? 'Ganti foto' : 'Pilih foto'),
                ),
              ),
              if (onRemove != null) ...[
                const SizedBox(width: 8),
                IconButton(
                  tooltip: 'Hapus foto',
                  onPressed: onRemove,
                  icon: Icon(Icons.delete_outline_rounded, color: scheme.error),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _preview({required double size}) {
    final file = preview;
    if (file == null) {
      if (initials == '?') {
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainer,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.person_outline_rounded,
            size: size * 0.45,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        );
      }
      return SizedBox(
        width: size,
        height: size,
        child: AvatarCircle(label: initials, size: size),
      );
    }
    return SizedBox(
      width: size,
      height: size,
      child: ClipOval(
        child: Image.file(
          file,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => AvatarCircle(label: initials, size: size),
        ),
      ),
    );
  }
}
