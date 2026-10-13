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
    int? divisionId,
    String? district,
    int? districtId,
    String? area,
    int? thanaId,
    String? fulfillment,
    String? ownership,
  }) async {
    final queryParams = <String, dynamic>{
      'test': testId,
      'page_size': 100,
    };

    if (fulfillment == 'home') {
      queryParams['home_sample_collection'] = true;
    }

    final response = await _apiClient.get(
      '/facility-tests/',
      queryParameters: queryParams,
    );

    final paginated = unwrapList<FacilityTest>(
      response.data,
      (json) => FacilityTest.fromJson(json as Map<String, dynamic>),
    );

    var list = paginated.results;

    // Filter by division
    if (divisionId != null) {
      list = list.where((ft) => ft.divisionId == null || ft.divisionId == divisionId).toList();
    } else if (division != null && division.isNotEmpty && division != 'all' && division != 'All Bangladesh') {
      final cleanDiv = division.replaceAll(RegExp(r'\s*Division$', caseSensitive: false), '').trim().toLowerCase();
      list = list.where((ft) {
        if (ft.facilityDivision == null) return true;
        return ft.facilityDivision!.toLowerCase().contains(cleanDiv);
      }).toList();
    }

    // Filter by district
    if (districtId != null) {
      list = list.where((ft) => ft.districtId == null || ft.districtId == districtId).toList();
    } else if (district != null && district.isNotEmpty && district != 'all' && district != 'All Districts') {
      final cleanDist = district.replaceAll(RegExp(r'\s*District$', caseSensitive: false), '').trim().toLowerCase();
      list = list.where((ft) {
        final d = ft.facilityDistrict?.toLowerCase() ?? '';
        final addr = ft.facilityAddress?.toLowerCase() ?? '';
        return d.contains(cleanDist) || addr.contains(cleanDist);
      }).toList();
    }

    // Filter by thana / area
    if (thanaId != null) {
      list = list.where((ft) => ft.thanaId == null || ft.thanaId == thanaId).toList();
    } else if (area != null && area.isNotEmpty && area != 'all' && area != 'All Areas') {
      final cleanArea = area.replaceAll(RegExp(r'\s*(Thana|Area)s?$', caseSensitive: false), '').trim().toLowerCase();
      list = list.where((ft) {
        final a = ft.facilityArea?.toLowerCase() ?? '';
        final b = ft.facilityBranch?.toLowerCase() ?? '';
        final addr = ft.facilityAddress?.toLowerCase() ?? '';
        return a.contains(cleanArea) || b.contains(cleanArea) || addr.contains(cleanArea);
      }).toList();
    }

    // Filter by fulfillment
    if (fulfillment != null && fulfillment != 'all') {
      if (fulfillment == 'home') {
        list = list.where((ft) => ft.homeSampleCollection).toList();
      } else if (fulfillment == 'center') {
        list = list.where((ft) => !ft.homeSampleCollection).toList();
      }
    }

    // Filter by ownership
    if (ownership != null && ownership.isNotEmpty && ownership != 'all') {
      final cleanOwn = ownership.toLowerCase();
      list = list.where((ft) {
        final own = ft.facilityOwnershipType?.toLowerCase() ?? '';
        return own == cleanOwn || own.contains(cleanOwn);
      }).toList();
    }

    // Sort by price ascending
    list.sort((a, b) => a.price.compareTo(b.price));

    return list;
  }
}
