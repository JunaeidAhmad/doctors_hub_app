import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/models/test_search.dart';

/// The test + lab the patient tapped on the tests tab, handed to the booking
/// screen so it never re-fetches (no single-offering read is in the patient
/// surface; see docs/BACKEND_GAPS.md G6).
class TestBookingSelection {
  const TestBookingSelection({
    required this.group,
    required this.offering,
    this.divisionId,
    this.districtId,
    this.thanaId,
  });

  final TestSearchGroup group;
  final LabOffering offering;

  /// Location filters from the tests tab, preselected in the pickup picker.
  final int? divisionId;
  final int? districtId;
  final int? thanaId;

  bool matches(String testId, String labId) =>
      group.id == testId && offering.id == labId;
}

final testBookingSelectionProvider =
    StateProvider<TestBookingSelection?>((ref) => null);
