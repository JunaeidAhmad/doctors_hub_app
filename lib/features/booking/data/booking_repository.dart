import '../../../core/network/api_client.dart';
import '../../../core/network/app_failure.dart';
import '../domain/models/booking_request.dart';
import '../domain/models/booking_result.dart';

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

  /// Live status of a doctor booking. Anonymous; `phone` must match the
  /// booking's `patient_phone`. Returns null on 404 `booking_not_found`.
  Future<DoctorBookingStatusResult?> getDoctorBookingStatus({
    required String bookingId,
    required String phone,
  }) async {
    try {
      final response = await _apiClient.get(
        '/bookings/doctor/$bookingId/status/',
        queryParameters: {'phone': phone},
      );
      return DoctorBookingStatusResult.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on NotFoundFailure {
      return null;
    }
  }

  /// Cancels a doctor booking (`pending` request or `confirmed`) with a
  /// mandatory reason. The `patient_token` comes from the create response.
  Future<void> cancelDoctorBooking({
    required String bookingId,
    required String patientToken,
    required String reason,
  }) async {
    await _apiClient.post(
      '/bookings/doctor/$bookingId/patient-cancel/',
      data: {
        'patient_token': patientToken,
        'reason': reason,
      },
    );
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
