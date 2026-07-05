import 'package:flutter/material.dart';

import '../../features/shell/presentation/pages/home_page.dart';
import 'custom_page_route.dart';

/// Named route identifiers.
abstract final class AppRoutes {
  static const home = '/';
}

/// Central router for named navigation with custom transitions.
abstract final class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.home:
      default:
        return CustomPageRoute<void>(
          settings: settings,
          page: const HomePage(),
        );
    }
  }

  static Future<T?> pushNamed<T>(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    return Navigator.of(context).pushNamed<T>(
      routeName,
      arguments: arguments,
    );
  }
}
