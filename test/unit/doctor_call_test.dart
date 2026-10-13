import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:doctors_hub_app/core/models/facility_summary.dart';
import 'package:doctors_hub_app/core/network/api_client.dart';
import 'package:doctors_hub_app/core/network/app_failure.dart';
import 'package:doctors_hub_app/core/providers/app_providers.dart';
import 'package:doctors_hub_app/core/widgets/otp_sheet.dart';
import 'package:doctors_hub_app/core/widgets/phone_field.dart';
import 'package:doctors_hub_app/features/booking/data/booking_repository.dart';
import 'package:doctors_hub_app/features/booking/domain/models/booking_result.dart';
import 'package:doctors_hub_app/features/booking/presentation/doctor_call_screen.dart';
import 'package:doctors_hub_app/features/doctors/data/doctor_repository.dart';
import 'package:doctors_hub_app/features/doctors/domain/models/chamber.dart';
import 'package:doctors_hub_app/features/doctors/domain/models/doctor.dart';
import 'package:doctors_hub_app/features/doctors/domain/models/schedule.dart';
import 'package:doctors_hub_app/l10n/app_localizations.dart';

class FakeDoctorRepository extends DoctorRepository {
  FakeDoctorRepository(this.doctor) : super(ApiClient());

  final Doctor doctor;

  @override
  Future<Doctor> getDoctorDetails(String idOrSlug) async => doctor;
}

class FakeCallRepository extends BookingRepository {
  FakeCallRepository({this.failure}) : super(ApiClient());

  final AppFailure? failure;
  int callLeadCalls = 0;
  String? lastName;
  String? lastPhone;
  String? lastOtp;

  @override
  Future<int?> sendOtp({
    required String phone,
    required String purpose,
  }) async {
    return 300;
  }

  @override
  Future<CallLeadResult> createCallLead({
    required String affiliationId,
    required String patientName,
    required String patientPhone,
    required String otpCode,
    int? patientAge,
    String? patientGender,
  }) async {
    callLeadCalls++;
    lastName = patientName;
    lastPhone = patientPhone;
    lastOtp = otpCode;
    if (failure != null) throw failure!;
    final json = jsonDecode(
      File('test/fixtures/v1/call_lead.json').readAsStringSync(),
    ) as Map<String, dynamic>;
    return CallLeadResult.fromJson(json);
  }
}

Doctor buildDoctor() => const Doctor(
      id: 'd1',
      name: 'A. B. M. Abdullah',
      slug: 'prof-dr-a-b-m-abdullah',
      chambers: [
        Chamber(
          id: 'c1',
          bookingMode: BookingMode.callOnly,
          facility: FacilitySummary(
            id: 'f1',
            displayName: 'Prof. Abdullah Consultation Chamber (Green Road)',
            address: '18/F Panthapath',
          ),
          schedules: [
            DoctorSchedule(
              dayOfWeek: 'Sunday',
              startTime: '18:00:00',
              endTime: '21:00:00',
            ),
          ],
        ),
      ],
    );

Future<void> pumpCallScreen(
  WidgetTester tester, {
  required FakeCallRepository repo,
}) async {
  tester.view.physicalSize = const Size(1080, 2200);
  tester.view.devicePixelRatio = 2.0;
  addTearDown(() => tester.view.resetPhysicalSize());

  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();

  final router = GoRouter(
    initialLocation: '/doctors/d1/call?chamber=c1',
    routes: [
      GoRoute(
        path: '/doctors/:id/call',
        builder: (context, state) => DoctorCallScreen(
          doctorId: 'd1',
          chamberId: state.uri.queryParameters['chamber'] ?? '',
        ),
      ),
      GoRoute(
        path: '/doctors/:id',
        builder: (_, __) => const Scaffold(body: Text('profile')),
      ),
    ],
  );

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        doctorRepositoryProvider
            .overrideWithValue(FakeDoctorRepository(buildDoctor())),
        bookingRepositoryProvider.overrideWithValue(repo),
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
}

Future<void> completeOtp(WidgetTester tester) async {
  await tester.enterText(find.byType(TextField).first, 'Test Patient');
  await tester.enterText(
    find.descendant(
      of: find.byType(PhoneField),
      matching: find.byType(TextField),
    ),
    '01712345678',
  );
  await tester.pump();

  await tester.tap(find.text('Get phone number'));
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
  testWidgets('call flow has no date or session picker and shows numbers after OTP',
      (tester) async {
    final repo = FakeCallRepository();
    await pumpCallScreen(tester, repo: repo);

    expect(find.text('Select date'), findsNothing);
    expect(find.text('Select session'), findsNothing);

    await completeOtp(tester);

    expect(repo.callLeadCalls, 1);
    expect(repo.lastOtp, '123456');
    expect(find.text('+8801711223344'), findsOneWidget);
    expect(find.text('01879542300'), findsOneWidget);
    expect(find.text('Select date'), findsNothing);
    expect(find.text('Select session'), findsNothing);
  });

  testWidgets('no_numbers shows the message and no number buttons',
      (tester) async {
    final repo = FakeCallRepository(
      failure: const ValidationFailure(
        message: 'No numbers',
        code: 'no_numbers',
      ),
    );
    await pumpCallScreen(tester, repo: repo);

    await completeOtp(tester);

    expect(
      find.text(
        'This chamber has no phone number listed yet. Please try another chamber.',
      ),
      findsOneWidget,
    );
    expect(find.text('+8801711223344'), findsNothing);
  });
}
