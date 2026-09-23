import 'package:intl/intl.dart';
import '../widgets/slot_grid.dart';
import '../../features/doctors/domain/models/schedule.dart';

class SlotGenerator {
  const SlotGenerator._();

  static const Map<int, String> _weekdayNames = {
    DateTime.monday: 'Monday',
    DateTime.tuesday: 'Tuesday',
    DateTime.wednesday: 'Wednesday',
    DateTime.thursday: 'Thursday',
    DateTime.friday: 'Friday',
    DateTime.saturday: 'Saturday',
    DateTime.sunday: 'Sunday',
  };

  static String getDayName(DateTime date) {
    return _weekdayNames[date.weekday] ?? '';
  }

  static bool isChamberAvailableOnDate(List<DoctorSchedule> schedules, DateTime date) {
    final dayName = getDayName(date).toLowerCase();
    return schedules.any((s) => s.dayOfWeek.toLowerCase() == dayName);
  }

  static List<ShiftSlotGroup> generateSlotsForDate({
    required List<DoctorSchedule> schedules,
    required DateTime date,
  }) {
    final dayName = getDayName(date).toLowerCase();
    final matchingSchedules = schedules
        .where((s) => s.dayOfWeek.toLowerCase() == dayName)
        .toList();

    if (matchingSchedules.isEmpty) {
      return [];
    }

    final morningSlots = <TimeSlot>[];
    final eveningSlots = <TimeSlot>[];

    for (final schedule in matchingSchedules) {
      final slots = _generate30MinSlots(schedule.startTime, schedule.endTime);
      for (final slot in slots) {
        final hour = int.tryParse(slot.timeString.split(':')[0]) ?? 12;
        if (hour < 14) {
          morningSlots.add(slot);
        } else {
          eveningSlots.add(slot);
        }
      }
    }

    final groups = <ShiftSlotGroup>[];
    if (morningSlots.isNotEmpty) {
      groups.add(ShiftSlotGroup(shiftName: 'Morning Shift', slots: morningSlots));
    }
    if (eveningSlots.isNotEmpty) {
      groups.add(ShiftSlotGroup(shiftName: 'Evening Shift', slots: eveningSlots));
    }

    return groups;
  }

  static List<TimeSlot> _generate30MinSlots(String startTime, String endTime) {
    final slots = <TimeSlot>[];
    try {
      final startParts = startTime.split(':').map(int.parse).toList();
      final endParts = endTime.split(':').map(int.parse).toList();

      var currentMinutes = startParts[0] * 60 + startParts[1];
      final endMinutes = endParts[0] * 60 + endParts[1];

      while (currentMinutes + 30 <= endMinutes) {
        final hour = currentMinutes ~/ 60;
        final minute = currentMinutes % 60;

        final timeString =
            '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';

        // Format to display format e.g. "06:00 PM"
        final dt = DateTime(2024, 1, 1, hour, minute);
        final displayLabel = DateFormat('hh:mm a').format(dt);

        slots.add(TimeSlot(
          timeString: timeString,
          displayLabel: displayLabel,
        ));

        currentMinutes += 30;
      }
    } catch (_) {
      // Fallback: return at least the start time as a slot
      if (startTime.isNotEmpty) {
        slots.add(TimeSlot(
          timeString: startTime.length >= 5 ? startTime.substring(0, 5) : startTime,
          displayLabel: startTime,
        ));
      }
    }

    return slots;
  }
}
