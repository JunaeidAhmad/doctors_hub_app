import '../../../core/network/api_client.dart';
import '../domain/models/booking_request.dart';
import '../domain/models/booking_response.dart';

class PatientLookupResult {
  const PatientLookupResult({
    required this.found,
    this.name,
    this.phone,
    this.age,
    this.gender,
  });

  final bool found;
  final String? name;
  final String? phone;
  final int? age;
  final String? gender;

  factory PatientLookupResult.fromJson(Map<String, dynamic> json) {
    return PatientLookupResult(
      found: json['found'] == true,
      name: json['patient_name'] as String? ?? json['name'] as String?,
      phone: json['phone'] as String?,
      age: (json['patient_age'] as num?)?.toInt() ?? (json['age'] as num?)?.toInt(),
      gender: json['gender'] as String?,
    );
  }
}

class BookingRepository {
  BookingRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<bool> sendOtp({
    required String phone,
    required String purpose, // 'doctor_booking' or 'test_booking'
  }) async {
    final response = await _apiClient.post(
      '/bookings/otp/send/',
      data: {
        'phone': phone,
        'purpose': purpose,
      },
    );
    return response.statusCode == 200 || response.statusCode == 201;
  }

  Future<bool> verifyOtp({
    required String phone,
    required String code,
    required String purpose,
  }) async {
    final response = await _apiClient.post(
      '/bookings/otp/verify/',
      data: {
        'phone': phone,
        'code': code,
        'purpose': purpose,
      },
    );
    return response.statusCode == 200;
  }

  Future<PatientLookupResult> lookupPatient(String phone) async {
    try {
      final response = await _apiClient.get(
        '/bookings/patients/lookup/',
        queryParameters: {'phone': phone},
      );
      if (response.data is Map<String, dynamic>) {
        return PatientLookupResult.fromJson(response.data as Map<String, dynamic>);
      }
    } catch (_) {
      // Lookup is best-effort
    }
    return const PatientLookupResult(found: false);
  }

  Future<BookingResponse> bookDoctor(DoctorBookingRequest request) async {
    final response = await _apiClient.post(
      '/bookings/doctor/',
      data: request.toJson(),
    );
    return BookingResponse.fromJson(response.data as Map<String, dynamic>);
  }

  Future<BookingResponse> bookTest(TestBookingRequest request) async {
    final response = await _apiClient.post(
      '/bookings/test/',
      data: request.toJson(),
    );
    return BookingResponse.fromJson(response.data as Map<String, dynamic>);
  }
}
