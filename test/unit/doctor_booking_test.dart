import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:doctors_hub_app/core/models/facility_summary.dart';
import 'package:doctors_hub_app/core/network/api_client.dart';
import 'package:doctors_hub_app/core/providers/app_providers.dart';
import 'package:doctors_hub_app/core/utils/dhaka_time.dart';
import 'package:doctors_hub_app/core/widgets/otp_sheet.dart';
import 'package:doctors_hub_app/core/widgets/phone_field.dart';
import 'package:doctors_hub_app/features/booking/data/booking_repository.dart';
import 'package:doctors_hub_app/features/booking/domain/booking_mode.dart';
import 'package:doctors_hub_app/features/booking/presentation/booking_success_screen.dart';
import 'package:doctors_hub_app/features/booking/presentation/doctor_booking_step1_screen.dart';
import 'package:doctors_hub_app/features/booking/presentation/doctor_booking_step2_screen.dart';
import 'package:doctors_hub_app/features/doctors/data/doctor_repository.dart';
import 'package:doctors_hub_app/features/doctors/domain/models/availability.dart';
import 'package:doctors_hub_app/features/doctors/domain/models/chamber.dart';
import 'package:doctors_hub_app/features/doctors/domain/models/doctor.dart';
import 'package:doctors_hub_app/l10n/app_localizations.dart';

import '../helpers/recording_adapter.dart';

class FakeDoctorRepository extends DoctorRepository {
  FakeDoctorRepository(this.doctor, {this.availability}) : super(ApiClient());

  final Doctor doctor;
  final AffiliationAvailability? availability;

  @override
  Future<Doctor> getDoctorDetails(String idOrSlug) async => doctor;

  @override
  Future<AffiliationAvailability> getAvailability(
    String chamberId, {
    required String from,
    int days = 14,
  }) async {
    final value = availability;
    if (value == null) {
      throw UnimplementedError('No availability configured for the fake.');
    }
    return value;
  }
}

Chamber buildChamber(String id, BookingMode mode) => Chamber(
      id: id,
      fee: 1200,
      bookingMode: mode,
      facility: const FacilitySummary(
        id: 'f1',
        displayName: 'Popular Diagnostic Centre (Dhanmondi)',
        address: 'House 16, Road 2, Dhanmondi',
        phone: '+8801713377775',
      ),
      advanceBookingDays: 14,
    );

Doctor buildDoctor(BookingMode mode) => Doctor(
      id: 'd1',
      name: 'A B Siddique',
      slug: 'a-b-siddique',
      chambers: [buildChamber('c1', mode)],
    );

String instantBody() =>
    File('test/fixtures/v1/doctor_booking_instant.json').readAsStringSync();

String requestBody() =>
    File('test/fixtures/v1/doctor_booking_request.json').readAsStringSync();

Future<RecordingAdapter> pumpStep2(
  WidgetTester tester, {
  required BookingMode mode,
  required String responseBody,
  int statusCode = 200,
}) async {
  tester.view.physicalSize = const Size(1080, 2200);
  tester.view.devicePixelRatio = 2.0;
  addTearDown(() => tester.view.resetPhysicalSize());

  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();

  final adapter = RecordingAdapter(responseBody, statusCode: statusCode);
  final client = ApiClient(origin: 'https://example.com');
  client.dio.httpClientAdapter = adapter;

  final doctor = buildDoctor(mode);
  final router = GoRouter(
    initialLocation: '/doctors/d1/book',
    routes: [
      GoRoute(
        path: '/doctors/:id/book',
        builder: (_, __) => const Scaffold(body: Text('step1')),
      ),
      GoRoute(
        path: '/doctors/:id/confirm',
        builder: (context, state) =>
            const DoctorBookingStep2Screen(doctorId: 'd1'),
      ),
      GoRoute(
        path: '/doctors/:id/call',
        builder: (_, __) => const Scaffold(body: Text('call')),
      ),
      GoRoute(path: '/success', builder: (_, __) => const BookingSuccessScreen()),
      GoRoute(path: '/doctors', builder: (_, __) => const Scaffold()),
    ],
  );

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        doctorRepositoryProvider.overrideWithValue(
          FakeDoctorRepository(doctor),
        ),
        bookingRepositoryProvider.overrideWithValue(
          BookingRepository(client),
        ),
      ],
      child: MaterialApp.router(
        routerConfig: router,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
      ),
    ),
  );
  await tester.pump();

  final uri = Uri(
    path: '/doctors/d1/confirm',
    queryParameters: {
      'chamber': 'c1',
      'date': '2026-10-15',
      'session_key': 's:e2db71ac-bd31-55ff-8f9a-12247d7fe32c',
      'displaySlot': '5:00 PM–8:00 PM',
    },
  );
  router.push(uri.toString());
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
  return adapter;
}

AffiliationAvailability availabilityWithSession({
  required String dateIso,
  required String startHm,
}) {
  return AffiliationAvailability(
    affiliationId: 'c1',
    facility: const FacilitySummary(
      id: 'f1',
      displayName: 'Popular Diagnostic Centre (Dhanmondi)',
      address: 'House 16, Road 2, Dhanmondi',
    ),
    dates: [
      AvailabilityDate(
        date: dateIso,
        weekday: 'Thu',
        status: AvailabilityDateStatus.available,
        hasSchedule: true,
        sessions: [
          AvailabilitySession(
            sessionKey: 's:test',
            startTime: startHm,
            endTime: '23:59',
            sessionStart: startHm,
            sessionEnd: '23:59',
            capacity: 10,
            booked: 4,
            remaining: 6,
            nextSerial: 5,
            estimatedTime: startHm,
            status: AvailabilitySessionStatus.available,
          ),
        ],
      ),
    ],
  );
}

Future<void> pumpStep1(
  WidgetTester tester, {
  required BookingMode mode,
  required AffiliationAvailability availability,
}) async {
  tester.view.physicalSize = const Size(1080, 2200);
  tester.view.devicePixelRatio = 2.0;
  addTearDown(() => tester.view.resetPhysicalSize());

  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();

  final router = GoRouter(
    initialLocation: '/doctors/d1/book',
    routes: [
      GoRoute(
        path: '/doctors/:id/book',
        builder: (_, __) => const DoctorBookingStep1Screen(doctorId: 'd1'),
      ),
    ],
  );

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        doctorRepositoryProvider.overrideWithValue(
          FakeDoctorRepository(buildDoctor(mode), availability: availability),
        ),
      ],
      child: MaterialApp.router(
        routerConfig: router,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
      ),
    ),
  );
  await tester.pump();
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));
}

Future<void> fillAndSubmit(WidgetTester tester, {String buttonLabel = 'Book appointment'}) async {
  await tester.enterText(find.byType(TextField).first, 'Test Patient');
  await tester.enterText(
    find.descendant(
      of: find.byType(PhoneField),
      matching: find.byType(TextField),
    ),
    '01712345678',
  );
  await tester.tap(find.text('Male'));
  await tester.pump();

  await tester.tap(find.text(buttonLabel));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));

  await tester.enterText(
    find.descendant(
      of: find.byType(OtpSheet),
      matching: find.byType(TextField),
    ),
    '123456',
  );
  await tester.pump();
  await tester.tap(find.text('Verify & Confirm'));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 200));
  await tester.pump(const Duration(milliseconds: 400));
  await tester.pump(const Duration(milliseconds: 400));
}

void main() {
  group('bookingModeView', () {
    test('instant books with sessions, seats and serial', () {
      final view = bookingModeView(buildChamber('c', BookingMode.instant));
      expect(view.canBook, isTrue);
      expect(view.showSessions, isTrue);
      expect(view.showSeatCounts, isTrue);
      expect(view.showSerial, isTrue);
      expect(view.badgeKey, 'badgeInstantBooking');
      expect(view.buttonKey, 'ctaBookAppointment');
    });

    test('request books but never shows a serial', () {
      final view = bookingModeView(buildChamber('c', BookingMode.request));
      expect(view.canBook, isTrue);
      expect(view.showSessions, isTrue);
      expect(view.showSerial, isFalse);
      expect(view.buttonKey, 'ctaRequestAppointment');
    });

    test('call_only does not book', () {
      final view = bookingModeView(buildChamber('c', BookingMode.callOnly));
      expect(view.canBook, isFalse);
      expect(view.showSessions, isFalse);
      expect(view.buttonKey, 'ctaGetPhoneNumber');
    });

    test('unknown has no badge and no button', () {
      final view = bookingModeView(buildChamber('c', BookingMode.unknown));
      expect(view.canBook, isFalse);
      expect(view.badgeKey, isNull);
      expect(view.buttonKey, isNull);
    });
  });

  group('availability parsing', () {
    test('parses the fixture dates and sessions', () {
      final json = jsonDecode(
        File('test/fixtures/v1/availability.json').readAsStringSync(),
      ) as Map<String, dynamic>;
      final availability = AffiliationAvailability.fromJson(json);

      expect(availability.affiliationId, isNotEmpty);
      expect(availability.facility.displayName, isNotEmpty);
      expect(availability.dates, isNotEmpty);

      final withSessions =
          availability.dates.where((d) => d.sessions.isNotEmpty).toList();
      expect(withSessions, isNotEmpty);
      final session = withSessions.first.sessions.first;
      expect(session.sessionKey, isNotEmpty);
      expect(session.status, isA<AvailabilitySessionStatus>());
    });

    test('unknown statuses parse to unknown', () {
      expect(
        availabilityDateStatusFromString('paused'),
        AvailabilityDateStatus.unknown,
      );
      expect(
        availabilitySessionStatusFromString('reopened'),
        AvailabilitySessionStatus.unknown,
      );
    });
  });

  group('request cutoff rule (frozen clock)', () {
    test('evening session stays requestable until one hour before start', () {
      // 15:59 Dhaka: 61 min to a 17:00 session, still requestable.
      expect(
        DhakaTime.requestCutoffReached(
          now: DateTime.utc(2026, 10, 15, 9, 59),
          dateIso: '2026-10-15',
          sessionStart: '17:00',
        ),
        isFalse,
      );
      // 16:01 Dhaka: 59 min to start, too late.
      expect(
        DhakaTime.requestCutoffReached(
          now: DateTime.utc(2026, 10, 15, 10, 1),
          dateIso: '2026-10-15',
          sessionStart: '17:00',
        ),
        isTrue,
      );
    });

    test('morning session stays requestable until two hours before start', () {
      // 06:59 Dhaka: 121 min to a 09:00 session, still requestable.
      expect(
        DhakaTime.requestCutoffReached(
          now: DateTime.utc(2026, 10, 15, 0, 59),
          dateIso: '2026-10-15',
          sessionStart: '09:00',
        ),
        isFalse,
      );
      // 07:01 Dhaka: 119 min to start, too late.
      expect(
        DhakaTime.requestCutoffReached(
          now: DateTime.utc(2026, 10, 15, 1, 1),
          dateIso: '2026-10-15',
          sessionStart: '09:00',
        ),
        isTrue,
      );
    });

    test('exactly at the cutoff counts as closed', () {
      // 16:00 Dhaka for a 17:00 session (1-hour cutoff).
      expect(
        DhakaTime.requestCutoffReached(
          now: DateTime.utc(2026, 10, 15, 10, 0),
          dateIso: '2026-10-15',
          sessionStart: '17:00',
        ),
        isTrue,
      );
      // 07:00 Dhaka for a 09:00 session (2-hour cutoff).
      expect(
        DhakaTime.requestCutoffReached(
          now: DateTime.utc(2026, 10, 15, 1, 0),
          dateIso: '2026-10-15',
          sessionStart: '09:00',
        ),
        isTrue,
      );
    });

    testWidgets('instant sessions ignore the request cutoff', (tester) async {
      final soon = DhakaTime.now().add(const Duration(minutes: 30));
      final dateIso = DhakaTime.isoDate(soon);
      final startHm = '${soon.hour.toString().padLeft(2, '0')}:'
          '${soon.minute.toString().padLeft(2, '0')}';

      await pumpStep1(
        tester,
        mode: BookingMode.instant,
        availability:
            availabilityWithSession(dateIso: dateIso, startHm: startHm),
      );

      expect(find.text('Too late to request — call the chamber'), findsNothing);
    });

    testWidgets('request sessions inside the cutoff are disabled', (tester) async {
      final soon = DhakaTime.now().add(const Duration(minutes: 30));
      final dateIso = DhakaTime.isoDate(soon);
      final startHm = '${soon.hour.toString().padLeft(2, '0')}:'
          '${soon.minute.toString().padLeft(2, '0')}';

      await pumpStep1(
        tester,
        mode: BookingMode.request,
        availability:
            availabilityWithSession(dateIso: dateIso, startHm: startHm),
      );

      expect(find.text('Too late to request — call the chamber'), findsOneWidget);
    });
  });

  group('step 2 booking', () {
    testWidgets('instant: posts session_key, patient_gender, otp_code and no slot',
        (tester) async {
      final adapter = await pumpStep2(
        tester,
        mode: BookingMode.instant,
        responseBody: instantBody(),
      );

      await fillAndSubmit(tester);

      expect(find.text('SL-004'), findsOneWidget);

      final options = adapter.lastOptions!;
      expect(options.path, '/bookings/doctor/');
      final body = options.data as Map<String, dynamic>;
      final keys = body.keys.toSet();
      expect(keys.contains('session_key'), isTrue);
      expect(keys.contains('patient_gender'), isTrue);
      expect(keys.contains('otp_code'), isTrue);
      expect(keys.contains('slot'), isFalse);
      expect(keys.contains('gender'), isFalse);
    });

    testWidgets('request: success shows no serial', (tester) async {
      await pumpStep2(
        tester,
        mode: BookingMode.request,
        responseBody: requestBody(),
      );

      await fillAndSubmit(tester, buttonLabel: 'Request appointment');

      expect(find.text('Request sent'), findsOneWidget);
      expect(find.text('SL-004'), findsNothing);
    });

    testWidgets('a session_key field error returns to step 1 with the message',
        (tester) async {
      await pumpStep2(
        tester,
        mode: BookingMode.instant,
        responseBody: '{"session_key":["This session is fully booked."]}',
        statusCode: 400,
      );

      await fillAndSubmit(tester);

      expect(find.text('This session is fully booked.'), findsOneWidget);
      expect(find.text('step1'), findsOneWidget);
    });
  });
}
