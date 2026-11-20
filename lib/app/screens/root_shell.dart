import 'package:data_siswa/app/models/siswa.dart';
import 'package:data_siswa/app/screens/dashboard_screen.dart';
import 'package:data_siswa/app/screens/profile_screen.dart';
import 'package:data_siswa/app/screens/student_form_screen.dart';
import 'package:data_siswa/app/screens/student_list_screen.dart';
import 'package:data_siswa/app/state/app_state.dart';
import 'package:data_siswa/app/widgets/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Kerangka utama setelah login: tiga tab dan tombol tambah data.
class RootShell extends StatefulWidget {
  const RootShell({super.key});

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  int _tab = 0;

  Future<void> _bukaForm([Siswa? siswa]) async {
    final hasil = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => StudentFormScreen(siswa: siswa)),
    );
    if (hasil == true && mounted) {
      tampilkanPesan(
        context,
        siswa == null
            ? 'Data siswa berhasil ditambahkan.'
            : 'Perubahan data tersimpan.',
      );
    }
  }

  void _pilihKelas(String kelas) {
    AppScope.baca(context).saringKelas(kelas);
    setState(() => _tab = 1);
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final state = AppScope.of(context);

    final gayaSistem = (tema.brightness == Brightness.dark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark)
        .copyWith(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness:
          tema.brightness == Brightness.dark ? Brightness.light : Brightness.dark,
      systemNavigationBarColor: tema.colorScheme.surface,
      systemNavigationBarIconBrightness:
          tema.brightness == Brightness.dark ? Brightness.light : Brightness.dark,
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: gayaSistem,
      child: Scaffold(
      body: IndexedStack(
        index: _tab,
        children: [
          DashboardScreen(
            onBukaData: () => setState(() => _tab = 1),
            onPilihKelas: _pilihKelas,
            onTambah: () => _bukaForm(),
            onUbah: (siswa) => _bukaForm(siswa),
            onBukaProfil: () => setState(() => _tab = 2),
          ),
          StudentListScreen(
            onTambah: () => _bukaForm(),
            onUbah: (siswa) => _bukaForm(siswa),
          ),
          const ProfileScreen(),
        ],
      ),
      floatingActionButton: _tab == 2
          ? null
          : _tab == 1
              ? FloatingActionButton(
                  onPressed: () => _bukaForm(),
                  tooltip: 'Tambah data siswa',
                  child: const Icon(Icons.add_rounded, size: 28),
                )
              : FloatingActionButton.extended(
                  onPressed: () => _bukaForm(),
                  icon: const Icon(Icons.add_rounded, size: 22),
                  label: const Text('Tambah'),
                  tooltip: 'Tambah data siswa',
                  extendedPadding: const EdgeInsets.symmetric(horizontal: 18),
                ),
      bottomNavigationBar: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: tema.colorScheme.outline)),
        ),
        child: NavigationBar(
          selectedIndex: _tab,
          onDestinationSelected: (index) => setState(() => _tab = index),
          destinations: [
            const NavigationDestination(
              icon: Icon(Icons.space_dashboard_outlined),
              selectedIcon: Icon(Icons.space_dashboard_rounded),
              label: 'Beranda',
            ),
            NavigationDestination(
              icon: Badge(
                isLabelVisible: state.totalSiswa > 0,
                label: Text('${state.totalSiswa}'),
                backgroundColor: tema.colorScheme.primary,
                textColor: tema.colorScheme.onPrimary,
                child: const Icon(Icons.groups_outlined),
              ),
              selectedIcon: Badge(
                isLabelVisible: state.totalSiswa > 0,
                label: Text('${state.totalSiswa}'),
                backgroundColor: tema.colorScheme.primary,
                textColor: tema.colorScheme.onPrimary,
                child: const Icon(Icons.groups_rounded),
              ),
              label: 'Data Siswa',
            ),
            const NavigationDestination(
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
