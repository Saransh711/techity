import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';
import 'app_spacing.dart';
import 'app_typography.dart';

/// Builds [ThemeData] for light and dark modes from core tokens only.
abstract final class AppTheme {
  static ThemeData get lightTheme => _buildTheme(Brightness.light);

  static ThemeData get darkTheme => _buildTheme(Brightness.dark);

  static ThemeData _buildTheme(Brightness brightness) {
    final isLight = brightness == Brightness.light;
    final colorScheme = isLight ? _lightColorScheme : _darkColorScheme;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,
      textTheme: AppTypography.textThemeForBrightness(brightness),
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        systemOverlayStyle: isLight
            ? SystemUiOverlayStyle.dark
            : SystemUiOverlayStyle.light,
        titleTextStyle: AppTypography.textThemeForBrightness(
          brightness,
        ).titleLarge?.copyWith(color: colorScheme.onSurface),
      ),
      cardTheme: CardThemeData(
        color: colorScheme.surfaceContainerHighest,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.sm),
          side: BorderSide(color: colorScheme.outlineVariant),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 2,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: isLight
            ? AppColors.lightOnSurface
            : AppColors.darkSurfaceVariant,
        contentTextStyle: AppTypography.textThemeForBrightness(brightness)
            .bodyMedium
            ?.copyWith(
              color: isLight ? AppColors.lightSurface : AppColors.darkOnSurface,
            ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.sm),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: colorScheme.outlineVariant,
        thickness: 1,
        space: 1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest,
        contentPadding: AppSpacing.listItemPadding,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.sm),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.sm),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.sm),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.sm),
          borderSide: const BorderSide(color: AppColors.danger),
        ),
      ),
    );
  }

  static final ColorScheme _lightColorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: AppColors.primary,
    onPrimary: AppColors.onPrimary,
    secondary: AppColors.info,
    onSecondary: AppColors.onInfo,
    error: AppColors.danger,
    onError: AppColors.onDanger,
    surface: AppColors.lightBackground,
    onSurface: AppColors.lightOnSurface,
    surfaceContainerHighest: AppColors.lightSurface,
    onSurfaceVariant: AppColors.lightOnSurfaceVariant,
    outline: AppColors.lightOutline,
    outlineVariant: AppColors.lightDivider,
  );

  static final ColorScheme _darkColorScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: AppColors.primary,
    onPrimary: AppColors.onPrimary,
    secondary: AppColors.info,
    onSecondary: AppColors.onInfo,
    error: AppColors.danger,
    onError: AppColors.onDanger,
    surface: AppColors.darkBackground,
    onSurface: AppColors.darkOnSurface,
    surfaceContainerHighest: AppColors.darkSurface,
    onSurfaceVariant: AppColors.darkOnSurfaceVariant,
    outline: AppColors.darkOutline,
    outlineVariant: AppColors.darkDivider,
  );
}
