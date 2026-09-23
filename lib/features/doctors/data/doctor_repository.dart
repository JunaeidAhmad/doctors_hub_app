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
    String? hospital,
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
    if (specialty != null && specialty.isNotEmpty && specialty != 'all') {
      queryParams['specialty'] = specialty;
    }
    if (division != null && division.isNotEmpty && division != 'all') {
      queryParams['division'] = division;
    }
    if (hospital != null && hospital.isNotEmpty) {
      queryParams['hospital'] = hospital;
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
