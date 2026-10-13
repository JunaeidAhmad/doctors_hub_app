import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class DateStripItem {
  const DateStripItem({
    required this.date,
    required this.isAvailable,
    this.label,
  });

  final DateTime date;
  final bool isAvailable;

  /// Optional small status label under the day number ("Full", "Not at...").
  final String? label;
}

class DateStrip extends StatelessWidget {
  const DateStrip({
    super.key,
    required this.dates,
    required this.selectedDate,
    required this.onDateSelected,
  });

  final List<DateStripItem> dates;
  final DateTime? selectedDate;
  final ValueChanged<DateTime> onDateSelected;

  bool _isSameDay(DateTime a, DateTime? b) {
    if (b == null) return false;
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 72,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: dates.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final item = dates[index];
          final isSelected = _isSameDay(item.date, selectedDate);
          final isAvailable = item.isAvailable;

          Color bgColor = AppColors.paper;
          Color textColor = AppColors.ink;
          Color borderColor = AppColors.ink;

          if (isSelected) {
            bgColor = AppColors.accent;
            textColor = AppColors.paper;
            borderColor = AppColors.ink;
          } else if (!isAvailable) {
            bgColor = AppColors.fillOff;
            textColor = AppColors.mutedLight;
            borderColor = AppColors.lineSoft;
          }

          final dayName = DateFormat('E').format(item.date); // e.g. "Thu"
          final dayNum = DateFormat('d').format(item.date); // e.g. "24"

          return InkWell(
            onTap: isAvailable ? () => onDateSelected(item.date) : null,
            child: Container(
              width: 54,
              decoration: BoxDecoration(
                color: bgColor,
                border: Border.all(color: borderColor, width: AppColors.borderWidth),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    dayName.toUpperCase(),
                    style: TextStyle(
                      fontFamily: AppTypography.fontMono,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    dayNum,
                    style: TextStyle(
                      fontFamily: AppTypography.fontArchivo,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: textColor,
                    ),
                  ),
                  if (item.label != null && item.label!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: Text(
                        item.label!,
                        style: TextStyle(
                          fontFamily: AppTypography.fontArchivo,
                          fontSize: 8,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
