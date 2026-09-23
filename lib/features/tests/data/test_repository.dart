import '../../../core/network/api_client.dart';
import '../../../core/network/unwrap_list.dart';
import '../domain/models/diagnostic_test.dart';
import '../domain/models/facility_test.dart';
import '../domain/models/test_category.dart';

class TestRepository {
  TestRepository(this._apiClient);

  final ApiClient _apiClient;
  List<TestCategory>? _cachedCategories;

  Future<List<TestCategory>> getCategories({bool forceRefresh = false}) async {
    if (!forceRefresh && _cachedCategories != null && _cachedCategories!.isNotEmpty) {
      return _cachedCategories!;
    }

    final response = await _apiClient.get(
      '/test-categories/',
      queryParameters: {'page_size': 100},
    );

    final paginated = unwrapList<TestCategory>(
      response.data,
      (json) => TestCategory.fromJson(json as Map<String, dynamic>),
    );
    _cachedCategories = paginated.results;
    return _cachedCategories!;
  }

  Future<PaginatedList<DiagnosticTest>> getTests({
    String? category,
    String? search,
    int page = 1,
    int pageSize = 20,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'page_size': pageSize,
    };

    if (category != null && category.isNotEmpty && category != 'all') {
      queryParams['category'] = category;
    }
    if (search != null && search.trim().isNotEmpty) {
      queryParams['search'] = search.trim();
    }

    final response = await _apiClient.get(
      '/tests/',
      queryParameters: queryParams,
    );

    return unwrapList<DiagnosticTest>(
      response.data,
      (json) => DiagnosticTest.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<List<FacilityTest>> getFacilityTestsForTest(
    String testId, {
    String? division,
  }) async {
    final response = await _apiClient.get(
      '/facility-tests/',
      queryParameters: {
        'test': testId,
        'page_size': 100,
      },
    );

    final paginated = unwrapList<FacilityTest>(
      response.data,
      (json) => FacilityTest.fromJson(json as Map<String, dynamic>),
    );

    var list = paginated.results;

    // Filter by division client-side if specified
    if (division != null && division.isNotEmpty && division != 'all') {
      list = list.where((ft) {
        if (ft.facilityDivision == null) return true;
        return ft.facilityDivision!.toLowerCase() == division.toLowerCase();
      }).toList();
    }

    // Sort by price ascending
    list.sort((a, b) => a.price.compareTo(b.price));

    return list;
  }
}
