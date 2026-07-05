import 'package:flutter/material.dart';

import '../../../categories/domain/entities/task_category.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/category_colors.dart';

/// Displays a category label with its preset [AppColors] accent.
class CategoryChip extends StatelessWidget {
  const CategoryChip({
    required this.category,
    this.selected = false,
    this.onTap,
    super.key,
  });

  final TaskCategory category;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = CategoryColors.forCategoryId(category.id);

    return FilterChip(
      label: Text(category.name),
      selected: selected,
      onSelected: onTap == null ? null : (_) => onTap!(),
      showCheckmark: false,
      labelStyle: theme.textTheme.labelMedium?.copyWith(
        color: selected ? CategoryColors.onCategory(color) : color,
        fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
      ),
      selectedColor: color,
      backgroundColor: color.withValues(alpha: 0.12),
      side: BorderSide(
        color: selected ? color : theme.colorScheme.outlineVariant,
        width: selected ? 1.5 : 1,
      ),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
    );
  }
}
