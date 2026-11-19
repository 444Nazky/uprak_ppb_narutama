import 'package:data_siswa/data/session_store.dart';
import 'package:data_siswa/data/sqlite_siswa_repository.dart';
import 'package:data_siswa/screens/login_screen.dart';
import 'package:data_siswa/screens/root_shell.dart';
import 'package:data_siswa/services/notifikasi_service.dart';
import 'package:data_siswa/state/app_state.dart';
import 'package:data_siswa/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

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
