import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class RadioRow<T> extends StatelessWidget {
  const RadioRow({
    super.key,
    required this.value,
    required this.groupValue,
    required this.onChanged,
    required this.title,
    this.subtitle,
    this.badge,
    this.fee,
  });

  final T value;
  final T? groupValue;
  final ValueChanged<T> onChanged;
  final String title;
  final String? subtitle;
  final String? badge;
  final String? fee;

  bool get isSelected => value == groupValue;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(value),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accentWash : AppColors.paper,
          border: Border.all(
            color: isSelected ? AppColors.accent : AppColors.ink,
            width: AppColors.borderWidth,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Custom square or round radio indicator
            Container(
              width: 20,
              height: 20,
              margin: const EdgeInsets.only(top: 2, right: 12),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.accent : AppColors.paper,
                border: Border.all(
                  color: isSelected ? AppColors.accent : AppColors.ink,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Center(
                      child: Icon(Icons.check, size: 14, color: AppColors.paper),
                    )
                  : null,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: AppTypography.bodyMedium,
                        ),
                      ),
                      if (fee != null)
                        Text(
                          fee!,
                          style: AppTypography.secondaryBold.copyWith(
                            color: AppColors.accent,
                          ),
                        ),
                    ],
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle!,
                      style: AppTypography.secondary,
                    ),
                  ],
                  if (badge != null) ...[
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: const BoxDecoration(
                        color: AppColors.fill,
                      ),
                      child: Text(
                        badge!,
                        style: AppTypography.tag,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
