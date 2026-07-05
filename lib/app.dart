import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/constants/app_strings.dart';
import 'core/di/injection.dart';
import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/settings/domain/entities/app_theme_preference.dart';
import 'features/settings/presentation/bloc/theme_bloc.dart';
import 'features/settings/presentation/bloc/theme_event.dart';
import 'features/settings/presentation/bloc/theme_state.dart';

/// Root widget configured with the theme resolved before first frame.
class App extends StatelessWidget {
  const App({
    required this.initialThemeMode,
    required this.initialThemePreference,
    super.key,
  });

  final ThemeMode initialThemeMode;
  final AppThemePreference initialThemePreference;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) =>
              getIt<ThemeBloc>(param1: initialThemePreference)
                ..add(const LoadTheme()),
        ),
      ],
      child: BlocBuilder<ThemeBloc, ThemeState>(
        buildWhen: (previous, current) =>
            current is ThemeLoaded || current is ThemeFailure,
        builder: (context, state) {
          final themeMode = switch (state) {
            ThemeLoaded(themeMode: final mode) => mode,
            _ => initialThemeMode,
          };

          return MaterialApp(
            title: AppStrings.appTitle,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeMode,
            initialRoute: AppRoutes.home,
            onGenerateRoute: AppRouter.onGenerateRoute,
          );
        },
      ),
    );
  }
}
