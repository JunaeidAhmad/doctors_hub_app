import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/bookings/domain/models/booking_item.dart';

class LocalBookingStore {
  LocalBookingStore(this._prefs);

  final SharedPreferences _prefs;

  static const String _bookingsKey = 'dh_saved_bookings_v1';
  static const String _lastPatientNameKey = 'dh_last_patient_name';
  static const String _lastPatientPhoneKey = 'dh_last_patient_phone';

  List<BookingItem> getBookings() {
    final rawList = _prefs.getStringList(_bookingsKey);
    if (rawList == null || rawList.isEmpty) return [];

    final list = <BookingItem>[];
    for (final raw in rawList) {
      try {
        final map = jsonDecode(raw) as Map<String, dynamic>;
        list.add(BookingItem.fromJson(map));
      } catch (_) {
        // Skip corrupted entries
      }
    }

    // Sort: upcoming first (nearest date first), then past bookings (most recent first)
    list.sort((a, b) {
      final aUpcoming = a.isUpcoming;
      final bUpcoming = b.isUpcoming;

      if (aUpcoming && !bUpcoming) return -1;
      if (!aUpcoming && bUpcoming) return 1;

      if (aUpcoming) {
        return a.appointmentDate.compareTo(b.appointmentDate);
      } else {
        return b.appointmentDate.compareTo(a.appointmentDate);
      }
    });

    return list;
  }

  Future<void> saveBooking(BookingItem booking) async {
    final existing = getBookings();
    // Prepend or replace if same id
    existing.removeWhere((b) => b.id == booking.id);
    existing.insert(0, booking);

    final rawList = existing.map((b) => jsonEncode(b.toJson())).toList();
    await _prefs.setStringList(_bookingsKey, rawList);

    // Also remember patient details for prefill
    await saveLastPatient(name: booking.patientName, phone: booking.patientPhone);
  }

  Future<void> removeBooking(String bookingId) async {
    final existing = getBookings();
    existing.removeWhere((b) => b.id == bookingId);
    final rawList = existing.map((b) => jsonEncode(b.toJson())).toList();
    await _prefs.setStringList(_bookingsKey, rawList);
  }

  int getUpcomingCount() {
    return getBookings().where((b) => b.isUpcoming).length;
  }

  Future<void> saveLastPatient({required String name, required String phone}) async {
    if (name.isNotEmpty) await _prefs.setString(_lastPatientNameKey, name);
    if (phone.isNotEmpty) await _prefs.setString(_lastPatientPhoneKey, phone);
  }

  String? getLastPatientName() => _prefs.getString(_lastPatientNameKey);
  String? getLastPatientPhone() => _prefs.getString(_lastPatientPhoneKey);
}
