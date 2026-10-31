import 'package:flutter/material.dart';

abstract final class AppColors {
  static const primary = Color(0xFF3B63EC);
  static const primaryDark = Color(0xFF2949B8);
  static const primaryLight = Color(0xFFEAF0FF);
  static const background = Color(0xFFF7F8FC);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceMuted = Color(0xFFF1F4F8);
  static const textPrimary = Color(0xFF151B2B);
  static const textSecondary = Color(0xFF7B8495);
  static const textMuted = Color(0xFFA5ADBA);
  static const border = Color(0xFFE7EBF2);
  static const disabled = Color(0xFFAFC1F2);
  static const success = Color(0xFF368A62);
  static const successLight = Color(0xFFEAF8F0);
  static const warningLight = Color(0xFFFFF8E5);
  static const warningText = Color(0xFF795B12);
  static const error = Color(0xFFB54745);
}

abstract final class AppSpacing {
  static const double xSmall = 8;
  static const double small = 12;
  static const double medium = 16;
  static const double large = 24;
  static const double xLarge = 32;
  static const double xxLarge = 40;
}

abstract final class AppRadius {
  static const small = 16.0;
  static const standard = 22.0;
  static const button = 20.0;
}

class AppTheme {
  static ThemeData get light {
    final colorScheme =
        ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          surface: AppColors.surface,
        ).copyWith(
          primary: AppColors.primary,
          onPrimary: Colors.white,
          surface: AppColors.surface,
          onSurface: AppColors.textPrimary,
          error: AppColors.error,
        );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.background,
      fontFamily: 'Inter',
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 30,
          fontWeight: FontWeight.w700,
          height: 1.2,
        ),
        headlineMedium: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 24,
          fontWeight: FontWeight.w700,
          height: 1.25,
        ),
        titleLarge: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 19,
          fontWeight: FontWeight.w700,
        ),
        titleMedium: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 16,
          height: 1.45,
        ),
        bodyMedium: TextStyle(
          color: AppColors.textSecondary,
          fontSize: 14,
          height: 1.45,
        ),
        labelLarge: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.small),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.small),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.small),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.small),
          borderSide: const BorderSide(color: AppColors.error),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.primaryLight,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            color: selected ? AppColors.primary : AppColors.textSecondary,
            fontSize: 12,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
          );
        }),
      ),
    );
  }
}
