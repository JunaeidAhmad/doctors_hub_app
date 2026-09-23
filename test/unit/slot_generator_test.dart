import 'package:flutter_test/flutter_test.dart';
import 'package:doctors_hub_app/core/utils/slot_generator.dart';
import 'package:doctors_hub_app/features/doctors/domain/models/schedule.dart';

void main() {
  group('SlotGenerator', () {
    final schedules = [
      const DoctorSchedule(
        dayOfWeek: 'Monday',
        startTime: '10:00:00',
        endTime: '12:00:00',
      ),
      const DoctorSchedule(
        dayOfWeek: 'Monday',
        startTime: '18:00:00',
        endTime: '20:00:00',
      ),
      const DoctorSchedule(
        dayOfWeek: 'Wednesday',
        startTime: '17:00:00',
        endTime: '19:00:00',
      ),
    ];

    test('correctly identifies chamber availability by date', () {
      // 2024-01-01 is a Monday
      final monday = DateTime(2024, 1, 1);
      // 2024-01-02 is a Tuesday
      final tuesday = DateTime(2024, 1, 2);
      // 2024-01-03 is a Wednesday
      final wednesday = DateTime(2024, 1, 3);

      expect(SlotGenerator.isChamberAvailableOnDate(schedules, monday), isTrue);
      expect(SlotGenerator.isChamberAvailableOnDate(schedules, tuesday), isFalse);
      expect(SlotGenerator.isChamberAvailableOnDate(schedules, wednesday), isTrue);
    });

    test('generates 30-minute intervals grouped into morning and evening shifts', () {
      final monday = DateTime(2024, 1, 1);
      final groups = SlotGenerator.generateSlotsForDate(
        schedules: schedules,
        date: monday,
      );

      expect(groups.length, equals(2));
      expect(groups[0].shiftName, equals('Morning Shift'));
      expect(groups[0].slots.length, equals(4)); // 10:00, 10:30, 11:00, 11:30
      expect(groups[0].slots[0].timeString, equals('10:00'));
      expect(groups[0].slots[3].timeString, equals('11:30'));

      expect(groups[1].shiftName, equals('Evening Shift'));
      expect(groups[1].slots.length, equals(4)); // 18:00, 18:30, 19:00, 19:30
      expect(groups[1].slots[0].timeString, equals('18:00'));
    });

    test('returns empty list for off days', () {
      final tuesday = DateTime(2024, 1, 2);
      final groups = SlotGenerator.generateSlotsForDate(
        schedules: schedules,
        date: tuesday,
      );

      expect(groups, isEmpty);
    });
  });
}
