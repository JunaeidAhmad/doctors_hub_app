import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:doctors_hub_app/app.dart';
import 'package:doctors_hub_app/core/app_config/app_config_providers.dart';
import 'package:doctors_hub_app/core/network/api_client.dart';
import 'package:doctors_hub_app/core/providers/app_providers.dart';
import 'package:doctors_hub_app/features/home/presentation/home_screen.dart';
import 'package:doctors_hub_app/features/hospitals/data/hospital_repository.dart';
import 'package:doctors_hub_app/features/hospitals/domain/models/hospital.dart';
import 'package:doctors_hub_app/features/hospitals/presentation/hospital_page_screen.dart';
import 'package:doctors_hub_app/features/hospitals/presentation/hospitals_screen.dart';
import 'package:doctors_hub_app/features/location/domain/models/division.dart';
import 'package:doctors_hub_app/l10n/app_localizations.dart';

class FakeHospitalRepository extends HospitalRepository {
  FakeHospitalRepository(this.hospital) : super(ApiClient());

  final Hospital hospital;

  @override
  Future<Hospital> getHospital(String idOrSlug) async => hospital;

}

Future<void> loadAppFonts() async {
  final archivo = FontLoader('Archivo')
    ..addFont(rootBundle.load('assets/fonts/Archivo.ttf'));
  final mono = FontLoader('JetBrainsMono')
    ..addFont(rootBundle.load('assets/fonts/JetBrainsMono.ttf'));
  final bengali = FontLoader('NotoSansBengali')
    ..addFont(rootBundle.load('assets/fonts/NotoSansBengali.ttf'));
  await Future.wait([archivo.load(), mono.load(), bengali.load()]);
}

void main() {
  setUpAll(loadAppFonts);

  testWidgets('the hospital page hides empty phones and the services section',
      (tester) async {
    tester.view.physicalSize = const Size(1080, 2200);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    const hospital = Hospital(
      id: 'h1',
      displayName: 'Square Hospital (Panthapath)',
      slug: 'square-hospital',
      category: 'General',
      area: 'Panthapath',
      areaBn: 'পান্থপথ',
      district: 'Dhaka',
      districtBn: 'ঢাকা',
      address: '18/F Panthapath',
      doctorCount: 3,
      testCount: 0,
    );

    String? pushedLocation;
    final router = GoRouter(
      initialLocation: '/hospitals/h1',
      routes: [
        GoRoute(
          path: '/hospitals/:idOrSlug',
          builder: (context, state) =>
              HospitalPageScreen(idOrSlug: state.pathParameters['idOrSlug']!),
        ),
        GoRoute(
          path: '/doctors',
          builder: (context, state) {
            pushedLocation = state.uri.toString();
            return const Scaffold(body: Text('doctors'));
          },
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          hospitalRepositoryProvider.overrideWithValue(
            FakeHospitalRepository(hospital),
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

    expect(find.text('Square Hospital (Panthapath)'), findsOneWidget);
    expect(find.text('Panthapath, Dhaka'), findsOneWidget);
    expect(find.text('Phone'), findsNothing);
    expect(find.text('Emergency'), findsNothing);
    expect(find.text('Ambulance'), findsNothing);
    expect(find.text('Services'), findsNothing);
    expect(find.text('Doctors here (3)'), findsOneWidget);
    expect(find.textContaining('Tests here'), findsNothing);

    await tester.tap(find.text('Doctors here (3)'));
    await tester.pumpAndSettle();
    expect(pushedLocation, contains('facility_id=h1'));
    expect(pushedLocation, contains('facility_name='));
  });

  testWidgets('the shell has five tabs including Hospitals', (tester) async {
    tester.view.physicalSize = const Size(640, 1400); // 320 px logical width
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          appConfigProvider.overrideWith((ref) async => null),
          divisionsProvider.overrideWith(
            (ref) => Future.value(const [
              Division(id: 1, name: 'Dhaka', bnName: 'ঢাকা', slug: 'dhaka'),
            ]),
          ),
          specialtiesProvider.overrideWith((ref) => Future.value(const [])),
          testCategoriesProvider.overrideWith((ref) => Future.value(const [])),
          hospitalCategoriesProvider.overrideWith((ref) => Future.value(const [])),
          homePopularDoctorsProvider.overrideWith((ref) => Future.value(const [])),
          homeTopHospitalsProvider.overrideWith((ref) => Future.value(const [])),
        ],
        child: const DoctorsHubApp(),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byIcon(Icons.local_hospital_outlined), findsOneWidget);
    expect(find.byIcon(Icons.calendar_today_outlined), findsWidgets);

    await tester.tap(find.byIcon(Icons.local_hospital_outlined));
    await tester.pumpAndSettle();
    expect(find.byType(HospitalsScreen), findsOneWidget);

    // Switch away and back: the branch keeps its state (filters included).
    await tester.tap(find.byIcon(Icons.home_outlined));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.local_hospital_outlined));
    await tester.pumpAndSettle();
    expect(find.byType(HospitalsScreen), findsOneWidget);
  });
}
