import 'package:flutter/material.dart';

/// Semantic color tokens for light and dark palettes.
abstract final class AppColors {
  // Brand
  static const primary = Color(0xFF2563EB);
  static const primaryDark = Color(0xFF1D4ED8);
  static const onPrimary = Color(0xFFFFFFFF);

  // Light palette
  static const lightBackground = Color(0xFFF8FAFC);
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightSurfaceVariant = Color(0xFFF1F5F9);
  static const lightOnBackground = Color(0xFF0F172A);
  static const lightOnSurface = Color(0xFF1E293B);
  static const lightOnSurfaceVariant = Color(0xFF64748B);
  static const lightOutline = Color(0xFFCBD5E1);
  static const lightDivider = Color(0xFFE2E8F0);

  // Dark palette
  static const darkBackground = Color(0xFF0F172A);
  static const darkSurface = Color(0xFF1E293B);
  static const darkSurfaceVariant = Color(0xFF334155);
  static const darkOnBackground = Color(0xFFF8FAFC);
  static const darkOnSurface = Color(0xFFE2E8F0);
  static const darkOnSurfaceVariant = Color(0xFF94A3B8);
  static const darkOutline = Color(0xFF475569);
  static const darkDivider = Color(0xFF334155);

  // Semantic
  static const success = Color(0xFF16A34A);
  static const onSuccess = Color(0xFFFFFFFF);
  static const warning = Color(0xFFF59E0B);
  static const onWarning = Color(0xFF0F172A);
  static const danger = Color(0xFFDC2626);
  static const onDanger = Color(0xFFFFFFFF);
  static const info = Color(0xFF0EA5E9);
  static const onInfo = Color(0xFFFFFFFF);

  // Misc
  static const scrim = Color(0x99000000);
  static const shadow = Color(0x1A000000);
}
