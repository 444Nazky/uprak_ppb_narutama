import 'package:flutter/material.dart';

import 'screens/home_shell.dart';
import 'screens/login_screen.dart';
import 'state/app_state.dart';
import 'theme/app_theme.dart';

class DataSiswaApp extends StatelessWidget {
  const DataSiswaApp({super.key, required this.state});

  final AppState state;

  static final ThemeData _lightTheme = AppTheme.light();
  static final ThemeData _darkTheme = AppTheme.dark();

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: state,
      builder: (context, _) {
        return MaterialApp(
          title: 'Data Siswa',
          debugShowCheckedModeBanner: false,
          theme: _lightTheme,
          darkTheme: _darkTheme,
          themeMode: state.themeMode,
          themeAnimationDuration: const Duration(milliseconds: 280),
          home: state.isAuthenticated
              ? HomeShell(state: state)
              : LoginScreen(state: state),
        );
      },
    );
  }
}
