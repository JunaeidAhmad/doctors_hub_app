import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:doctors_hub_app/app.dart';
import 'package:doctors_hub_app/core/app_config/app_config_providers.dart';
import 'package:doctors_hub_app/core/providers/app_providers.dart';
import 'package:doctors_hub_app/features/doctors/domain/models/doctor.dart';
import 'package:doctors_hub_app/features/doctors/domain/models/specialty.dart';
import 'package:doctors_hub_app/features/home/presentation/home_screen.dart';
import 'package:doctors_hub_app/features/hospitals/domain/models/hospital.dart';
import 'package:doctors_hub_app/features/hospitals/domain/models/hospital_category.dart';
import 'package:doctors_hub_app/features/location/domain/models/division.dart';
import 'package:doctors_hub_app/features/tests/domain/models/test_category.dart';

void main() {
  testWidgets('App renders Home screen with mocked data', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    final testDivisions = [
      const Division(id: 1, name: 'Dhaka', bnName: 'ঢাকা', slug: 'dhaka'),
      const Division(id: 2, name: 'Chattogram', bnName: 'চট্টগ্রাম', slug: 'chattogram'),
    ];

    final testSpecialties = [
      const Specialty(id: '1', name: 'Cardiology', slug: 'cardiology', doctorCount: 15),
      const Specialty(id: '2', name: 'Dermatology', slug: 'dermatology', doctorCount: 8),
    ];

    final testDoctors = [
      const Doctor(
        id: 'doc-1',
        name: 'Dr. John Doe',
        slug: 'dr-john-doe',
      ),
    ];

    final testCategories = [
      const TestCategory(id: 'cat-1', name: 'Blood Test', slug: 'blood-test'),
    ];

    final testHospitalCategories = [
      const HospitalCategory(id: '1', name: 'General Hospital', slug: 'general'),
    ];

    final testHospitals = [
      const Hospital(
        id: 'hosp-1',
        displayName: 'Dhaka Medical Center',
        name: 'Dhaka Medical Center',
        slug: 'dhaka-medical-center',
        category: 'Hospital',
        area: 'Dhanmondi',
        doctorCount: 25,
      ),
    ];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          appConfigProvider.overrideWith((ref) async => null),
          divisionsProvider.overrideWith((ref) => Future.value(testDivisions)),
          specialtiesProvider.overrideWith((ref) => Future.value(testSpecialties)),
          homePopularDoctorsProvider.overrideWith((ref) => Future.value(testDoctors)),
          testCategoriesProvider.overrideWith((ref) => Future.value(testCategories)),
          hospitalCategoriesProvider.overrideWith((ref) => Future.value(testHospitalCategories)),
          homeTopHospitalsProvider.overrideWith((ref) => Future.value(testHospitals)),
        ],
        child: const DoctorsHubApp(),
      ),
    );

    // Initial pump
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Verify key elements
    expect(find.text('DOCTORS HUB'), findsOneWidget);
    expect(find.text('Specialties'), findsOneWidget);
    expect(find.text('Cardiology'), findsOneWidget);
    expect(find.text('Hospitals'), findsNWidgets(3));
  });
}
