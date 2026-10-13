import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:doctors_hub_app/core/app_config/app_config_providers.dart';
import 'package:doctors_hub_app/core/models/facility_summary.dart';
import 'package:doctors_hub_app/core/network/api_client.dart';
import 'package:doctors_hub_app/core/providers/app_providers.dart';
import 'package:doctors_hub_app/features/home/presentation/home_screen.dart';
import 'package:doctors_hub_app/features/hospitals/domain/models/hospital.dart';
import 'package:doctors_hub_app/features/location/domain/models/division.dart';
import 'package:doctors_hub_app/features/tests/data/test_repository.dart';
import 'package:doctors_hub_app/features/tests/domain/models/test_category.dart';
import 'package:doctors_hub_app/features/tests/domain/models/test_search.dart';
import 'package:doctors_hub_app/features/tests/presentation/tests_catalogue_screen.dart';
import 'package:doctors_hub_app/l10n/app_localizations.dart';

class CountingTestRepository extends TestRepository {
  CountingTestRepository() : super(ApiClient());

  int searchCalls = 0;

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
    searchCalls++;
    return const TestSearchPage(
      groups: [
        TestSearchGroup(
          id: 'test-1',
          name: 'CBC',
          offerings: [
            LabOffering(
              id: 'lab-1',
              facility: FacilitySummary(id: 'lab-1', displayName: 'Lab One'),
            ),
          ],
        ),
      ],
      count: 1,
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
  testWidgets('Home search keeps the division as an id', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    String? pushedLocation;
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(path: '/', builder: (_, __) => const HomeScreen()),
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
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Open the division dropdown and pick Dhaka.
    await tester.tap(find.text('All Bangladesh'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Dhaka').last);
    await tester.pumpAndSettle();

    // Run the search.
    await tester.tap(find.text('Search'));
    await tester.pumpAndSettle();

    expect(pushedLocation, contains('division_id=1'));
    expect(pushedLocation, isNot(contains('division=Dhaka')));
  });

  testWidgets('A Home hospital row opens the hospital page', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    String? pushedLocation;
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(path: '/', builder: (_, __) => const HomeScreen()),
        GoRoute(
          path: '/doctors',
          builder: (context, state) {
            pushedLocation = state.uri.toString();
            return const Scaffold(body: Text('doctors'));
          },
        ),
        GoRoute(
          path: '/hospitals/:idOrSlug',
          builder: (context, state) {
            pushedLocation = state.uri.toString();
            return const Scaffold(body: Text('hospital'));
          },
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          appConfigProvider.overrideWith((ref) async => null),
          divisionsProvider.overrideWith((ref) => Future.value(const [])),
          specialtiesProvider.overrideWith((ref) => Future.value(const [])),
          testCategoriesProvider.overrideWith((ref) => Future.value(const [])),
          hospitalCategoriesProvider.overrideWith((ref) => Future.value(const [])),
          homePopularDoctorsProvider.overrideWith((ref) => Future.value(const [])),
          homeTopHospitalsProvider.overrideWith(
            (ref) => Future.value(const [
              Hospital(
                id: 'hosp-1',
                displayName: 'Square Hospital (Panthapath)',
                name: 'Square Hospital',
              ),
            ]),
          ),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    await tester.tap(find.text('Square Hospital (Panthapath)').first);
    await tester.pumpAndSettle();

    expect(pushedLocation, '/hospitals/hosp-1');
  });

  testWidgets('Tests tab issues exactly one search request per page',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final repo = CountingTestRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          testRepositoryProvider.overrideWithValue(repo),
          testCategoriesProvider.overrideWith((ref) => Future.value(const [])),
          divisionsProvider.overrideWith((ref) => Future.value(const [])),
          districtsProvider(null).overrideWith((ref) => Future.value(const [])),
          thanasProvider(null).overrideWith((ref) => Future.value(const [])),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: TestsCatalogueScreen(),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(repo.searchCalls, 1);
  });
}
