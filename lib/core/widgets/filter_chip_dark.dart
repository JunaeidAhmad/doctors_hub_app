import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class FilterChipDark extends StatelessWidget {
  const FilterChipDark({
    super.key,
    required this.label,
    required this.onDeleted,
    this.backgroundColor = AppColors.ink,
    this.textColor = AppColors.paper,
    this.height = 32.0,
  });

  final String label;
  final VoidCallback onDeleted;
  final Color backgroundColor;
  final Color textColor;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: const EdgeInsets.only(left: 10, right: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border.all(color: AppColors.ink, width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            label,
            style: AppTypography.tag.copyWith(
              color: textColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 4),
          InkWell(
            onTap: onDeleted,
            child: Padding(
              padding: const EdgeInsets.all(2.0),
              child: Icon(Icons.close, size: 14, color: textColor),
            ),
          ),
        ],
      ),
    );
  }
}

class DhSelectChip extends StatelessWidget {
  const DhSelectChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onSelected,
    this.height = 32.0,
  });

  final String label;
  final bool isSelected;
  final ValueChanged<bool> onSelected;
  final double height;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onSelected(!isSelected),
      child: Container(
        height: height,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.ink : AppColors.paper,
          border: Border.all(color: AppColors.ink, width: 1.5),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: AppTypography.tag.copyWith(
            color: isSelected ? AppColors.paper : AppColors.ink,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
