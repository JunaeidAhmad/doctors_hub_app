import '../../../core/network/api_client.dart';
import '../../../core/network/unwrap_list.dart';
import '../../location/domain/models/division.dart';

class LocationRepository {
  LocationRepository(this._apiClient);

  final ApiClient _apiClient;
  List<Division>? _cachedDivisions;

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
}
