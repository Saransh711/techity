import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/app_theme_preference.dart';

sealed class ThemeState extends Equatable {
  const ThemeState();

  @override
  List<Object?> get props => [];
}

final class ThemeInitial extends ThemeState {
  const ThemeInitial();
}

final class ThemeLoaded extends ThemeState {
  const ThemeLoaded({required this.preference, required this.themeMode});

  final AppThemePreference preference;
  final ThemeMode themeMode;

  @override
  List<Object?> get props => [preference, themeMode];
}

final class ThemeFailure extends ThemeState {
  const ThemeFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
