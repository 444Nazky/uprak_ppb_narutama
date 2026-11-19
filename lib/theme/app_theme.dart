import 'package:flutter/material.dart';

abstract final class AppColors {
  static const blue = Color(0xFF1D4ED8);
  static const blueDark = Color(0xFF1E3A8A);
  static const blueSoft = Color(0xFFDBEAFE);
  static const teal = Color(0xFF0F766E);
  static const amber = Color(0xFFF59E0B);
  static const danger = Color(0xFFDC2626);
  static const success = Color(0xFF15803D);

  static const canvas = Color(0xFFF5F7FB);
  static const surface = Colors.white;
  static const surfaceMuted = Color(0xFFF1F5F9);
  static const ink = Color(0xFF0F172A);
  static const inkMuted = Color(0xFF64748B);
  static const line = Color(0xFFE2E8F0);

  static const darkCanvas = Color(0xFF0B1220);
  static const darkSurface = Color(0xFF111B2E);
  static const darkSurfaceMuted = Color(0xFF18263D);
  static const darkInk = Color(0xFFE6EDF7);
  static const darkInkMuted = Color(0xFF94A3B8);
  static const darkLine = Color(0xFF26344B);
}

abstract final class AppTheme {
  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.blue,
      brightness: Brightness.light,
    ).copyWith(
      primary: AppColors.blue,
      onPrimary: Colors.white,
      primaryContainer: AppColors.blueSoft,
      onPrimaryContainer: const Color(0xFF172554),
      secondary: AppColors.teal,
      onSecondary: Colors.white,
      secondaryContainer: const Color(0xFFCCFBF1),
      onSecondaryContainer: const Color(0xFF134E4A),
      error: AppColors.danger,
      onError: Colors.white,
      errorContainer: const Color(0xFFFEE2E2),
      onErrorContainer: const Color(0xFF7F1D1D),
      surface: AppColors.surface,
      onSurface: AppColors.ink,
      surfaceContainerLowest: Colors.white,
      surfaceContainerLow: const Color(0xFFF8FAFC),
      surfaceContainer: AppColors.surfaceMuted,
      surfaceContainerHigh: const Color(0xFFE8EEF7),
      surfaceContainerHighest: const Color(0xFFDEE7F3),
      outline: const Color(0xFFCBD5E1),
      outlineVariant: AppColors.line,
    );
    return _build(
      scheme: scheme,
      canvas: AppColors.canvas,
      mutedInk: AppColors.inkMuted,
      line: AppColors.line,
      navSurface: Colors.white,
    );
  }

  static ThemeData dark() {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.blue,
      brightness: Brightness.dark,
    ).copyWith(
      primary: const Color(0xFF93C5FD),
      onPrimary: const Color(0xFF0B2A5B),
      primaryContainer: AppColors.blueDark,
      onPrimaryContainer: AppColors.blueSoft,
      secondary: const Color(0xFF5EEAD4),
      onSecondary: const Color(0xFF042F2E),
      secondaryContainer: const Color(0xFF115E59),
      onSecondaryContainer: const Color(0xFFCCFBF1),
      error: const Color(0xFFF87171),
      onError: const Color(0xFF450A0A),
      errorContainer: const Color(0xFF7F1D1D),
      onErrorContainer: const Color(0xFFFEE2E2),
      surface: AppColors.darkSurface,
      onSurface: AppColors.darkInk,
      surfaceContainerLowest: const Color(0xFF080E19),
      surfaceContainerLow: const Color(0xFF0E1728),
      surfaceContainer: AppColors.darkSurfaceMuted,
      surfaceContainerHigh: const Color(0xFF1E2E48),
      surfaceContainerHighest: const Color(0xFF273A57),
      outline: const Color(0xFF3B4C66),
      outlineVariant: AppColors.darkLine,
    );
    return _build(
      scheme: scheme,
      canvas: AppColors.darkCanvas,
      mutedInk: AppColors.darkInkMuted,
      line: AppColors.darkLine,
      navSurface: AppColors.darkSurface,
    );
  }

  static ThemeData _build({
    required ColorScheme scheme,
    required Color canvas,
    required Color mutedInk,
    required Color line,
    required Color navSurface,
  }) {
    final base = ThemeData(
      useMaterial3: true,
      fontFamily: 'PlusJakartaSans',
      colorScheme: scheme,
      scaffoldBackgroundColor: canvas,
      splashFactory: InkSparkle.splashFactory,
    );

    final text = base.textTheme.copyWith(
      displayLarge: base.textTheme.displayLarge?.copyWith(
        fontSize: 40,
        fontWeight: FontWeight.w800,
        letterSpacing: -1.4,
        height: 1.1,
      ),
      displaySmall: base.textTheme.displaySmall?.copyWith(
        fontSize: 32,
        fontWeight: FontWeight.w800,
        letterSpacing: -1,
        height: 1.15,
      ),
      headlineMedium: base.textTheme.headlineMedium?.copyWith(
        fontSize: 26,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.8,
        height: 1.2,
      ),
      headlineSmall: base.textTheme.headlineSmall?.copyWith(
        fontSize: 21,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.4,
      ),
      titleLarge: base.textTheme.titleLarge?.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.2,
      ),
      titleMedium: base.textTheme.titleMedium?.copyWith(
        fontSize: 15,
        fontWeight: FontWeight.w700,
      ),
      titleSmall: base.textTheme.titleSmall?.copyWith(
        fontSize: 13,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: base.textTheme.bodyLarge?.copyWith(
        fontSize: 15,
        height: 1.55,
        fontWeight: FontWeight.w400,
      ),
      bodyMedium: base.textTheme.bodyMedium?.copyWith(
        fontSize: 13.5,
        height: 1.5,
        fontWeight: FontWeight.w400,
      ),
      bodySmall: base.textTheme.bodySmall?.copyWith(
        fontSize: 12,
        height: 1.45,
        fontWeight: FontWeight.w400,
        color: mutedInk,
      ),
      labelLarge: base.textTheme.labelLarge?.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.1,
      ),
      labelMedium: base.textTheme.labelMedium?.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
    );

    final inputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: line),
    );

    return base.copyWith(
      textTheme: text,
      appBarTheme: AppBarThemeData(
        backgroundColor: canvas,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: text.titleLarge,
        iconTheme: IconThemeData(color: scheme.onSurface, size: 22),
        actionsIconTheme: IconThemeData(color: scheme.onSurface, size: 22),
      ),
      cardTheme: CardThemeData(
        color: scheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: line),
        ),
      ),
      inputDecorationTheme: InputDecorationThemeData(
        filled: true,
        fillColor: scheme.surfaceContainerLow,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        hintStyle: TextStyle(color: mutedInk, fontWeight: FontWeight.w400),
        labelStyle: TextStyle(color: mutedInk, fontWeight: FontWeight.w500),
        prefixIconColor: mutedInk,
        suffixIconColor: mutedInk,
        border: inputBorder,
        enabledBorder: inputBorder,
        focusedBorder: inputBorder.copyWith(
          borderSide: BorderSide(color: scheme.primary, width: 1.6),
        ),
        errorBorder: inputBorder.copyWith(
          borderSide: BorderSide(color: scheme.error),
        ),
        focusedErrorBorder: inputBorder.copyWith(
          borderSide: BorderSide(color: scheme.error, width: 1.6),
        ),
        errorStyle: TextStyle(
          color: scheme.error,
          fontWeight: FontWeight.w500,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          textStyle: text.labelLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          textStyle: text.labelLarge,
          foregroundColor: scheme.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, 48),
          foregroundColor: scheme.onSurface,
          side: BorderSide(color: line),
          textStyle: text.labelLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: navSurface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: scheme.primaryContainer,
        elevation: 0,
        height: 68,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return text.labelMedium?.copyWith(
            color: selected ? scheme.primary : mutedInk,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            size: 23,
            color: selected ? scheme.primary : mutedInk,
          );
        }),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: scheme.surface,
        selectedColor: scheme.primaryContainer,
        side: BorderSide(color: line),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(999),
        ),
        labelStyle: text.labelMedium!.copyWith(color: scheme.onSurface),
        secondaryLabelStyle: text.labelMedium!.copyWith(
          color: scheme.onPrimaryContainer,
          fontWeight: FontWeight.w700,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        showCheckmark: false,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        elevation: 2,
        focusElevation: 3,
        hoverElevation: 3,
        highlightElevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        extendedTextStyle: text.labelLarge,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: scheme.brightness == Brightness.light
            ? const Color(0xFF0F172A)
            : const Color(0xFFE2E8F0),
        contentTextStyle: text.bodyMedium?.copyWith(
          color: scheme.brightness == Brightness.light
              ? Colors.white
              : const Color(0xFF0F172A),
        ),
        actionTextColor: scheme.brightness == Brightness.light
            ? const Color(0xFF93C5FD)
            : AppColors.blue,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        titleTextStyle: text.headlineSmall,
        contentTextStyle: text.bodyMedium?.copyWith(color: mutedInk),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: scheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: line),
        ),
        textStyle: text.bodyMedium,
      ),
      dividerTheme: DividerThemeData(color: line, thickness: 1, space: 1),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: scheme.primary,
      ),
    );
  }
}
