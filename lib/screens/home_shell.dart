import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/student.dart';
import '../state/app_state.dart';
import 'dashboard_tab.dart';
import 'profile_tab.dart';
import 'student_form_screen.dart';
import 'students_tab.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key, required this.state});

  final AppState state;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  Future<void> _openForm({Student? student}) async {
    final messenger = ScaffoldMessenger.of(context);
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) =>
            StudentFormScreen(state: widget.state, student: student),
      ),
    );
    if (!mounted || saved != true) return;
    setState(() => _index = 1);
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          student == null
              ? 'Data siswa berhasil ditambahkan.'
              : 'Data siswa berhasil diperbarui.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: Scaffold(
        body: IndexedStack(
          index: _index,
          children: [
            DashboardTab(
              state: widget.state,
              onNavigate: (index) => setState(() => _index = index),
              onAdd: () => _openForm(),
            ),
            StudentsTab(
              state: widget.state,
              onAdd: () => _openForm(),
              onEdit: (student) => _openForm(student: student),
            ),
            ProfileTab(state: widget.state),
          ],
        ),
        floatingActionButton: _index == 2
            ? null
            : FloatingActionButton.extended(
                onPressed: () => _openForm(),
                icon: const Icon(Icons.add_rounded),
                label: const Text('Tambah'),
              ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: scheme.surface,
            border: Border(top: BorderSide(color: scheme.outlineVariant)),
          ),
          child: NavigationBar(
            selectedIndex: _index,
            onDestinationSelected: (index) => setState(() => _index = index),
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.space_dashboard_outlined),
                selectedIcon: Icon(Icons.space_dashboard_rounded),
                label: 'Beranda',
              ),
              NavigationDestination(
                icon: Icon(Icons.groups_outlined),
                selectedIcon: Icon(Icons.groups_rounded),
                label: 'Siswa',
              ),
              NavigationDestination(
                icon: Icon(Icons.person_outline_rounded),
                selectedIcon: Icon(Icons.person_rounded),
                label: 'Profil',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
