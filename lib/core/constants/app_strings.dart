/// Central registry for all user-visible strings.
abstract final class AppStrings {
  // App
  static const appTitle = 'Task Manager Pro';

  // Navigation
  static const home = 'Home';
  static const settings = 'Settings';
  static const categories = 'Categories';
  static const filters = 'Filters';

  // Tasks
  static const tasks = 'Tasks';
  static const addTask = 'Add Task';
  static const editTask = 'Edit Task';
  static const deleteTask = 'Delete Task';
  static const taskTitle = 'Title';
  static const taskDescription = 'Description';
  static const taskDueDate = 'Due Date';
  static const noDueDate = 'No due date';
  static const taskCategory = 'Category';
  static const taskCompleted = 'Completed';
  static const taskPending = 'Pending';
  static const noTasks = 'No tasks yet';
  static const noTasksSubtitle = 'Tap + to create your first task';
  static const searchTasks = 'Search tasks';
  static const markComplete = 'Mark complete';
  static const markIncomplete = 'Mark incomplete';
  static const reorderTasks = 'Reorder tasks';
  static const todayProgress = "Today's progress";

  // Categories (fixed presets — extensible via [CategoryConstants] IDs)
  static const categoryWork = 'Work';
  static const categoryPersonal = 'Personal';
  static const categoryUrgent = 'Urgent';
  static const categoryAll = 'All categories';
  static const categoryName = 'Category name';
  static const noCategories = 'No categories yet';
  static const addCategory = 'Add Category';
  static const editCategory = 'Edit Category';
  static const deleteCategory = 'Delete Category';
  static const filterAll = 'All';
  static const filterToday = 'Today';
  static const filterOverdue = 'Overdue';
  static const filterCompleted = 'Done';
  static const filterPending = 'Pending';
  static const filterPickDate = 'Pick date';
  static const filterStatus = 'Status';
  static const filterDueDate = 'Due date';
  static const sortByDueDate = 'Due date';
  static const sortByCreated = 'Created';
  static const sortByManual = 'Manual order';
  static const clearFilters = 'Clear filters';

  // Settings
  static const theme = 'Theme';
  static const themeLight = 'Light';
  static const themeDark = 'Dark';
  static const themeSystem = 'System default';

  // Actions
  static const save = 'Save';
  static const cancel = 'Cancel';
  static const delete = 'Delete';
  static const undo = 'Undo';
  static const retry = 'Retry';
  static const close = 'Close';
  static const confirm = 'Confirm';

  // Snackbars
  static const taskCreated = 'Task created';
  static const taskUpdated = 'Task updated';
  static const taskDeleted = 'Task deleted';
  static const taskRestored = 'Task restored';
  static const categoryCreated = 'Category created';
  static const categoryUpdated = 'Category updated';
  static const categoryDeleted = 'Category deleted';
  static const settingsSaved = 'Settings saved';

  // Undo
  static String undoCountdown(int seconds) => 'Undo (${seconds}s)';

  // Errors
  static const errorGeneric = 'Something went wrong. Please try again.';
  static const errorCache = 'Unable to read or save data locally.';
  static const errorValidation = 'Please check your input and try again.';
  static const errorTitleRequired = 'Title is required.';
  static const errorUnknown = 'An unexpected error occurred.';
  static const errorLoadTasks = 'Failed to load tasks.';
  static const errorSaveTask = 'Failed to save task.';
  static const errorDeleteTask = 'Failed to delete task.';
  static const errorLoadCategories = 'Failed to load categories.';
  static const errorLoadSettings = 'Failed to load settings.';
}
