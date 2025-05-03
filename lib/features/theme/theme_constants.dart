import 'package:flutter/material.dart';

class AppTheme {
  static const double borderRadius = 12.0;
  static const double spacing = 16.0;

  static final ColorScheme colorScheme = ColorScheme.light(
    primary: const Color(0xFF1565C0),
    primaryContainer: const Color(0xFFE3F2FD),
    secondary: const Color(0xFF2E7D32),
    secondaryContainer: const Color(0xFFE8F5E9),
    surface: Colors.white,
    background: const Color(0xFFF5F5F5),
    error: const Color(0xFFD32F2F),
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onSurface: Colors.black87,
    onBackground: Colors.black87,
    onError: Colors.white,
  );

  static final gradients = _AppGradients();
  static final elevations = _AppElevations();

  static ThemeData get theme => ThemeData(
        useMaterial3: true,
        colorScheme: colorScheme,
        scaffoldBackgroundColor: colorScheme.background,
        cardTheme: CardTheme(
          elevation: elevations.card,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
        tabBarTheme: TabBarTheme(
          labelColor: colorScheme.primary,
          unselectedLabelColor: Colors.grey[600],
          indicatorSize: TabBarIndicatorSize.label,
          dividerColor: Colors.transparent,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 14,
          ),
        ),
      );
}

class _AppGradients {
  final LinearGradient primaryGradient = const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1976D2), Color(0xFF1565C0)],
  );

  final LinearGradient successGradient = const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
  );

  final LinearGradient errorGradient = const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFE53935), Color(0xFFC62828)],
  );
}

class _AppElevations {
  final double card = 1.0;
  final double dialog = 8.0;
  final double drawer = 16.0;
}
