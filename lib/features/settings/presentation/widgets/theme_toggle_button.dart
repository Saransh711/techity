import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_strings.dart';
import '../../domain/entities/app_theme_preference.dart';
import '../bloc/theme_bloc.dart';
import '../bloc/theme_event.dart';
import '../bloc/theme_state.dart';

/// App-bar control that toggles between light and dark theme.
class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      buildWhen: (previous, current) =>
          previous.runtimeType != current.runtimeType ||
          (previous is ThemeLoaded &&
              current is ThemeLoaded &&
              previous.preference != current.preference),
      builder: (context, state) {
        final preference = switch (state) {
          ThemeLoaded(preference: final value) => value,
          _ => AppThemePreference.system,
        };

        final isDark = switch (preference) {
          AppThemePreference.dark => true,
          AppThemePreference.light => false,
          AppThemePreference.system =>
            MediaQuery.platformBrightnessOf(context) == Brightness.dark,
        };

        return IconButton(
          tooltip: AppStrings.theme,
          onPressed: () => context.read<ThemeBloc>().add(const ToggleTheme()),
          icon: Icon(
            isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
          ),
        );
      },
    );
  }
}
