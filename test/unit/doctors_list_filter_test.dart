import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:doctors_hub_app/core/network/api_client.dart';
import 'package:doctors_hub_app/core/network/unwrap_list.dart';
import 'package:doctors_hub_app/core/providers/app_providers.dart';
import 'package:doctors_hub_app/features/doctors/data/doctor_repository.dart';
import 'package:doctors_hub_app/features/doctors/domain/models/doctor.dart';
import 'package:doctors_hub_app/features/doctors/domain/models/specialty.dart';
import 'package:doctors_hub_app/features/doctors/presentation/doctors_list_screen.dart';
import 'package:doctors_hub_app/features/hospitals/domain/models/hospital.dart';
import 'package:doctors_hub_app/features/location/domain/models/division.dart';
import 'package:doctors_hub_app/features/location/domain/models/district.dart';
import 'package:doctors_hub_app/features/location/domain/models/thana.dart';

class MockDoctorRepository extends DoctorRepository {
  MockDoctorRepository() : super(ApiClient());

  @override
  Future<PaginatedList<Doctor>> searchDoctors({
    String? search,
    String? specialty,
    String? division,
    int? divisionId,
    String? district,
    int? districtId,
    String? area,
    int? thanaId,
    String? hospital,
    String? facility,
    String? day,
    String? gender,
    int page = 1,
    int pageSize = 20,
  }) async {
    return const PaginatedList(results: [], count: 0);
  }
}

void main() {
  testWidgets('DoctorsListScreen toggles filter panel with all filter options',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2200);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    final testSpecialties = [
      const Specialty(id: '1', name: 'Cardiology', slug: 'cardiology'),
    ];

    final testDivisions = [
      const Division(id: 1, name: 'Dhaka', bnName: 'ঢাকা', slug: 'dhaka'),
    ];

    final testDistricts = [
      const District(id: 1, name: 'Dhaka', slug: 'dhaka', divisionId: 1),
    ];

    final testThanas = [
      const Thana(id: 1, name: 'Dhanmondi', slug: 'dhanmondi', districtId: 1),
    ];

    final testFacilities = [
      const Hospital(
        id: 'hosp-1',
        name: 'Square Hospital',
        slug: 'square-hospital',
      ),
    ];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          doctorRepositoryProvider.overrideWithValue(MockDoctorRepository()),
          specialtiesProvider.overrideWith((ref) => Future.value(testSpecialties)),
          facilitiesProvider.overrideWith((ref) => Future.value(testFacilities)),
          divisionsProvider.overrideWith((ref) => Future.value(testDivisions)),
          districtsProvider(null).overrideWith((ref) => Future.value(testDistricts)),
          districtsProvider(1).overrideWith((ref) => Future.value(testDistricts)),
          thanasProvider(null).overrideWith((ref) => Future.value(testThanas)),
          thanasProvider(1).overrideWith((ref) => Future.value(testThanas)),
        ],
        child: const MaterialApp(
          home: DoctorsListScreen(),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // 1. Filter button should be present initially in "Filters" state
    expect(find.text('Filters'), findsOneWidget);
    expect(find.byIcon(Icons.tune), findsOneWidget);

    // Filter panel should be hidden initially
    expect(find.text('FILTER OPTIONS'), findsNothing);
    expect(find.text('HOSPITAL & DIAGNOSTIC CENTER'), findsNothing);

    // 2. Tap filter button to open filter panel
    await tester.tap(find.text('Filters'));
    await tester.pump();

    // Now filter button says "Hide"
    expect(find.text('Hide'), findsOneWidget);

    // Filter options are visible
    expect(find.text('FILTER OPTIONS'), findsOneWidget);
    expect(find.text('HOSPITAL & DIAGNOSTIC CENTER'), findsOneWidget);
    expect(find.text('LOCATION'), findsOneWidget);
    expect(find.text('VISITING DAYS'), findsOneWidget);
    expect(find.text('DOCTOR GENDER'), findsOneWidget);

    // Check visiting days options
    expect(find.text('Fri'), findsOneWidget);
    expect(find.text('Sat'), findsOneWidget);
    expect(find.text('All Days'), findsOneWidget);

    // Check gender options
    expect(find.text('All'), findsWidgets);
    expect(find.text('Male'), findsOneWidget);
    expect(find.text('Female'), findsOneWidget);

    // 3. Tap "Hide" button to hide the filter panel
    await tester.tap(find.text('Hide'));
    await tester.pump();

    // Panel should now be hidden again
    expect(find.text('FILTER OPTIONS'), findsNothing);
    expect(find.text('HOSPITAL & DIAGNOSTIC CENTER'), findsNothing);
    expect(find.text('Filters'), findsOneWidget);
  });
}
