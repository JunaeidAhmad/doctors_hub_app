import '../../../core/network/api_client.dart';
import '../domain/models/booking_request.dart';
import '../domain/models/booking_result.dart';

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
    final patientRaw = json['patient'];
    final patient = patientRaw is Map
        ? Map<String, dynamic>.from(patientRaw)
        : const <String, dynamic>{};
    final gender = patient['gender'] is String
        ? (patient['gender'] as String).toLowerCase()
        : null;
    return PatientLookupResult(
      found: json['found'] == true,
      name: patient['name'] as String?,
      phone: patient['phone'] as String?,
      age: (patient['age'] as num?)?.toInt(),
      gender: gender == null || gender.isEmpty ? null : gender,
    );
  }
}

class BookingRepository {
  BookingRepository(this._apiClient);

  final ApiClient _apiClient;

  /// Sends a real OTP and returns its `expires_in` seconds.
  ///
  /// The code goes on the booking or call-lead POST as `otp_code`; the app
  /// never calls the verify endpoint first.
  Future<int?> sendOtp({
    required String phone,
    required String purpose,
  }) async {
    final response = await _apiClient.post(
      '/bookings/otp/send/',
      data: {
        'phone': phone,
        'purpose': purpose,
      },
    );
    final data = response.data;
    if (data is Map && data['expires_in'] != null) {
      return (data['expires_in'] as num?)?.toInt();
    }
    return null;
  }

  Future<PatientLookupResult> lookupPatient(String phone) async {
    try {
      final response = await _apiClient.get(
        '/bookings/patients/lookup/',
        queryParameters: {'phone': phone},
      );
      if (response.data is Map<String, dynamic>) {
        return PatientLookupResult.fromJson(
          response.data as Map<String, dynamic>,
        );
      }
    } catch (_) {
      // Lookup is best-effort
    }
    return const PatientLookupResult(found: false);
  }

  Future<DoctorBookingResult> bookDoctor(DoctorBookingRequest request) async {
    final response = await _apiClient.post(
      '/bookings/doctor/',
      data: request.toJson(),
    );
    return DoctorBookingResult.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  Future<TestBookingResult> bookTest(TestBookingRequest request) async {
    final response = await _apiClient.post(
      '/bookings/test/',
      data: request.toJson(),
    );
    return TestBookingResult.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  /// Books one of a hospital's services. Created `pending`; the hospital
  /// contacts the patient to confirm.
  Future<HospitalServiceBookingResult> bookHospitalService({
    required String hospitalId,
    required String serviceId,
    required String bookingDate,
    required String preferredTime,
    required String patientName,
    required String patientPhone,
    required String otpCode,
    int? patientAge,
    String? patientGender,
    String? notes,
  }) async {
    final response = await _apiClient.post(
      '/bookings/hospital-service/',
      data: {
        'hospital_id': hospitalId,
        'service_id': serviceId,
        'booking_date': bookingDate,
        'preferred_time': preferredTime,
        'patient_name': patientName,
        'patient_phone': patientPhone,
        'otp_code': otpCode,
        if (patientAge != null) 'patient_age': patientAge,
        if (patientGender != null && patientGender.isNotEmpty)
          'patient_gender': patientGender,
        if (notes != null && notes.isNotEmpty) 'notes': notes,
      },
    );
    return HospitalServiceBookingResult.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  /// `call_only` chambers: logs the lead and returns the chamber's numbers.
  /// No booking is created.
  Future<CallLeadResult> createCallLead({
    required String affiliationId,
    required String patientName,
    required String patientPhone,
    required String otpCode,
    int? patientAge,
    String? patientGender,
  }) async {
    final response = await _apiClient.post(
      '/bookings/call-leads/',
      data: {
        'affiliation_id': affiliationId,
        'patient_name': patientName,
        'patient_phone': patientPhone,
        'otp_code': otpCode,
        if (patientAge != null) 'patient_age': patientAge,
        if (patientGender != null && patientGender.isNotEmpty)
          'patient_gender': patientGender,
      },
    );
    return CallLeadResult.fromJson(
      response.data as Map<String, dynamic>,
    );
  }
}
