import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:doctors_hub_app/core/network/api_client.dart';
import 'package:doctors_hub_app/core/network/unwrap_list.dart';
import 'package:doctors_hub_app/core/providers/app_providers.dart';
import 'package:doctors_hub_app/features/hospitals/data/hospital_repository.dart';
import 'package:doctors_hub_app/features/hospitals/domain/models/hospital.dart';
import 'package:doctors_hub_app/features/hospitals/domain/models/hospital_category.dart';
import 'package:doctors_hub_app/features/hospitals/presentation/hospitals_screen.dart';
import 'package:doctors_hub_app/features/tests/data/test_repository.dart';
import 'package:doctors_hub_app/features/tests/domain/models/test_search.dart';
import 'package:doctors_hub_app/features/tests/domain/models/test_category.dart';
import 'package:doctors_hub_app/features/tests/presentation/tests_catalogue_screen.dart';
import 'package:doctors_hub_app/features/location/domain/models/division.dart';
import 'package:doctors_hub_app/features/location/domain/models/district.dart';
import 'package:doctors_hub_app/features/location/domain/models/thana.dart';

class MockHospitalRepository extends HospitalRepository {
  MockHospitalRepository() : super(ApiClient());

  @override
  Future<PaginatedList<Hospital>> getHospitals({
    String? search,
    String? category,
    int? divisionId,
    int? districtId,
    int? thanaId,
    String? ownershipType,
    int page = 1,
    int pageSize = 20,
  }) async {
    return const PaginatedList(results: [], count: 0);
  }

  @override
  Future<List<HospitalCategory>> getCategories({bool forceRefresh = false}) async {
    return [];
  }
}

class MockTestRepository extends TestRepository {
  MockTestRepository() : super(ApiClient());

  @override
  Future<TestSearchPage> searchTests({
    String? q,
    String? testcat,
    int? divisionId,
    int? districtId,
    int? thanaId,
    String? locationId,
    String? locationName,
    String? fulfillment,
    String? ownership,
    String ordering = 'price',
    int page = 1,
    int pageSize = 20,
  }) async {
    return const TestSearchPage(
      groups: [],
      count: 0,
      next: null,
      facets: TestSearchFacets(),
    );
  }

  @override
  Future<List<TestCategory>> getCategories({bool forceRefresh = false}) async {
    return [];
  }
}

void main() {
  final testDivisions = [
    const Division(id: 1, name: 'Dhaka', bnName: 'ঢাকা', slug: 'dhaka'),
  ];
  final testDistricts = [
    const District(id: 1, name: 'Dhaka', slug: 'dhaka', divisionId: 1),
  ];
  final testThanas = [
    const Thana(id: 1, name: 'Dhanmondi', slug: 'dhanmondi', districtId: 1),
  ];

  testWidgets('HospitalsScreen toggles filter panel with location and ownership',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2200);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          hospitalRepositoryProvider.overrideWithValue(MockHospitalRepository()),
          divisionsProvider.overrideWith((ref) => Future.value(testDivisions)),
          districtsProvider(null).overrideWith((ref) => Future.value(testDistricts)),
          districtsProvider(1).overrideWith((ref) => Future.value(testDistricts)),
          thanasProvider(null).overrideWith((ref) => Future.value(testThanas)),
          thanasProvider(1).overrideWith((ref) => Future.value(testThanas)),
          hospitalCategoriesProvider.overrideWith((ref) => Future.value([])),
        ],
        child: const MaterialApp(
          home: HospitalsScreen(),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Filter button exists
    expect(find.text('Filters'), findsOneWidget);
    expect(find.text('FILTER OPTIONS'), findsNothing);

    // Tap to open filters
    await tester.tap(find.text('Filters'));
    await tester.pump();

    // Now open
    expect(find.text('Hide'), findsOneWidget);
    expect(find.text('FILTER OPTIONS'), findsOneWidget);
    expect(find.text('LOCATION'), findsOneWidget);
    expect(find.text('OWNERSHIP TYPE'), findsOneWidget);
    expect(find.text('Private'), findsOneWidget);
    expect(find.text('Govt'), findsOneWidget);

    // Tap Hide
    await tester.tap(find.text('Hide'));
    await tester.pump();
    expect(find.text('FILTER OPTIONS'), findsNothing);
  });

  testWidgets('TestsCatalogueScreen toggles filter panel with location, fulfillment, and ownership',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2200);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          testRepositoryProvider.overrideWithValue(MockTestRepository()),
          divisionsProvider.overrideWith((ref) => Future.value(testDivisions)),
          districtsProvider(null).overrideWith((ref) => Future.value(testDistricts)),
          districtsProvider(1).overrideWith((ref) => Future.value(testDistricts)),
          thanasProvider(null).overrideWith((ref) => Future.value(testThanas)),
          thanasProvider(1).overrideWith((ref) => Future.value(testThanas)),
          testCategoriesProvider.overrideWith((ref) => Future.value([])),
        ],
        child: const MaterialApp(
          home: TestsCatalogueScreen(),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Filter button exists
    expect(find.text('Filters'), findsOneWidget);
    expect(find.text('FILTER OPTIONS'), findsNothing);

    // Tap to open filters
    await tester.tap(find.text('Filters'));
    await tester.pump();

    // Now open
    expect(find.text('Hide'), findsOneWidget);
    expect(find.text('FILTER OPTIONS'), findsOneWidget);
    expect(find.text('LOCATION'), findsOneWidget);
    expect(find.text('FULFILLMENT'), findsOneWidget);
    expect(find.text('OWNERSHIP TYPE'), findsOneWidget);
    expect(find.text('Home Pickup'), findsOneWidget);
    expect(find.text('Hospital Lab'), findsOneWidget);

    // Tap Hide
    await tester.tap(find.text('Hide'));
    await tester.pump();
    expect(find.text('FILTER OPTIONS'), findsNothing);
  });
}
