import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:doctors_hub_app/core/network/api_client.dart';
import 'package:doctors_hub_app/core/providers/app_providers.dart';
import 'package:doctors_hub_app/core/widgets/otp_sheet.dart';
import 'package:doctors_hub_app/core/widgets/phone_field.dart';
import 'package:doctors_hub_app/features/booking/data/booking_repository.dart';
import 'package:doctors_hub_app/features/booking/presentation/booking_success_screen.dart';
import 'package:doctors_hub_app/features/hospitals/domain/models/hospital.dart';
import 'package:doctors_hub_app/features/hospitals/presentation/hospital_page_screen.dart';
import 'package:doctors_hub_app/features/hospitals/presentation/hospital_service_booking_screen.dart';
import 'package:doctors_hub_app/features/hospitals/presentation/hospital_service_selection.dart';
import 'package:doctors_hub_app/l10n/app_localizations.dart';

import '../helpers/recording_adapter.dart';

const serviceBookingBody = '''
{
  "id": "e1f2a3b4-c5d6-7e8f-9a0b-1c2d3e4f5a6b",
  "status": "pending",
  "booking_date": "2026-10-16",
  "preferred_time": "Morning (9 am–12 pm)",
  "service_name": "Full Check-up Package",
  "facility": {
    "id": "h1",
    "display_name": "Square Hospital (Panthapath)",
    "phone": "+8801713377775"
  }
}
''';

Future<RecordingAdapter> pumpServiceBooking(WidgetTester tester) async {
  tester.view.physicalSize = const Size(1080, 2600);
  tester.view.devicePixelRatio = 2.0;
  addTearDown(() => tester.view.resetPhysicalSize());

  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();

  final adapter = RecordingAdapter(serviceBookingBody);
  final client = ApiClient(origin: 'https://example.com');
  client.dio.httpClientAdapter = adapter;

  final router = GoRouter(
    initialLocation: '/hospitals/h1/services/svc-1/book',
    routes: [
      GoRoute(
        path: '/hospitals/:idOrSlug/services/:serviceId/book',
        builder: (context, state) => HospitalServiceBookingScreen(
          idOrSlug: state.pathParameters['idOrSlug']!,
          serviceId: state.pathParameters['serviceId']!,
        ),
      ),
      GoRoute(
        path: '/hospitals/:idOrSlug',
        builder: (_, __) => const Scaffold(body: Text('hospital')),
      ),
      GoRoute(path: '/success', builder: (_, __) => const BookingSuccessScreen()),
    ],
  );

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        bookingRepositoryProvider.overrideWithValue(BookingRepository(client)),
        hospitalDetailsProvider.overrideWith(
          (ref, idOrSlug) async => const HospitalStub().hospital,
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

void main() {
  testWidgets(
      'service booking posts hospital_id, service_id, booking_date, preferred_time, otp_code',
      (tester) async {
    final adapter = await pumpServiceBooking(tester);

    // A warm navigation hands the selection over through the provider.
    final container = ProviderScope.containerOf(
      tester.element(find.byType(HospitalServiceBookingScreen)),
    );
    container.read(hospitalServiceSelectionProvider.notifier).state =
        HospitalServiceSelection(
      hospital: const HospitalStub().hospital,
      service: const HospitalStub().service,
    );
    await tester.pump();

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
    await tester.pump();

    await tester.tap(find.text('Send request'));
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

    final body = adapter.lastOptions!.data as Map<String, dynamic>;
    final keys = body.keys.toSet();
    expect(body['hospital_id'], 'h1');
    expect(body['service_id'], 'svc-1');
    expect(body['booking_date'], isNotEmpty);
    expect(body['preferred_time'], isNotEmpty);
    expect(body['otp_code'], '123456');
    expect(keys.contains('hospital'), isFalse);
    expect(keys.contains('service'), isFalse);
    expect(keys.contains('date'), isFalse);
    expect(keys.contains('gender'), isFalse);

    expect(find.textContaining('Request received'), findsOneWidget);
    expect(find.text('SERIAL'), findsNothing);
    expect(find.textContaining('৳'), findsNothing);

    final bookings = container.read(localBookingsProvider);
    expect(bookings.single.type, 'service');
    expect(bookings.single.facilityPhone, '+8801713377775');
  });
}

class HospitalStub {
  const HospitalStub();

  Hospital get hospital => const Hospital(
        id: 'h1',
        displayName: 'Square Hospital (Panthapath)',
        slug: 'square-hospital',
        phone: '+8801713377775',
      );

  HospitalServiceRef get service =>
      const HospitalServiceRef(id: 'svc-1', name: 'Full Check-up Package');
}
