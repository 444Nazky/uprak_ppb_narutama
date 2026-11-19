import 'package:data_siswa/app/data/session_store.dart';
import 'package:data_siswa/app/data/sqlite_siswa_repository.dart';
import 'package:data_siswa/app/screens/login_screen.dart';
import 'package:data_siswa/app/screens/root_shell.dart';
import 'package:data_siswa/app/services/notifikasi_service.dart';
import 'package:data_siswa/app/state/app_state.dart';
import 'package:data_siswa/app/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';

/// Titik masuk aplikasi: siapkan sesi, database, lalu tampilkan layar login
/// atau dashboard sesuai status sesi.
Future<void> jalankanAplikasi() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await initializeDateFormatting('id_ID');

  final state = AppState(SqliteSiswaRepository(), SessionStore());
  await state.init();
  await NotifikasiService.init();

  runApp(DataSiswaApp(state: state));
}

class DataSiswaApp extends StatelessWidget {
  const DataSiswaApp({super.key, required this.state});

  final AppState state;

  @override
  Widget build(BuildContext context) {
    return AppScope(
      state: state,
      child: AnimatedBuilder(
        animation: state,
        builder: (context, _) {
          return MaterialApp(
            title: 'Aplikasi Data Siswa',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            themeMode: state.tema,
            home: AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              child: state.sudahLogin
                  ? const RootShell(key: ValueKey('shell'))
                  : const LoginScreen(key: ValueKey('login')),
            ),
          );
        },
      ),
    );
  }
}
