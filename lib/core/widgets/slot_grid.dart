import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class TimeSlot {
  const TimeSlot({
    required this.timeString, // e.g. "18:00" or "06:00 PM"
    required this.displayLabel, // e.g. "06:00 PM"
    this.isBooked = false,
  });

  final String timeString;
  final String displayLabel;
  final bool isBooked;
}

class ShiftSlotGroup {
  const ShiftSlotGroup({
    required this.shiftName, // e.g. "Morning Shift" or "Evening Shift"
    required this.slots,
  });

  final String shiftName;
  final List<TimeSlot> slots;
}

class SlotGrid extends StatelessWidget {
  const SlotGrid({
    super.key,
    required this.groups,
    required this.selectedSlot,
    required this.onSlotSelected,
  });

  final List<ShiftSlotGroup> groups;
  final String? selectedSlot;
  final ValueChanged<TimeSlot> onSlotSelected;

  @override
  Widget build(BuildContext context) {
    if (groups.isEmpty || groups.every((g) => g.slots.isEmpty)) {
      return Container(
        padding: const EdgeInsets.all(24),
        alignment: Alignment.center,
        child: const Text(
          'No slots available',
          style: AppTypography.secondary,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: groups.map((group) {
        if (group.slots.isEmpty) return const SizedBox.shrink();

        return Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Text(
                  group.shiftName.toUpperCase(),
                  style: AppTypography.kicker.copyWith(
                    color: AppColors.muted,
                    fontSize: 12,
                  ),
                ),
              ),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: group.slots.map((slot) {
                  final isSelected = selectedSlot == slot.timeString;
                  final isBooked = slot.isBooked;

                  Color bgColor = AppColors.paper;
                  Color textColor = AppColors.ink;
                  Color borderColor = AppColors.ink;

                  if (isSelected) {
                    bgColor = AppColors.accent;
                    textColor = AppColors.paper;
                    borderColor = AppColors.ink;
                  } else if (isBooked) {
                    bgColor = AppColors.fill;
                    textColor = AppColors.mutedLight;
                    borderColor = AppColors.lineSoft;
                  }

                  return InkWell(
                    onTap: isBooked ? null : () => onSlotSelected(slot),
                    child: Container(
                      width: 96,
                      height: 42,
                      decoration: BoxDecoration(
                        color: bgColor,
                        border: Border.all(color: borderColor, width: AppColors.borderWidth),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        slot.displayLabel,
                        style: TextStyle(
                          fontFamily: AppTypography.fontMono,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: textColor,
                          decoration: isBooked ? TextDecoration.lineThrough : null,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
