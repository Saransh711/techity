import 'package:flutter/material.dart';

import '../../features/shell/presentation/pages/home_page.dart';
import '../../features/tasks/presentation/pages/task_form_page.dart';
import 'custom_page_route.dart';

/// Named route identifiers.
abstract final class AppRoutes {
  static const home = '/';
  static const taskForm = '/task-form';
}

/// Arguments for [AppRoutes.taskForm] (add when [taskId] is null, edit otherwise).
class TaskFormRouteArgs {
  const TaskFormRouteArgs({this.taskId});

  final String? taskId;

  bool get isEdit => taskId != null;
}

/// Central router — all navigation goes through named routes + [CustomPageRoute].
abstract final class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.taskForm:
        final args = settings.arguments as TaskFormRouteArgs?;
        return CustomPageRoute<bool>(
          settings: settings,
          page: TaskFormPage(taskId: args?.taskId),
        );
      case AppRoutes.home:
        return CustomPageRoute<void>(
          settings: settings,
          page: const HomePage(),
        );
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
    return Navigator.of(context).pushNamed<T>(routeName, arguments: arguments);
  }

  /// Opens the task form in create mode.
  static Future<bool?> pushTaskFormAdd(BuildContext context) {
    return pushNamed<bool>(
      context,
      AppRoutes.taskForm,
      arguments: const TaskFormRouteArgs(),
    );
  }

  /// Opens the task form in edit mode for [taskId].
  static Future<bool?> pushTaskFormEdit(
    BuildContext context, {
    required String taskId,
  }) {
    return pushNamed<bool>(
      context,
      AppRoutes.taskForm,
      arguments: TaskFormRouteArgs(taskId: taskId),
    );
  }

  /// Create when [taskId] is null, edit otherwise.
  static Future<bool?> pushTaskForm(BuildContext context, {String? taskId}) {
    return taskId == null
        ? pushTaskFormAdd(context)
        : pushTaskFormEdit(context, taskId: taskId);
  }

  static void pop<T>(BuildContext context, [T? result]) {
    Navigator.of(context).pop<T>(result);
  }
}
