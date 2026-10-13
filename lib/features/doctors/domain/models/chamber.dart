import '../../../../core/models/facility_summary.dart';
import 'schedule.dart';

/// `booking_mode` enum from v1. Unknown values parse to [BookingMode.unknown]
/// (tolerant parsing rule).
enum BookingMode { instant, request, callOnly, unknown }

BookingMode bookingModeFromString(String? raw) {
  switch (raw) {
    case 'instant':
      return BookingMode.instant;
    case 'request':
      return BookingMode.request;
    case 'call_only':
      return BookingMode.callOnly;
    default:
      return BookingMode.unknown;
  }
}

String? bookingModeToString(BookingMode mode) => switch (mode) {
      BookingMode.instant => 'instant',
      BookingMode.request => 'request',
      BookingMode.callOnly => 'call_only',
      BookingMode.unknown => null,
    };

/// `chambers[].next_available` from v1 list and detail payloads.
class NextAvailable {
  const NextAvailable({
    this.date,
    this.sessionStart,
    this.remaining,
  });

  final String? date;
  final String? sessionStart;
  final int? remaining;

  factory NextAvailable.fromJson(Map<String, dynamic> json) {
    return NextAvailable(
      date: json['date'] is String ? json['date'] as String : null,
      sessionStart:
          json['session_start'] is String ? json['session_start'] as String : null,
      remaining: (json['remaining'] as num?)?.toInt(),
    );
  }
}

/// A doctor's chamber (`chambers[]` in v1 doctor list and detail payloads).
///
/// Detail payloads also carry `advance_booking_days` and `is_active`; list
/// payloads do not.
class Chamber {
  const Chamber({
    required this.id,
    this.fee,
    this.chamberType,
    this.bookingMode = BookingMode.unknown,
    required this.facility,
    this.schedules = const [],
    this.nextAvailable,
    this.advanceBookingDays,
    this.isActive,
  });

  const Chamber.empty()
      : id = '',
        fee = null,
        chamberType = null,
        bookingMode = BookingMode.unknown,
        facility = const FacilitySummary.empty(),
        schedules = const [],
        nextAvailable = null,
        advanceBookingDays = null,
        isActive = null;

  final String id;
  final double? fee;
  final String? chamberType;
  final BookingMode bookingMode;
  final FacilitySummary facility;
  final List<DoctorSchedule> schedules;
  final NextAvailable? nextAvailable;
  final int? advanceBookingDays;
  final bool? isActive;

  String get fullDisplayName => facility.displayName;

  factory Chamber.fromJson(Map<String, dynamic> json) {
    final schedulesRaw = json['schedules'];
    final schedules = <DoctorSchedule>[];
    if (schedulesRaw is List) {
      for (final item in schedulesRaw) {
        if (item is Map) {
          schedules.add(DoctorSchedule.fromJson(Map<String, dynamic>.from(item)));
        }
      }
    }

    final facilityRaw = json['facility'];
    final nextAvailableRaw = json['next_available'];

    double? fee;
    if (json['fee'] != null) {
      fee = double.tryParse(json['fee'].toString());
    }

    return Chamber(
      id: json['id']?.toString() ?? '',
      fee: fee,
      chamberType: json['chamber_type'] as String?,
      bookingMode: bookingModeFromString(json['booking_mode'] as String?),
      facility: facilityRaw is Map
          ? FacilitySummary.fromJson(Map<String, dynamic>.from(facilityRaw))
          : const FacilitySummary.empty(),
      schedules: schedules,
      nextAvailable: nextAvailableRaw is Map
          ? NextAvailable.fromJson(
              Map<String, dynamic>.from(nextAvailableRaw))
          : null,
      advanceBookingDays: (json['advance_booking_days'] as num?)?.toInt(),
      isActive: json['is_active'] as bool?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'fee': fee,
        'chamber_type': chamberType,
        'booking_mode': switch (bookingMode) {
          BookingMode.instant => 'instant',
          BookingMode.request => 'request',
          BookingMode.callOnly => 'call_only',
          BookingMode.unknown => null,
        },
        'facility': facility.toJson(),
        'schedules': schedules.map((s) => s.toJson()).toList(),
        'next_available': nextAvailable == null
            ? null
            : {
                'date': nextAvailable!.date,
                'session_start': nextAvailable!.sessionStart,
                'remaining': nextAvailable!.remaining,
              },
        'advance_booking_days': advanceBookingDays,
        'is_active': isActive,
      };
}
