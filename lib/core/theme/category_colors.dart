import 'package:flutter/material.dart';

import '../constants/category_constants.dart';
import 'app_colors.dart';

/// Maps fixed category IDs to [AppColors] tokens for consistent UI.
abstract final class CategoryColors {
  static Color forCategoryId(String categoryId) {
    return switch (categoryId) {
      CategoryConstants.workId => AppColors.categoryWork,
      CategoryConstants.personalId => AppColors.categoryPersonal,
      CategoryConstants.urgentId => AppColors.categoryUrgent,
      _ => AppColors.primary,
    };
  }

  static Color onCategory(Color categoryColor) {
    return categoryColor == AppColors.categoryUrgent
        ? AppColors.onDanger
        : AppColors.onPrimary;
  }
}
