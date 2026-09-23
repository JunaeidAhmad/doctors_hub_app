class BookingItem {
  const BookingItem({
    required this.id,
    required this.bookingRef,
    this.serialDisplay,
    this.serialNumber,
    required this.type, // 'doctor' or 'test'
    required this.title, // Doctor name or Test name
    required this.subtitle, // Specialty or Center name
    required this.facilityName,
    required this.appointmentDate,
    required this.timeSlot,
    required this.patientName,
    required this.patientPhone,
    required this.fee,
    required this.paymentMethod, // 'counter' or 'online'
    this.facilityPhone,
    this.notes,
    required this.createdAt,
  });

  final String id;
  final String bookingRef;
  final String? serialDisplay;
  final int? serialNumber;
  final String type;
  final String title;
  final String subtitle;
  final String facilityName;
  final DateTime appointmentDate;
  final String timeSlot;
  final String patientName;
  final String patientPhone;
  final double fee;
  final String paymentMethod;
  final String? facilityPhone;
  final String? notes;
  final DateTime createdAt;

  bool get isUpcoming {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final apptDay = DateTime(appointmentDate.year, appointmentDate.month, appointmentDate.day);
    return apptDay.isAfter(today) || apptDay.isAtSameMomentAs(today);
  }

  factory BookingItem.fromJson(Map<String, dynamic> json) {
    return BookingItem(
      id: json['id'] as String,
      bookingRef: json['booking_ref'] as String,
      serialDisplay: json['serial_display'] as String?,
      serialNumber: (json['serial_number'] as num?)?.toInt(),
      type: json['type'] as String? ?? 'doctor',
      title: json['title'] as String? ?? '',
      subtitle: json['subtitle'] as String? ?? '',
      facilityName: json['facility_name'] as String? ?? '',
      appointmentDate: DateTime.parse(json['appointment_date'] as String),
      timeSlot: json['time_slot'] as String? ?? '',
      patientName: json['patient_name'] as String? ?? '',
      patientPhone: json['patient_phone'] as String? ?? '',
      fee: (json['fee'] as num?)?.toDouble() ?? 0.0,
      paymentMethod: json['payment_method'] as String? ?? 'counter',
      facilityPhone: json['facility_phone'] as String?,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'booking_ref': bookingRef,
    'serial_display': serialDisplay,
    'serial_number': serialNumber,
    'type': type,
    'title': title,
    'subtitle': subtitle,
    'facility_name': facilityName,
    'appointment_date': appointmentDate.toIso8601String(),
    'time_slot': timeSlot,
    'patient_name': patientName,
    'patient_phone': patientPhone,
    'fee': fee,
    'payment_method': paymentMethod,
    'facility_phone': facilityPhone,
    'notes': notes,
    'created_at': createdAt.toIso8601String(),
  };
}
