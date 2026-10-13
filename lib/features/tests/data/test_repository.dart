import '../../../core/network/api_client.dart';
import '../../../core/network/unwrap_list.dart';
import '../domain/models/test_category.dart';
import '../domain/models/test_search.dart';

class TestSearchPage {
  const TestSearchPage({
    required this.groups,
    required this.count,
    required this.next,
    required this.facets,
  });

  final List<TestSearchGroup> groups;
  final int count;
  final String? next;
  final TestSearchFacets facets;

  bool get hasMore => next != null && next!.isNotEmpty;

  factory TestSearchPage.fromJson(Map<String, dynamic> json) {
    final groups = <TestSearchGroup>[];
    final results = json['results'];
    if (results is List) {
      for (final item in results) {
        if (item is Map) {
          groups.add(TestSearchGroup.fromJson(Map<String, dynamic>.from(item)));
        }
      }
    }
    final facetsRaw = json['facets'];
    return TestSearchPage(
      groups: groups,
      count: (json['count'] as num?)?.toInt() ?? groups.length,
      next: json['next'] is String ? json['next'] as String : null,
      facets: TestSearchFacets.fromJson(
        facetsRaw is Map ? Map<String, dynamic>.from(facetsRaw) : null,
      ),
    );
  }
}

class TestRepository {
  TestRepository(this._apiClient);

  final ApiClient _apiClient;
  List<TestCategory>? _cachedCategories;

  Future<List<TestCategory>> getCategories({bool forceRefresh = false}) async {
    if (!forceRefresh &&
        _cachedCategories != null &&
        _cachedCategories!.isNotEmpty) {
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

  /// One server-side call for the tests tab: groups with offerings, facets,
  /// count and `next`. `page_size` is capped at 50 by the server.
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
    final queryParams = <String, dynamic>{
      'page': page,
      'page_size': pageSize > 50 ? 50 : pageSize,
      'ordering': ordering,
    };

    if (q != null && q.trim().isNotEmpty) {
      queryParams['q'] = q.trim();
    }
    if (testcat != null && testcat.isNotEmpty) {
      queryParams['testcat'] = testcat;
    }
    if (divisionId != null) {
      queryParams['division_id'] = divisionId;
    }
    if (districtId != null) {
      queryParams['district_id'] = districtId;
    }
    if (thanaId != null) {
      queryParams['thana_id'] = thanaId;
    }
    if (locationId != null) {
      queryParams['location_id'] = locationId;
    }
    if (fulfillment != null && fulfillment.isNotEmpty && fulfillment != 'all') {
      queryParams['fulfillment'] = fulfillment;
    }
    if (ownership != null && ownership.isNotEmpty && ownership != 'all') {
      queryParams['ownership'] = ownership;
    }

    final response = await _apiClient.get(
      '/facility-tests/search/',
      queryParameters: queryParams,
    );

    final data = response.data;
    if (data is Map<String, dynamic>) {
      return TestSearchPage.fromJson(data);
    }
    return const TestSearchPage(
      groups: [],
      count: 0,
      next: null,
      facets: TestSearchFacets(),
    );
  }
}
