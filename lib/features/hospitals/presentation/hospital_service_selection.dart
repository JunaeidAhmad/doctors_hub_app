import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/models/hospital.dart';

/// The hospital + service the patient tapped on the hospital page, handed to
/// the booking screen so it doesn't re-fetch on a warm navigation.
class HospitalServiceSelection {
  const HospitalServiceSelection({
    required this.hospital,
    required this.service,
  });

  final Hospital hospital;
  final HospitalServiceRef service;

  bool matches(String serviceId) => service.id == serviceId;
}

final hospitalServiceSelectionProvider =
    StateProvider<HospitalServiceSelection?>((ref) => null);
