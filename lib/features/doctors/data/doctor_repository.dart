import '../../../core/network/api_client.dart';
import '../../../core/network/unwrap_list.dart';
import '../domain/models/doctor.dart';
import '../domain/models/specialty.dart';

class DoctorRepository {
  DoctorRepository(this._apiClient);

  final ApiClient _apiClient;
  List<Specialty>? _cachedSpecialties;

  Future<List<Specialty>> getSpecialties({bool forceRefresh = false}) async {
    if (!forceRefresh && _cachedSpecialties != null && _cachedSpecialties!.isNotEmpty) {
      return _cachedSpecialties!;
    }

    final response = await _apiClient.get(
      '/specialties/',
      queryParameters: {'canonical_only': true},
    );

    final paginated = unwrapList<Specialty>(
      response.data,
      (json) => Specialty.fromJson(json as Map<String, dynamic>),
    );
    _cachedSpecialties = paginated.results;
    return _cachedSpecialties!;
  }

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
    final queryParams = <String, dynamic>{
      'page': page,
      'page_size': pageSize,
    };

    if (search != null && search.trim().isNotEmpty) {
      queryParams['search'] = search.trim();
    }
    if (specialty != null && specialty.isNotEmpty && specialty.toLowerCase() != 'all') {
      queryParams['specialty'] = specialty;
    }
    if (division != null &&
        division.isNotEmpty &&
        division.toLowerCase() != 'all' &&
        division.toLowerCase() != 'all bangladesh') {
      queryParams['division'] = division;
    }
    if (divisionId != null) {
      queryParams['division_id'] = divisionId;
    }
    if (district != null &&
        district.isNotEmpty &&
        district.toLowerCase() != 'all' &&
        district.toLowerCase() != 'all districts') {
      queryParams['district'] = district;
    }
    if (districtId != null) {
      queryParams['district_id'] = districtId;
    }
    if (area != null &&
        area.isNotEmpty &&
        area.toLowerCase() != 'all' &&
        area.toLowerCase() != 'all areas') {
      queryParams['area'] = area;
    }
    if (thanaId != null) {
      queryParams['thana_id'] = thanaId;
    }
    final effectiveFacility = facility ?? hospital;
    if (effectiveFacility != null &&
        effectiveFacility.isNotEmpty &&
        effectiveFacility.toLowerCase() != 'all') {
      queryParams['facility'] = effectiveFacility;
    }
    if (day != null &&
        day.isNotEmpty &&
        day.toLowerCase() != 'all' &&
        day.toLowerCase() != 'all days') {
      queryParams['day'] = day;
    }
    if (gender != null &&
        gender.isNotEmpty &&
        gender.toLowerCase() != 'all') {
      queryParams['gender'] = gender;
    }

    final response = await _apiClient.get(
      '/doctors/',
      queryParameters: queryParams,
    );

    return unwrapList<Doctor>(
      response.data,
      (json) => Doctor.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<Doctor> getDoctorDetails(String idOrSlug) async {
    final response = await _apiClient.get('/doctors/$idOrSlug/');
    return Doctor.fromJson(response.data as Map<String, dynamic>);
  }
}
