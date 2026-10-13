import '../../../../core/utils/dhaka_time.dart';
import '../../../../features/booking/domain/models/booking_result.dart';
import '../../../../features/doctors/domain/models/chamber.dart';

class BookingItem {
  const BookingItem({
    required this.id,
    required this.bookingRef,
    this.serialDisplay,
    this.serialNumber,
    required this.type, // 'doctor', 'test' or 'service'
    required this.title, // Doctor name, test name or service name
    required this.subtitle, // Specialty or facility name
    required this.facilityName,
    required this.appointmentDate,
    required this.timeSlot, // session window or time window
    required this.patientName,
    required this.patientPhone,
    this.fee,
    required this.paymentMethod, // 'counter' or 'online'
    this.facilityPhone,
    this.notes,
    required this.createdAt,
    this.status = BookingStatus.unknown,
    this.bookingMode = BookingMode.unknown,
    this.affiliationId,
    this.doctorSlug,
    this.sessionStart,
    this.sessionEnd,
    this.estimatedTime,
    this.confirmDeadline,
    this.isUrgent = false,
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
  final double? fee;
  final String paymentMethod;
  final String? facilityPhone;
  final String? notes;
  final DateTime createdAt;
  final BookingStatus status;
  final BookingMode bookingMode;
  final String? affiliationId;
  final String? doctorSlug;
  final String? sessionStart;
  final String? sessionEnd;
  final String? estimatedTime;
  final String? confirmDeadline;
  final bool isUrgent;

  /// Upcoming = the session end (or the test date's end of day in Dhaka) is
  /// still after now — not just "date >= today".
  bool get isUpcoming {
    final now = DhakaTime.now();
    final dateIso = DhakaTime.isoDate(appointmentDate);
    final end = (sessionEnd != null && sessionEnd!.isNotEmpty)
        ? DhakaTime.parseDhaka(dateIso, sessionEnd!)
        : DhakaTime.parseDhaka(dateIso, '23:59');
    return end.isAfter(now);
  }

  BookingItem copyWith({BookingStatus? status}) {
    return BookingItem(
      id: id,
      bookingRef: bookingRef,
      serialDisplay: serialDisplay,
      serialNumber: serialNumber,
      type: type,
      title: title,
      subtitle: subtitle,
      facilityName: facilityName,
      appointmentDate: appointmentDate,
      timeSlot: timeSlot,
      patientName: patientName,
      patientPhone: patientPhone,
      fee: fee,
      paymentMethod: paymentMethod,
      facilityPhone: facilityPhone,
      notes: notes,
      createdAt: createdAt,
      status: status ?? this.status,
      bookingMode: bookingMode,
      affiliationId: affiliationId,
      doctorSlug: doctorSlug,
      sessionStart: sessionStart,
      sessionEnd: sessionEnd,
      estimatedTime: estimatedTime,
      confirmDeadline: confirmDeadline,
      isUrgent: isUrgent,
    );
  }

  factory BookingItem.fromJson(Map<String, dynamic> json) {
    return BookingItem(
      id: json['id'] as String? ?? '',
      bookingRef: json['booking_ref'] as String? ?? '',
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
      fee: (json['fee'] as num?)?.toDouble(),
      paymentMethod: json['payment_method'] as String? ?? 'counter',
      facilityPhone: json['facility_phone'] as String?,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      status: bookingStatusFromString(json['status'] as String?),
      bookingMode: bookingModeFromString(json['booking_mode'] as String?),
      affiliationId: json['affiliation_id'] as String?,
      doctorSlug: json['doctor_slug'] as String?,
      sessionStart: json['session_start'] as String?,
      sessionEnd: json['session_end'] as String?,
      estimatedTime: json['estimated_time'] as String?,
      confirmDeadline: json['confirm_deadline'] as String?,
      isUrgent: json['is_urgent'] == true,
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
        'status': bookingStatusToString(status),
        'booking_mode': bookingModeToString(bookingMode),
        'affiliation_id': affiliationId,
        'doctor_slug': doctorSlug,
        'session_start': sessionStart,
        'session_end': sessionEnd,
        'estimated_time': estimatedTime,
        'confirm_deadline': confirmDeadline,
        'is_urgent': isUrgent,
      };
}
