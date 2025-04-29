import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:shared_preferences/shared_preferences.dart';

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>(
  (ref) => ThemeNotifier(),
);

class ThemeNotifier extends StateNotifier<ThemeMode> {
  ThemeNotifier() : super(ThemeMode.system) {
    _loadThemeMode();
  }

  static const _themePreferenceKey = 'theme_mode';

  Future<void> _loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final themeIndex = prefs.getInt(_themePreferenceKey);
    if (themeIndex != null) {
      state = ThemeMode.values[themeIndex];
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themePreferenceKey, mode.index);
    state = mode;
  }

  Future<void> toggleTheme() async {
    final newMode = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    await setThemeMode(newMode);
  }

  // Get theme data for light mode
  static ThemeData get lightTheme {
    final customScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF6AB19B),
      primary: const Color(0xFF6AB19B),
      secondary: const Color(0xFF7DCFB6),
    );

    return FlexThemeData.light(
      colors: FlexSchemeColor(
        primary: const Color(0xFF6AB19B),
        primaryContainer: const Color(0xFF6AB19B).withOpacity(0.9),
        secondary: const Color(0xFF7DCFB6),
        secondaryContainer: const Color(0xFF7DCFB6).withOpacity(0.9),
      ),
      surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
      blendLevel: 20,
      subThemesData: const FlexSubThemesData(
        blendOnLevel: 20,
        blendOnColors: false,
        useTextTheme: true,
        useM2StyleDividerInM3: true,
        alignedDropdown: true,
        useInputDecoratorThemeInDialogs: true,
        cardRadius: 12.0,
        elevatedButtonRadius: 8.0,
        tooltipRadius: 4.0,
        popupMenuRadius: 8.0,
        dialogRadius: 20.0,
      ),
      keyColors: const FlexKeyColors(
        useSecondary: true,
        useTertiary: true,
      ),
      visualDensity: FlexColorScheme.comfortablePlatformDensity,
      useMaterial3: true,
      swapLegacyOnMaterial3: true,
    ).copyWith(
      colorScheme: customScheme,
    );
  }

  // Get theme data for dark mode
  static ThemeData get darkTheme {
    final customDarkScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF6AB19B),
      primary: const Color(0xFF6AB19B),
      secondary: const Color(0xFF7DCFB6),
      brightness: Brightness.dark,
    );

    return FlexThemeData.dark(
      colors: FlexSchemeColor(
        primary: const Color(0xFF6AB19B),
        primaryContainer: const Color(0xFF6AB19B).withOpacity(0.85),
        secondary: const Color(0xFF7DCFB6),
        secondaryContainer: const Color(0xFF7DCFB6).withOpacity(0.85),
      ),
      surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
      blendLevel: 15,
      subThemesData: const FlexSubThemesData(
        blendOnLevel: 20,
        useTextTheme: true,
        useM2StyleDividerInM3: true,
        alignedDropdown: true,
        useInputDecoratorThemeInDialogs: true,
        cardRadius: 12.0,
        elevatedButtonRadius: 8.0,
        tooltipRadius: 4.0,
        popupMenuRadius: 8.0,
        dialogRadius: 20.0,
      ),
      keyColors: const FlexKeyColors(
        useSecondary: true,
        useTertiary: true,
      ),
      visualDensity: FlexColorScheme.comfortablePlatformDensity,
      useMaterial3: true,
      swapLegacyOnMaterial3: true,
    ).copyWith(
      colorScheme: customDarkScheme,
    );
  }
}
