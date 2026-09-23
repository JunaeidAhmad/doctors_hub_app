import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:doctors_hub_app/core/storage/local_booking_store.dart';
import 'package:doctors_hub_app/features/bookings/domain/models/booking_item.dart';

void main() {
  group('LocalBookingStore', () {
    late LocalBookingStore store;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      store = LocalBookingStore(prefs);
    });

    test('stores, retrieves, and sorts bookings properly', () async {
      expect(store.getBookings(), isEmpty);
      expect(store.getUpcomingCount(), equals(0));

      final futureDate = DateTime.now().add(const Duration(days: 3));
      final pastDate = DateTime.now().subtract(const Duration(days: 3));

      final upcomingBooking = BookingItem(
        id: 'book-1',
        bookingRef: 'DH-11111',
        serialDisplay: 'SL-001',
        type: 'doctor',
        title: 'Dr. John Doe',
        subtitle: 'Cardiology',
        facilityName: 'Dhaka Clinic',
        appointmentDate: futureDate,
        timeSlot: '10:00 AM',
        patientName: 'Rahim Khan',
        patientPhone: '01712345678',
        fee: 1000,
        paymentMethod: 'counter',
        createdAt: DateTime.now(),
      );

      final pastBooking = BookingItem(
        id: 'book-2',
        bookingRef: 'DH-22222',
        serialDisplay: 'SL-002',
        type: 'doctor',
        title: 'Dr. Jane Smith',
        subtitle: 'Dermatology',
        facilityName: 'Popular Lab',
        appointmentDate: pastDate,
        timeSlot: '05:00 PM',
        patientName: 'Rahim Khan',
        patientPhone: '01712345678',
        fee: 800,
        paymentMethod: 'counter',
        createdAt: DateTime.now(),
      );

      await store.saveBooking(pastBooking);
      await store.saveBooking(upcomingBooking);

      final bookings = store.getBookings();
      expect(bookings.length, equals(2));
      // Upcoming should be first
      expect(bookings[0].id, equals('book-1'));
      expect(bookings[1].id, equals('book-2'));

      expect(store.getUpcomingCount(), equals(1));
      expect(store.getLastPatientName(), equals('Rahim Khan'));
      expect(store.getLastPatientPhone(), equals('01712345678'));

      // Remove booking
      await store.removeBooking('book-1');
      expect(store.getBookings().length, equals(1));
      expect(store.getUpcomingCount(), equals(0));
    });
  });
}
