/// Hive type IDs, box names, and preference keys.
abstract final class AppKeys {
  // Hive type IDs
  static const taskTypeId = 0;
  static const categoryTypeId = 1;
  static const filterStateTypeId = 2;

  // Hive box names
  static const tasksBox = 'tasks_box';
  static const categoriesBox = 'categories_box';
  static const settingsBox = 'settings_box';
  static const filtersBox = 'filters_box';

  // Settings preference keys
  static const themeModeKey = 'theme_mode';
  static const sortOrderKey = 'sort_order';
  static const activeFilterKey = 'active_filter';
  static const activeFilterV2Key = 'active_filter_v2';

  // Local notifications
  static const reminderChannelId = 'task_reminders';
}
