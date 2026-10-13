import '../../../../core/models/facility_summary.dart';

/// `status` enum on doctor, test and hospital-service bookings.
enum BookingStatus { pending, confirmed, cancelled, completed, noShow, expired, unknown }

BookingStatus bookingStatusFromString(String? raw) {
  switch (raw) {
    case 'pending':
      return BookingStatus.pending;
    case 'confirmed':
      return BookingStatus.confirmed;
    case 'cancelled':
      return BookingStatus.cancelled;
    case 'completed':
      return BookingStatus.completed;
    case 'no_show':
      return BookingStatus.noShow;
    case 'expired':
      return BookingStatus.expired;
    default:
      return BookingStatus.unknown;
  }
}

String bookingStatusToString(BookingStatus status) => switch (status) {
      BookingStatus.pending => 'pending',
      BookingStatus.confirmed => 'confirmed',
      BookingStatus.cancelled => 'cancelled',
      BookingStatus.completed => 'completed',
      BookingStatus.noShow => 'no_show',
      BookingStatus.expired => 'expired',
      BookingStatus.unknown => '',
    };

/// Response of `POST /bookings/doctor/`.
class DoctorBookingResult {
  const DoctorBookingResult({
    required this.id,
    required this.status,
    this.serialNumber,
    this.serialDisplay,
    this.estimatedTime,
    this.sessionStart,
    this.sessionEnd,
    this.date,
    this.fee,
    this.doctorName = '',
    this.facility,
    this.confirmDeadline,
    this.isUrgent = false,
    this.source,
  });

  final String id;
  final BookingStatus status;
  final int? serialNumber;
  final String? serialDisplay;
  final String? estimatedTime;
  final String? sessionStart;
  final String? sessionEnd;
  final String? date;
  final double? fee;
  final String doctorName;
  final FacilitySummary? facility;
  final String? confirmDeadline;
  final bool isUrgent;
  final String? source;

  /// Booking reference: the first 8 characters of the booking id.
  String get shortRef =>
      id.length >= 8 ? id.substring(0, 8).toUpperCase() : id.toUpperCase();

  factory DoctorBookingResult.fromJson(Map<String, dynamic> json) {
    final facilityRaw = json['facility'];
    double? fee;
    if (json['fee'] != null) {
      fee = double.tryParse(json['fee'].toString());
    }
    return DoctorBookingResult(
      id: json['id']?.toString() ?? '',
      status: bookingStatusFromString(json['status'] as String?),
      serialNumber: (json['serial_number'] as num?)?.toInt(),
      serialDisplay: json['serial_display'] as String?,
      estimatedTime: json['estimated_time'] as String?,
      sessionStart: json['session_start'] as String?,
      sessionEnd: json['session_end'] as String?,
      date: json['date'] as String?,
      fee: fee,
      doctorName: json['doctor_name'] as String? ?? '',
      facility: facilityRaw is Map
          ? FacilitySummary.fromJson(Map<String, dynamic>.from(facilityRaw))
          : null,
      confirmDeadline: json['confirm_deadline'] as String?,
      isUrgent: json['is_urgent'] == true,
      source: json['source'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'status': bookingStatusToString(status),
        'serial_number': serialNumber,
        'serial_display': serialDisplay,
        'estimated_time': estimatedTime,
        'session_start': sessionStart,
        'session_end': sessionEnd,
        'date': date,
        'fee': fee,
        'doctor_name': doctorName,
        'facility': facility?.toJson(),
        'confirm_deadline': confirmDeadline,
        'is_urgent': isUrgent,
        'source': source,
      };
}

enum CollectionType { center, home, unknown }

CollectionType collectionTypeFromString(String? raw) {
  switch (raw) {
    case 'center':
      return CollectionType.center;
    case 'home':
      return CollectionType.home;
    default:
      return CollectionType.unknown;
  }
}

/// Response of `POST /bookings/test/`.
class TestBookingResult {
  const TestBookingResult({
    required this.id,
    required this.status,
    this.pickupDate,
    this.collectionType = CollectionType.unknown,
    this.price,
    this.testName = '',
    this.facility,
  });

  final String id;
  final BookingStatus status;
  final String? pickupDate;
  final CollectionType collectionType;
  final double? price;
  final String testName;
  final FacilitySummary? facility;

  String get shortRef =>
      id.length >= 8 ? id.substring(0, 8).toUpperCase() : id.toUpperCase();

  factory TestBookingResult.fromJson(Map<String, dynamic> json) {
    final facilityRaw = json['facility'];
    double? price;
    if (json['price'] != null) {
      price = double.tryParse(json['price'].toString());
    }
    return TestBookingResult(
      id: json['id']?.toString() ?? '',
      status: bookingStatusFromString(json['status'] as String?),
      pickupDate: json['pickup_date'] as String?,
      collectionType:
          collectionTypeFromString(json['collection_type'] as String?),
      price: price,
      testName: json['test_name'] as String? ?? '',
      facility: facilityRaw is Map
          ? FacilitySummary.fromJson(Map<String, dynamic>.from(facilityRaw))
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'status': bookingStatusToString(status),
        'pickup_date': pickupDate,
        'collection_type': switch (collectionType) {
          CollectionType.center => 'center',
          CollectionType.home => 'home',
          CollectionType.unknown => null,
        },
        'price': price,
        'test_name': testName,
        'facility': facility?.toJson(),
      };
}

/// Response of `POST /bookings/hospital-service/`.
class HospitalServiceBookingResult {
  const HospitalServiceBookingResult({
    required this.id,
    required this.status,
    this.bookingDate,
    this.preferredTime = '',
    this.serviceName = '',
    this.facility,
  });

  final String id;
  final BookingStatus status;
  final String? bookingDate;
  final String preferredTime;
  final String serviceName;
  final FacilitySummary? facility;

  String get shortRef =>
      id.length >= 8 ? id.substring(0, 8).toUpperCase() : id.toUpperCase();

  factory HospitalServiceBookingResult.fromJson(Map<String, dynamic> json) {
    final facilityRaw = json['facility'];
    return HospitalServiceBookingResult(
      id: json['id']?.toString() ?? '',
      status: bookingStatusFromString(json['status'] as String?),
      bookingDate: json['booking_date'] as String?,
      preferredTime: json['preferred_time'] as String? ?? '',
      serviceName: json['service_name'] as String? ?? '',
      facility: facilityRaw is Map
          ? FacilitySummary.fromJson(Map<String, dynamic>.from(facilityRaw))
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'status': bookingStatusToString(status),
        'booking_date': bookingDate,
        'preferred_time': preferredTime,
        'service_name': serviceName,
        'facility': facility?.toJson(),
      };
}

class CallLeadNumber {
  const CallLeadNumber({required this.phone, this.label = ''});

  final String phone;
  final String label;

  factory CallLeadNumber.fromJson(Map<String, dynamic> json) {
    return CallLeadNumber(
      phone: json['phone'] as String? ?? '',
      label: json['label'] as String? ?? '',
    );
  }
}

class CallLeadFacility {
  const CallLeadFacility({required this.id, required this.displayName});

  final String id;
  final String displayName;

  factory CallLeadFacility.fromJson(Map<String, dynamic> json) {
    return CallLeadFacility(
      id: json['id']?.toString() ?? '',
      displayName: json['display_name'] as String? ?? '',
    );
  }
}

/// Response of `POST /bookings/call-leads/`.
class CallLeadResult {
  const CallLeadResult({
    required this.id,
    this.doctorName = '',
    this.facility,
    this.numbers = const [],
  });

  final String id;
  final String doctorName;
  final CallLeadFacility? facility;
  final List<CallLeadNumber> numbers;

  factory CallLeadResult.fromJson(Map<String, dynamic> json) {
    final numbers = <CallLeadNumber>[];
    final numbersRaw = json['numbers'];
    if (numbersRaw is List) {
      for (final item in numbersRaw) {
        if (item is Map) {
          numbers.add(CallLeadNumber.fromJson(Map<String, dynamic>.from(item)));
        }
      }
    }
    final facilityRaw = json['facility'];
    return CallLeadResult(
      id: json['id']?.toString() ?? '',
      doctorName: json['doctor_name'] as String? ?? '',
      facility: facilityRaw is Map
          ? CallLeadFacility.fromJson(Map<String, dynamic>.from(facilityRaw))
          : null,
      numbers: numbers,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'doctor_name': doctorName,
        'facility': facility == null
            ? null
            : {'id': facility!.id, 'display_name': facility!.displayName},
        'numbers': numbers
            .map((n) => {'phone': n.phone, 'label': n.label})
            .toList(),
      };
}
