import 'package:flutter/material.dart';

import '../models/student.dart';
import '../state/app_state.dart';
import '../utils/export_helper.dart';
import '../widgets/avatar_circle.dart';
import '../widgets/empty_state.dart';

class StudentsTab extends StatefulWidget {
  const StudentsTab({
    super.key,
    required this.state,
    required this.onAdd,
    required this.onEdit,
  });

  final AppState state;
  final VoidCallback onAdd;
  final ValueChanged<Student> onEdit;

  @override
  State<StudentsTab> createState() => _StudentsTabState();
}

class _StudentsTabState extends State<StudentsTab> {
  final _searchController = TextEditingController();
  String _query = '';
  String _selectedClass = 'Semua';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String get _effectiveClass {
    if (_selectedClass == 'Semua') return 'Semua';
    return widget.state.classes.contains(_selectedClass)
        ? _selectedClass
        : 'Semua';
  }

  List<Student> get _filtered {
    final query = _query.trim().toLowerCase();
    return widget.state.students.where((student) {
      final matchClass =
          _effectiveClass == 'Semua' || student.kelas == _effectiveClass;
      if (!matchClass) return false;
      if (query.isEmpty) return true;
      return student.name.toLowerCase().contains(query) ||
          student.nis.toLowerCase().contains(query) ||
          student.alamat.toLowerCase().contains(query);
    }).toList();
  }

  void _resetFilters() {
    _searchController.clear();
    setState(() {
      _query = '';
      _selectedClass = 'Semua';
    });
  }

  Future<void> _confirmDelete(Student student) async {
    final messenger = ScaffoldMessenger.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        final scheme = Theme.of(dialogContext).colorScheme;
        return AlertDialog(
          icon: Icon(
            Icons.delete_outline_rounded,
            color: scheme.error,
            size: 28,
          ),
          title: const Text('Hapus data siswa?'),
          content: Text(
            'Data ${student.name} dengan NIS ${student.nis} akan dihapus '
            'permanen dan tidak bisa dikembalikan.',
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
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;
    try {
      await widget.state.deleteStudent(student);
      messenger.showSnackBar(
        SnackBar(content: Text('Data ${student.name} dihapus.')),
      );
    } catch (_) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Gagal menghapus data. Coba lagi.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final students = _filtered;
    final classes = widget.state.classes;

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Data Siswa', style: theme.textTheme.headlineSmall),
                      const SizedBox(height: 2),
                      Text(
                        '${widget.state.totalStudents} siswa terdaftar',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                IconButton.outlined(
                  tooltip: 'Export PDF',
                  onPressed: () => exportStudentsPdf(
                    context,
                    students,
                    filterLabel: _effectiveClass == 'Semua'
                        ? null
                        : _effectiveClass,
                  ),
                  icon: const Icon(Icons.picture_as_pdf_outlined, size: 20),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _query = value),
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Cari nama, NIS, atau alamat',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _query.isEmpty
                    ? null
                    : IconButton(
                        tooltip: 'Hapus pencarian',
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _query = '');
                        },
                        icon: const Icon(Icons.close_rounded),
                      ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _ClassChip(
                    label: 'Semua',
                    selected: _effectiveClass == 'Semua',
                    onTap: () => setState(() => _selectedClass = 'Semua'),
                  ),
                  ...classes.map(
                    (kelas) => Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: _ClassChip(
                        label: kelas,
                        selected: _effectiveClass == kelas,
                        onTap: () => setState(() => _selectedClass = kelas),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: students.isEmpty
                  ? ListView(
                      padding: const EdgeInsets.only(bottom: 120),
                      children: [
                        const SizedBox(height: 20),
                        if (widget.state.students.isEmpty)
                          EmptyState(
                            icon: Icons.groups_2_outlined,
                            title: 'Belum ada data siswa',
                            message:
                                'Tambahkan siswa pertama, atau isi data '
                                'contoh untuk mencoba aplikasi.',
                            action: FilledButton.icon(
                              onPressed: widget.onAdd,
                              icon: const Icon(Icons.add_rounded),
                              label: const Text('Tambah siswa'),
                              style: FilledButton.styleFrom(
                                minimumSize: const Size(0, 46),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                ),
                              ),
                            ),
                            secondaryAction: TextButton(
                              onPressed: () => widget.state.seedSampleData(),
                              child: const Text('Isi data contoh'),
                            ),
                          )
                        else
                          EmptyState(
                            icon: Icons.search_off_rounded,
                            title: 'Siswa tidak ditemukan',
                            message:
                                'Tidak ada data yang cocok dengan pencarian '
                                'atau filter kelas yang dipilih.',
                            action: OutlinedButton(
                              onPressed: _resetFilters,
                              child: const Text('Reset pencarian'),
                            ),
                          ),
                      ],
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.only(top: 8, bottom: 120),
                      itemCount: students.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final student = students[index];
                        return _StudentCard(
                          student: student,
                          onTap: () => widget.onEdit(student),
                          onEdit: () => widget.onEdit(student),
                          onDelete: () => _confirmDelete(student),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ClassChip extends StatelessWidget {
  const _ClassChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Material(
      color: selected ? scheme.primaryContainer : scheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(999),
        side: BorderSide(
          color: selected ? scheme.primary : scheme.outlineVariant,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: selected ? scheme.onPrimaryContainer : scheme.onSurface,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class _StudentCard extends StatelessWidget {
  const _StudentCard({
    required this.student,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  final Student student;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Material(
      color: scheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: scheme.outlineVariant),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 6, 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AvatarCircle(
                label: student.initials,
                photoPath: student.photoPath,
                size: 50,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: Text(
                        student.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontSize: 14.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 7),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        _Tag(
                          label: 'NIS ${student.nis}',
                          background: scheme.surfaceContainer,
                          foreground: scheme.onSurfaceVariant,
                        ),
                        _Tag(
                          label: student.kelas,
                          background: scheme.primaryContainer,
                          foreground: scheme.onPrimaryContainer,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 14,
                          color: scheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            student.alamat,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall,
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
                  color: scheme.onSurfaceVariant,
                ),
                onSelected: (value) {
                  if (value == 'edit') onEdit();
                  if (value == 'delete') onDelete();
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit_outlined, size: 19),
                        SizedBox(width: 10),
                        Text('Edit'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(
                          Icons.delete_outline_rounded,
                          size: 19,
                          color: scheme.error,
                        ),
                        const SizedBox(width: 10),
                        Text('Hapus', style: TextStyle(color: scheme.error)),
                      ],
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
}

class _Tag extends StatelessWidget {
  const _Tag({
    required this.label,
    required this.background,
    required this.foreground,
  });

  final String label;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(7),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelMedium?.copyWith(
          fontSize: 11,
          color: foreground,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
