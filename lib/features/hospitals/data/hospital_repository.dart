import '../../../core/network/api_client.dart';
import '../../../core/network/unwrap_list.dart';
import '../domain/models/hospital.dart';
import '../domain/models/hospital_category.dart';

class HospitalRepository {
  HospitalRepository(this._apiClient);

  final ApiClient _apiClient;
  List<HospitalCategory>? _cachedCategories;

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

  Future<PaginatedList<Hospital>> getHospitals({
    String? category,
    int? divisionId,
    int? districtId,
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

    if (category != null && category.isNotEmpty) {
      queryParams['category'] = category;
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
    if (ownershipType != null && ownershipType.isNotEmpty) {
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

  Future<Hospital> getHospital(String idOrSlug) async {
    final response = await _apiClient.get('/hospitals/$idOrSlug/');
    return Hospital.fromJson(response.data as Map<String, dynamic>);
  }
}
