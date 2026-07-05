import 'package:flutter/material.dart';

import '../../features/shell/presentation/pages/home_page.dart';
import '../../features/tasks/presentation/pages/task_form_page.dart';
import 'custom_page_route.dart';

/// Named route identifiers.
abstract final class AppRoutes {
  static const home = '/';
  static const taskForm = '/task-form';
}

/// Arguments for [AppRoutes.taskForm].
class TaskFormRouteArgs {
  const TaskFormRouteArgs({this.taskId});

  final String? taskId;
}

/// Central router for named navigation with custom transitions.
abstract final class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.taskForm:
        final args = settings.arguments as TaskFormRouteArgs?;
        return CustomPageRoute<void>(
          settings: settings,
          page: TaskFormPage(taskId: args?.taskId),
        );
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

  static Future<bool?> pushTaskForm(
    BuildContext context, {
    String? taskId,
  }) {
    return pushNamed<bool>(
      context,
      AppRoutes.taskForm,
      arguments: TaskFormRouteArgs(taskId: taskId),
    );
  }
}
