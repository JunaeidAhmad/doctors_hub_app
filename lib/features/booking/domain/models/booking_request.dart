class DoctorBookingRequest {
  const DoctorBookingRequest({
    required this.affiliationId,
    required this.date, // "YYYY-MM-DD"
    required this.sessionKey, // from /affiliations/{id}/availability/
    required this.patientName,
    required this.patientPhone,
    this.otpCode,
    this.patientAge,
    this.patientGender, // male / female / other
    this.notes,
  });

  final String affiliationId;
  final String date;
  final String sessionKey;
  final String patientName;
  final String patientPhone;
  final String? otpCode;
  final int? patientAge;
  final String? patientGender;
  final String? notes;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'affiliation_id': affiliationId,
      'date': date,
      'session_key': sessionKey,
      'patient_name': patientName,
      'patient_phone': patientPhone,
    };
    if (otpCode != null && otpCode!.isNotEmpty) map['otp_code'] = otpCode;
    if (patientAge != null) map['patient_age'] = patientAge;
    if (patientGender != null && patientGender!.isNotEmpty) {
      map['patient_gender'] = patientGender;
    }
    if (notes != null && notes!.isNotEmpty) map['notes'] = notes;
    return map;
  }
}

class TestBookingRequest {
  const TestBookingRequest({
    required this.facilityTestId,
    required this.pickupDate, // "YYYY-MM-DD"
    required this.collectionType, // 'center' or 'home'
    required this.patientName,
    required this.patientPhone,
    this.pickupThanaId,
    this.pickupAddressLine,
    this.otpCode,
    this.patientAge,
    this.patientGender,
    this.notes,
  });

  final String facilityTestId;
  final String pickupDate;
  final String collectionType;
  final String patientName;
  final String patientPhone;
  final int? pickupThanaId;
  final String? pickupAddressLine;
  final String? otpCode;
  final int? patientAge;
  final String? patientGender;
  final String? notes;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'facility_test_id': facilityTestId,
      'pickup_date': pickupDate,
      'collection_type': collectionType,
      'patient_name': patientName,
      'patient_phone': patientPhone,
    };
    if (pickupThanaId != null) map['pickup_thana_id'] = pickupThanaId;
    if (pickupAddressLine != null && pickupAddressLine!.isNotEmpty) {
      map['pickup_address_line'] = pickupAddressLine;
    }
    if (otpCode != null && otpCode!.isNotEmpty) map['otp_code'] = otpCode;
    if (patientAge != null) map['patient_age'] = patientAge;
    if (patientGender != null && patientGender!.isNotEmpty) {
      map['patient_gender'] = patientGender;
    }
    if (notes != null && notes!.isNotEmpty) map['notes'] = notes;
    return map;
  }
}
