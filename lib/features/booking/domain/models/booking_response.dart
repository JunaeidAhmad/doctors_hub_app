class BookingResponse {
  const BookingResponse({
    required this.id,
    required this.bookingRef,
    this.serialDisplay,
    this.serialNumber,
    this.status,
    this.patientName,
    this.patientPhone,
    this.totalFee,
    this.message,
    this.date,
    this.slot,
  });

  final String id;
  final String bookingRef;
  final String? serialDisplay;
  final int? serialNumber;
  final String? status;
  final String? patientName;
  final String? patientPhone;
  final double? totalFee;
  final String? message;
  final String? date;
  final String? slot;

  factory BookingResponse.fromJson(Map<String, dynamic> json) {
    double? fee;
    if (json['fee'] != null) {
      fee = double.tryParse(json['fee'].toString());
    } else if (json['price'] != null) {
      fee = double.tryParse(json['price'].toString());
    } else if (json['total_amount'] != null) {
      fee = double.tryParse(json['total_amount'].toString());
    }

    return BookingResponse(
      id: json['id']?.toString() ?? '',
      bookingRef: json['booking_ref'] as String? ?? json['reference'] as String? ?? 'DH-${DateTime.now().millisecondsSinceEpoch % 100000}',
      serialDisplay: json['serial_display'] as String? ?? (json['serial_number'] != null ? 'SL-${json['serial_number'].toString().padLeft(3, '0')}' : null),
      serialNumber: (json['serial_number'] as num?)?.toInt(),
      status: json['status'] as String?,
      patientName: json['patient_name'] as String?,
      patientPhone: json['patient_phone'] as String?,
      totalFee: fee,
      message: json['message'] as String?,
      date: json['date'] as String? ?? json['pickup_date'] as String?,
      slot: json['slot'] as String?,
    );
  }
}
