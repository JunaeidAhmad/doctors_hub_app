import '../../../core/network/api_client.dart';
import '../../../core/network/unwrap_list.dart';
import '../domain/models/hospital.dart';
import '../domain/models/hospital_category.dart';

class HospitalRepository {
  HospitalRepository(this._apiClient);

  final ApiClient _apiClient;
  List<HospitalCategory>? _cachedCategories;
  List<Hospital>? _cachedFacilities;

  Future<List<HospitalCategory>> getCategories({bool forceRefresh = false}) async {
    if (!forceRefresh && _cachedCategories != null && _cachedCategories!.isNotEmpty) {
      return _cachedCategories!;
    }

    final response = await _apiClient.get('/hospital-categories/');

    final paginated = unwrapList<HospitalCategory>(
      response.data,
      (json) => HospitalCategory.fromJson(json as Map<String, dynamic>),
    );
    _cachedCategories = paginated.results;
    return _cachedCategories!;
  }

  Future<List<Hospital>> getAllFacilities({bool forceRefresh = false}) async {
    if (!forceRefresh && _cachedFacilities != null && _cachedFacilities!.isNotEmpty) {
      return _cachedFacilities!;
    }

    try {
      final response = await _apiClient.get('/locations/');
      final paginated = unwrapList<Hospital>(
        response.data,
        (json) => Hospital.fromJson(json as Map<String, dynamic>),
      );
      if (paginated.results.isNotEmpty) {
        _cachedFacilities = paginated.results;
        return _cachedFacilities!;
      }
    } catch (_) {}

    final fallback = await getHospitals(pageSize: 100);
    _cachedFacilities = fallback.results;
    return _cachedFacilities!;
  }

  Future<PaginatedList<Hospital>> getHospitals({
    String? category,
    String? division,
    int? divisionId,
    String? district,
    int? districtId,
    String? area,
    int? thanaId,
    String? ownershipType,
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
    if (divisionId != null) {
      queryParams['division_id'] = divisionId;
    } else if (division != null && division.isNotEmpty && division != 'all' && division != 'All Bangladesh') {
      queryParams['division'] = division;
    }
    if (districtId != null) {
      queryParams['district_id'] = districtId;
    } else if (district != null && district.isNotEmpty && district != 'all' && district != 'All Districts') {
      queryParams['district'] = district;
    }
    if (thanaId != null) {
      queryParams['thana_id'] = thanaId;
    } else if (area != null && area.isNotEmpty && area != 'all' && area != 'All Areas') {
      queryParams['area'] = area;
    }
    if (ownershipType != null && ownershipType.isNotEmpty && ownershipType != 'all') {
      queryParams['ownership_type'] = ownershipType;
    }
    if (search != null && search.trim().isNotEmpty) {
      queryParams['search'] = search.trim();
    }

    final response = await _apiClient.get(
      '/hospitals/',
      queryParameters: queryParams,
    );

    return unwrapList<Hospital>(
      response.data,
      (json) => Hospital.fromJson(json as Map<String, dynamic>),
    );
  }
}
