import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:doctors_hub_app/core/network/api_client.dart';
import 'package:doctors_hub_app/core/network/app_failure.dart';
import 'package:doctors_hub_app/core/providers/app_providers.dart';
import 'package:doctors_hub_app/features/booking/data/booking_repository.dart';
import 'package:doctors_hub_app/features/booking/domain/models/booking_result.dart';
import 'package:doctors_hub_app/features/bookings/domain/models/booking_item.dart';
import 'package:doctors_hub_app/features/bookings/presentation/bookings_screen.dart';
import 'package:doctors_hub_app/features/doctors/domain/models/chamber.dart';
import 'package:doctors_hub_app/l10n/app_localizations.dart';

import '../helpers/recording_adapter.dart';

class FakeBookingRepository extends BookingRepository {
  FakeBookingRepository({this.statusResult, this.cancelError})
      : super(ApiClient());

  final DoctorBookingStatusResult? statusResult;
  final AppFailure? cancelError;
  int statusCalls = 0;
  final List<Map<String, String>> cancelled = [];

  @override
  Future<DoctorBookingStatusResult?> getDoctorBookingStatus({
    required String bookingId,
    required String phone,
  }) async {
    statusCalls++;
    return statusResult;
  }

  @override
  Future<void> cancelDoctorBooking({
    required String bookingId,
    required String patientToken,
    required String reason,
  }) async {
    final error = cancelError;
    if (error != null) throw error;
    cancelled.add({
      'id': bookingId,
      'token': patientToken,
      'reason': reason,
    });
  }
}

BookingItem buildBooking({
  String id = 'b1d4e6f2-aaaa-bbbb-cccc-111122223333',
  String type = 'doctor',
  BookingStatus status = BookingStatus.pending,
  String? patientToken = 'req7Tok3nAbCdEf',
  String? serialDisplay,
}) {
  return BookingItem(
    id: id,
    bookingRef: id.substring(0, 8).toUpperCase(),
    type: type,
    title: 'A B Siddique',
    subtitle: 'Cardiology',
    facilityName: 'Popular Diagnostic Centre',
    appointmentDate: DateTime.parse('2099-10-20'),
    timeSlot: '5:00 PM–8:00 PM',
    patientName: 'Test Patient',
    patientPhone: '01712345678',
    paymentMethod: 'counter',
    createdAt: DateTime.parse('2026-10-18T10:00:00'),
    status: status,
    bookingMode: BookingMode.request,
    confirmDeadline: '2099-10-19T12:00:00+06:00',
    patientToken: patientToken,
    serialDisplay: serialDisplay,
  );
}

Future<void> pumpBookings(
  WidgetTester tester,
  List<BookingItem> bookings, {
  required FakeBookingRepository repo,
}) async {
  tester.view.physicalSize = const Size(1080, 2200);
  tester.view.devicePixelRatio = 2.0;
  addTearDown(() => tester.view.resetPhysicalSize());

  SharedPreferences.setMockInitialValues({
    'dh_saved_bookings_v2':
        bookings.map((b) => jsonEncode(b.toJson())).toList(),
  });
  final prefs = await SharedPreferences.getInstance();

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        bookingRepositoryProvider.overrideWithValue(repo),
      ],
      child: const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: BookingsScreen(),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  testWidgets('pull-to-refresh flips a pending request to confirmed with serial',
      (tester) async {
    final repo = FakeBookingRepository(
      statusResult: const DoctorBookingStatusResult(
        id: 'b1d4e6f2-aaaa-bbbb-cccc-111122223333',
        status: BookingStatus.confirmed,
        serialNumber: 7,
        serialDisplay: 'SL-007',
        estimatedTime: '18:10',
      ),
    );
    await pumpBookings(tester, [buildBooking()], repo: repo);

    expect(find.text('Awaiting confirmation'), findsOneWidget);
    expect(find.text('SL-007'), findsNothing);

    await tester.fling(find.byType(ListView), const Offset(0, 300), 1000);
    await tester.pumpAndSettle();

    expect(repo.statusCalls, greaterThan(0));
    expect(find.text('Confirmed'), findsOneWidget);
    expect(find.text('SL-007'), findsOneWidget);
    expect(find.text('Awaiting confirmation'), findsNothing);
  });

  testWidgets('cancel asks for a reason and cancels on the server',
      (tester) async {
    final repo = FakeBookingRepository();
    await pumpBookings(tester, [buildBooking()], repo: repo);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.text('Cancel Appointment'), findsOneWidget);

    // Too-short reason is rejected client-side.
    await tester.tap(find.text('Yes, cancel'));
    await tester.pump();
    expect(find.text('Enter a reason (at least 3 characters).'), findsOneWidget);
    expect(repo.cancelled, isEmpty);

    await tester.enterText(find.byType(TextField), 'Not needed');
    await tester.tap(find.text('Yes, cancel'));
    await tester.pumpAndSettle();

    expect(repo.cancelled, hasLength(1));
    expect(repo.cancelled.single['id'], startsWith('b1d4e6f2'));
    expect(repo.cancelled.single['token'], 'req7Tok3nAbCdEf');
    expect(repo.cancelled.single['reason'], 'Not needed');
    expect(find.text('Cancelled'), findsOneWidget);
  });

  testWidgets('a confirmed booking can be cancelled remotely', (tester) async {
    final repo = FakeBookingRepository();
    await pumpBookings(
      tester,
      [buildBooking(status: BookingStatus.confirmed, serialDisplay: 'SL-004')],
      repo: repo,
    );

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.text('Cancel Appointment'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'Can not attend');
    await tester.tap(find.text('Yes, cancel'));
    await tester.pumpAndSettle();

    expect(repo.cancelled, hasLength(1));
    expect(find.text('Cancelled'), findsOneWidget);
  });

  testWidgets('not_cancellable refreshes the status and shows the message',
      (tester) async {
    final repo = FakeBookingRepository(
      statusResult: const DoctorBookingStatusResult(
        id: 'b1d4e6f2-aaaa-bbbb-cccc-111122223333',
        status: BookingStatus.completed,
      ),
      cancelError: const ValidationFailure(
        message: 'This booking can no longer be cancelled.',
        code: 'not_cancellable',
      ),
    );
    await pumpBookings(tester, [buildBooking()], repo: repo);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Please cancel');
    await tester.tap(find.text('Yes, cancel'));
    await tester.pumpAndSettle();

    expect(repo.cancelled, isEmpty);
    expect(repo.statusCalls, greaterThan(0));
    expect(
      find.text(
        'This booking can no longer be cancelled. Pull to refresh to see its status.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('test bookings without a token keep the local remove dialog',
      (tester) async {
    final repo = FakeBookingRepository();
    await pumpBookings(
      tester,
      [buildBooking(type: 'test', patientToken: null)],
      repo: repo,
    );

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(
      find.text('You can remove this booking record from your phone.'),
      findsOneWidget,
    );
    expect(find.text('Cancel Appointment'), findsOneWidget);
  });

  group('BookingRepository status and cancel', () {
    test('status 404 booking_not_found returns null', () async {
      final adapter = RecordingAdapter(
        '{"code":"booking_not_found","detail":"Booking not found.","detail_bn":"x"}',
        statusCode: 404,
      );
      final client = ApiClient(origin: 'https://example.com');
      client.dio.httpClientAdapter = adapter;
      final repo = BookingRepository(client);

      final result = await repo.getDoctorBookingStatus(
        bookingId: 'b1',
        phone: '01712345678',
      );

      expect(result, isNull);
      expect(adapter.lastOptions!.path, '/bookings/doctor/b1/status/');
      expect(adapter.lastOptions!.queryParameters['phone'], '01712345678');
    });

    test('status 200 parses serial, estimate and deadline', () async {
      final adapter = RecordingAdapter(
        '{"id":"b1","status":"confirmed","serial_number":7,'
        '"serial_display":"SL-007","estimated_time":"18:10",'
        '"confirm_deadline":"2026-10-19T12:00:00+06:00","is_urgent":false}',
      );
      final client = ApiClient(origin: 'https://example.com');
      client.dio.httpClientAdapter = adapter;
      final repo = BookingRepository(client);

      final result = await repo.getDoctorBookingStatus(
        bookingId: 'b1',
        phone: '01712345678',
      );

      expect(result!.status, BookingStatus.confirmed);
      expect(result.serialDisplay, 'SL-007');
      expect(result.estimatedTime, '18:10');
      expect(result.confirmDeadline, '2026-10-19T12:00:00+06:00');
    });

    test('cancel posts the token and reason', () async {
      final adapter = RecordingAdapter('{"status":"cancelled"}');
      final client = ApiClient(origin: 'https://example.com');
      client.dio.httpClientAdapter = adapter;
      final repo = BookingRepository(client);

      await repo.cancelDoctorBooking(
        bookingId: 'b1',
        patientToken: 'tok123',
        reason: 'Not needed',
      );

      expect(adapter.lastOptions!.path, '/bookings/doctor/b1/patient-cancel/');
      final body = adapter.lastOptions!.data as Map<String, dynamic>;
      expect(body['patient_token'], 'tok123');
      expect(body['reason'], 'Not needed');
    });
  });
}
