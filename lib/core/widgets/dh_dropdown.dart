import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class DhDropdownItem<T> {
  const DhDropdownItem({
    required this.value,
    required this.label,
  });

  final T value;
  final String label;
}

class DhDropdown<T> extends StatelessWidget {
  const DhDropdown({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
    this.hint,
    this.height = 48.0,
    this.backgroundColor = AppColors.paper,
    this.borderColor = AppColors.ink,
  });

  final T? value;
  final List<DhDropdownItem<T>> items;
  final ValueChanged<T?> onChanged;
  final String? hint;
  final double height;
  final Color backgroundColor;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border.all(color: borderColor, width: AppColors.borderWidth),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          hint: hint != null
              ? Text(
                  hint!,
                  style: AppTypography.body.copyWith(color: AppColors.mutedLight),
                  overflow: TextOverflow.ellipsis,
                )
              : null,
          isExpanded: true,
          icon: const Icon(Icons.arrow_drop_down, color: AppColors.ink, size: 24),
          style: AppTypography.body,
          dropdownColor: AppColors.paper,
          borderRadius: BorderRadius.zero,
          elevation: 4,
          onChanged: onChanged,
          items: items.map((item) {
            return DropdownMenuItem<T>(
              value: item.value,
              child: Text(
                item.label,
                style: AppTypography.body,
                overflow: TextOverflow.ellipsis,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
