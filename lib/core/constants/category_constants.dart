import '../constants/app_strings.dart';

/// Fixed category identifiers and display tokens.
abstract final class CategoryConstants {
  static const workId = 'work';
  static const personalId = 'personal';
  static const urgentId = 'urgent';

  static const workName = AppStrings.categoryWork;
  static const personalName = AppStrings.categoryPersonal;
  static const urgentName = AppStrings.categoryUrgent;
}
