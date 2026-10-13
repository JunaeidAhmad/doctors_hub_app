import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:doctors_hub_app/core/network/api_client.dart';
import 'package:doctors_hub_app/core/network/app_failure.dart';
import 'package:doctors_hub_app/core/providers/app_providers.dart';
import 'package:doctors_hub_app/core/widgets/otp_sheet.dart';
import 'package:doctors_hub_app/features/booking/data/booking_repository.dart';
import 'package:doctors_hub_app/l10n/app_localizations.dart';

class FakeBookingRepository extends BookingRepository {
  FakeBookingRepository() : super(ApiClient());

  int sendCalls = 0;
  String? lastPurpose;
  String? lastPhone;
  AppFailure? sendFailure;

  @override
  Future<int?> sendOtp({
    required String phone,
    required String purpose,
  }) async {
    sendCalls++;
    lastPhone = phone;
    lastPurpose = purpose;
    if (sendFailure != null) throw sendFailure!;
    return 300;
  }
}

Future<void> pumpSheet(
  WidgetTester tester, {
  required FakeBookingRepository repo,
  required Future<AppFailure?> Function(String code) onSubmit,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [bookingRepositoryProvider.overrideWithValue(repo)],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => OtpSheet.show(
                context,
                phone: '01712345678',
                purpose: 'doctor_booking',
                onSubmit: onSubmit,
              ),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    ),
  );

  await tester.tap(find.text('open'));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
}

Future<void> enterCodeAndSubmit(WidgetTester tester) async {
  await tester.enterText(find.byType(TextField), '123456');
  await tester.pump();
  await tester.tap(find.text('Verify & Confirm'));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));
}

void main() {
  testWidgets('sends one code on open with the given purpose', (tester) async {
    final repo = FakeBookingRepository();
    await pumpSheet(
      tester,
      repo: repo,
      onSubmit: (_) async => null,
    );

    expect(repo.sendCalls, 1);
    expect(repo.lastPurpose, 'doctor_booking');
    expect(repo.lastPhone, '01712345678');
    expect(find.byType(OtpSheet), findsOneWidget);
  });

  testWidgets('an otp_code field error keeps the sheet open',
      (tester) async {
    final repo = FakeBookingRepository();
    await pumpSheet(
      tester,
      repo: repo,
      onSubmit: (_) async => const ValidationFailure(
        message: 'Invalid code',
        fieldErrors: {
          'otp_code': ['The code is not valid.'],
        },
      ),
    );

    await enterCodeAndSubmit(tester);

    expect(find.text('The code is not valid.'), findsOneWidget);
    expect(find.byType(OtpSheet), findsOneWidget);
  });

  testWidgets('success closes the sheet', (tester) async {
    final repo = FakeBookingRepository();
    await pumpSheet(
      tester,
      repo: repo,
      onSubmit: (_) async => null,
    );

    await enterCodeAndSubmit(tester);
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byType(OtpSheet), findsNothing);
  });

  testWidgets('resend is disabled during the 60s countdown', (tester) async {
    final repo = FakeBookingRepository();
    await pumpSheet(
      tester,
      repo: repo,
      onSubmit: (_) async => null,
    );

    expect(find.text('Resend in 60s'), findsOneWidget);

    await tester.tap(find.text('Resend code'));
    await tester.pump();

    expect(repo.sendCalls, 1);
  });
}
