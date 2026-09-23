class DoctorBookingRequest {
  const DoctorBookingRequest({
    required this.affiliationId,
    required this.date, // "YYYY-MM-DD"
    required this.slot, // "HH:MM"
    required this.patientName,
    required this.patientPhone,
    this.otpCode,
    this.patientAge,
    this.gender,
    this.notes,
  });

  final String affiliationId;
  final String date;
  final String slot;
  final String patientName;
  final String patientPhone;
  final String? otpCode;
  final int? patientAge;
  final String? gender;
  final String? notes;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'affiliation_id': affiliationId,
      'date': date,
      'slot': slot,
      'patient_name': patientName,
      'patient_phone': patientPhone,
    };
    if (otpCode != null && otpCode!.isNotEmpty) map['otp_code'] = otpCode;
    if (patientAge != null) map['patient_age'] = patientAge;
    if (gender != null) map['gender'] = gender;
    if (notes != null && notes!.isNotEmpty) map['notes'] = notes;
    return map;
  }
}

class TestBookingRequest {
  const TestBookingRequest({
    required this.facilityTestId,
    required this.pickupDate, // "YYYY-MM-DD"
    required this.patientName,
    required this.patientPhone,
    this.pickupAddressLine,
    this.otpCode,
    this.notes,
  });

  final String facilityTestId;
  final String pickupDate;
  final String patientName;
  final String patientPhone;
  final String? pickupAddressLine;
  final String? otpCode;
  final String? notes;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'facility_test_id': facilityTestId,
      'pickup_date': pickupDate,
      'patient_name': patientName,
      'patient_phone': patientPhone,
    };
    if (pickupAddressLine != null && pickupAddressLine!.isNotEmpty) {
      map['pickup_address_line'] = pickupAddressLine;
    }
    if (otpCode != null && otpCode!.isNotEmpty) map['otp_code'] = otpCode;
    if (notes != null && notes!.isNotEmpty) map['notes'] = notes;
    return map;
  }
}
