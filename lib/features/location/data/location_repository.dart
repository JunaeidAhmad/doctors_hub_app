import '../../../core/network/api_client.dart';
import '../../../core/network/unwrap_list.dart';
import '../domain/models/division.dart';
import '../domain/models/district.dart';
import '../domain/models/thana.dart';

class LocationRepository {
  LocationRepository(this._apiClient);

  final ApiClient _apiClient;
  List<Division>? _cachedDivisions;
  List<District>? _cachedAllDistricts;
  final Map<int, List<District>> _cachedDistrictsByDivision = {};
  final Map<int, List<Thana>> _cachedThanasByDistrict = {};

  Future<List<Division>> getDivisions({bool forceRefresh = false}) async {
    if (!forceRefresh && _cachedDivisions != null && _cachedDivisions!.isNotEmpty) {
      return _cachedDivisions!;
    }

    final response = await _apiClient.get('/divisions/');
    final paginated = unwrapList<Division>(
      response.data,
      (json) => Division.fromJson(json as Map<String, dynamic>),
    );
    _cachedDivisions = paginated.results;
    return _cachedDivisions!;
  }

  Future<List<District>> getDistricts({
    int? divisionId,
    bool forceRefresh = false,
  }) async {
    if (divisionId != null) {
      if (!forceRefresh && _cachedDistrictsByDivision.containsKey(divisionId)) {
        return _cachedDistrictsByDivision[divisionId]!;
      }

      final response = await _apiClient.get(
        '/districts/',
        queryParameters: {'division': divisionId},
      );
      final paginated = unwrapList<District>(
        response.data,
        (json) => District.fromJson(json as Map<String, dynamic>),
      );
      _cachedDistrictsByDivision[divisionId] = paginated.results;
      return paginated.results;
    }

    if (!forceRefresh && _cachedAllDistricts != null && _cachedAllDistricts!.isNotEmpty) {
      return _cachedAllDistricts!;
    }

    final response = await _apiClient.get('/districts/');
    final paginated = unwrapList<District>(
      response.data,
      (json) => District.fromJson(json as Map<String, dynamic>),
    );
    _cachedAllDistricts = paginated.results;
    return _cachedAllDistricts!;
  }

  Future<List<Thana>> getThanas({
    int? districtId,
    bool forceRefresh = false,
  }) async {
    if (districtId != null) {
      if (!forceRefresh && _cachedThanasByDistrict.containsKey(districtId)) {
        return _cachedThanasByDistrict[districtId]!;
      }

      final response = await _apiClient.get(
        '/thanas/',
        queryParameters: {'district': districtId},
      );
      final paginated = unwrapList<Thana>(
        response.data,
        (json) => Thana.fromJson(json as Map<String, dynamic>),
      );
      _cachedThanasByDistrict[districtId] = paginated.results;
      return paginated.results;
    }

    final response = await _apiClient.get('/thanas/');
    final paginated = unwrapList<Thana>(
      response.data,
      (json) => Thana.fromJson(json as Map<String, dynamic>),
    );
    return paginated.results;
  }
}
