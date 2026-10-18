import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:doctors_hub_app/core/models/facility_summary.dart';
import 'package:doctors_hub_app/core/network/api_client.dart';
import 'package:doctors_hub_app/core/providers/app_providers.dart';
import 'package:doctors_hub_app/core/widgets/otp_sheet.dart';
import 'package:doctors_hub_app/core/widgets/phone_field.dart';
import 'package:doctors_hub_app/features/booking/data/booking_repository.dart';
import 'package:doctors_hub_app/features/booking/presentation/booking_success_screen.dart';
import 'package:doctors_hub_app/features/location/domain/models/district.dart';
import 'package:doctors_hub_app/features/location/domain/models/division.dart';
import 'package:doctors_hub_app/features/location/domain/models/thana.dart';
import 'package:doctors_hub_app/features/tests/domain/models/test_search.dart';
import 'package:doctors_hub_app/features/tests/presentation/test_booking_screen.dart';
import 'package:doctors_hub_app/features/tests/presentation/test_selection_provider.dart';
import 'package:doctors_hub_app/l10n/app_localizations.dart';

import '../helpers/recording_adapter.dart';

TestSearchGroup buildGroup({bool priced = true}) => TestSearchGroup(
      id: 'test-1',
      name: 'Blood Grouping & Rh Factor',
      offerings: [
        LabOffering(
          id: 'lab-1',
          facility: const FacilitySummary(
            id: 'f1',
            displayName: 'BSMMU Diagnostic Laboratory',
            phone: '+88029661051',
          ),
          price: priced ? 450 : null,
          calculatedPrice: priced ? 450 : null,
          homeSampleCollection: true,
          homeSampleCharge: 100,
        ),
      ],
    );

Future<RecordingAdapter> pumpTestBooking(
  WidgetTester tester, {
  bool priced = true,
  int? thanaId,
}) async {
  tester.view.physicalSize = const Size(1080, 2600);
  tester.view.devicePixelRatio = 2.0;
  addTearDown(() => tester.view.resetPhysicalSize());

  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();

  final adapter = RecordingAdapter(
    File('test/fixtures/v1/test_booking.json').readAsStringSync(),
  );
  final client = ApiClient(origin: 'https://example.com');
  client.dio.httpClientAdapter = adapter;

  final group = buildGroup(priced: priced);
  final selection = TestBookingSelection(
    group: group,
    offering: group.offerings.first,
    divisionId: thanaId == null ? null : 1,
    districtId: thanaId == null ? null : 1,
    thanaId: thanaId,
  );

  final router = GoRouter(
    initialLocation: '/tests/test-1/labs/lab-1/book',
    routes: [
      GoRoute(
        path: '/tests/:testId/labs/:labId/book',
        builder: (context, state) => TestBookingScreen(
          testId: state.pathParameters['testId']!,
          facilityTestId: state.pathParameters['labId']!,
        ),
      ),
      GoRoute(path: '/tests', builder: (_, __) => const Scaffold(body: Text('tests'))),
      GoRoute(path: '/success', builder: (_, __) => const BookingSuccessScreen()),
    ],
  );

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        testBookingSelectionProvider.overrideWith((ref) => selection),
        bookingRepositoryProvider.overrideWithValue(
          BookingRepository(client),
        ),
        divisionsProvider.overrideWith(
          (ref) => Future.value(const [
            Division(id: 1, name: 'Dhaka', bnName: 'ঢাকা', slug: 'dhaka'),
          ]),
        ),
        districtsProvider(1).overrideWith(
          (ref) => Future.value(const [
            District(id: 1, name: 'Dhaka', slug: 'dhaka', divisionId: 1),
          ]),
        ),
        thanasProvider(1).overrideWith(
          (ref) => Future.value(const [
            Thana(id: 1, name: 'Dhanmondi', slug: 'dhanmondi', districtId: 1),
          ]),
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
  await tester.pump(const Duration(milliseconds: 100));
  return adapter;
}

Future<void> fillPatient(WidgetTester tester, {String? address}) async {
  await tester.enterText(
    find.widgetWithText(TextField, 'Enter full name'),
    'Test Patient',
  );
  await tester.enterText(
    find.descendant(
      of: find.byType(PhoneField),
      matching: find.byType(TextField),
    ),
    '01712345678',
  );
  if (address != null) {
    await tester.enterText(
      find.widgetWithText(TextField, 'House, Road, Area, Landmark...'),
      address,
    );
  }
  await tester.pump();
}

Future<void> submitWithOtp(WidgetTester tester) async {
  await tester.ensureVisible(find.text('Confirm booking'));
  await tester.tap(find.text('Confirm booking'));
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
}

void main() {
  testWidgets('home pickup sends collection_type, thana and address',
      (tester) async {
    final adapter = await pumpTestBooking(tester, thanaId: 1);

    await tester.ensureVisible(find.textContaining('Home pickup'));
    await tester.tap(find.textContaining('Home pickup'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await fillPatient(tester, address: 'House 5, Road 3');
    await submitWithOtp(tester);

    final body = adapter.lastOptions!.data as Map<String, dynamic>;
    expect(body['collection_type'], 'home');
    expect(body['pickup_thana_id'], 1);
    expect(body['pickup_address_line'], 'House 5, Road 3');
    expect(body['otp_code'], '123456');
    expect(body['preferred_time'], '07:00');
    expect(body.containsKey('notes'), isFalse);
    expect(body.containsKey('pickupDate'), isFalse);
  });

  testWidgets('lab visit sends collection_type center and no pickup fields',
      (tester) async {
    final adapter = await pumpTestBooking(tester);

    await fillPatient(tester);
    await submitWithOtp(tester);

    final body = adapter.lastOptions!.data as Map<String, dynamic>;
    expect(body['collection_type'], 'center');
    expect(body['preferred_time'], '07:00');
    expect(body.containsKey('pickup_thana_id'), isFalse);
    expect(body.containsKey('pickup_address_line'), isFalse);
  });

  testWidgets('a null-price offering never shows ৳0', (tester) async {
    await pumpTestBooking(tester, priced: false);

    expect(find.textContaining('৳0'), findsNothing);
    expect(find.text('Price confirmed at the lab'), findsOneWidget);
  });
}
