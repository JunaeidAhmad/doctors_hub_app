import '../../../../core/models/facility_summary.dart';
import 'chamber.dart';

/// `GET /affiliations/{id}/availability/` response.
class AffiliationAvailability {
  const AffiliationAvailability({
    required this.affiliationId,
    required this.facility,
    this.fee,
    this.timezone = '',
    this.dates = const [],
    this.nextAvailable,
  });

  final String affiliationId;
  final FacilitySummary facility;
  final double? fee;
  final String timezone;
  final List<AvailabilityDate> dates;
  final NextAvailable? nextAvailable;

  factory AffiliationAvailability.fromJson(Map<String, dynamic> json) {
    final dates = <AvailabilityDate>[];
    final datesRaw = json['dates'];
    if (datesRaw is List) {
      for (final item in datesRaw) {
        if (item is Map) {
          dates.add(AvailabilityDate.fromJson(Map<String, dynamic>.from(item)));
        }
      }
    }

    double? fee;
    if (json['fee'] != null) {
      fee = double.tryParse(json['fee'].toString());
    }

    final facilityRaw = json['facility'];
    final nextAvailableRaw = json['next_available'];

    return AffiliationAvailability(
      affiliationId: json['affiliation_id']?.toString() ?? '',
      facility: facilityRaw is Map
          ? FacilitySummary.fromJson(Map<String, dynamic>.from(facilityRaw))
          : const FacilitySummary.empty(),
      fee: fee,
      timezone: json['timezone'] as String? ?? '',
      dates: dates,
      nextAvailable: nextAvailableRaw is Map
          ? NextAvailable.fromJson(
              Map<String, dynamic>.from(nextAvailableRaw))
          : null,
    );
  }
}

enum AvailabilityDateStatus { available, full, ended, closed, unknown }

AvailabilityDateStatus availabilityDateStatusFromString(String? raw) {
  switch (raw) {
    case 'available':
      return AvailabilityDateStatus.available;
    case 'full':
      return AvailabilityDateStatus.full;
    case 'ended':
      return AvailabilityDateStatus.ended;
    case 'closed':
      return AvailabilityDateStatus.closed;
    default:
      return AvailabilityDateStatus.unknown;
  }
}

class AvailabilityDate {
  const AvailabilityDate({
    required this.date,
    this.weekday = '',
    this.status = AvailabilityDateStatus.unknown,
    this.hasSchedule = false,
    this.sessions = const [],
  });

  final String date;
  final String weekday;
  final AvailabilityDateStatus status;
  final bool hasSchedule;
  final List<AvailabilitySession> sessions;

  bool get isBookable => status == AvailabilityDateStatus.available;

  factory AvailabilityDate.fromJson(Map<String, dynamic> json) {
    final sessions = <AvailabilitySession>[];
    final sessionsRaw = json['sessions'];
    if (sessionsRaw is List) {
      for (final item in sessionsRaw) {
        if (item is Map) {
          sessions.add(
            AvailabilitySession.fromJson(Map<String, dynamic>.from(item)),
          );
        }
      }
    }

    return AvailabilityDate(
      date: json['date'] as String? ?? '',
      weekday: json['weekday'] as String? ?? '',
      status: availabilityDateStatusFromString(json['status'] as String?),
      hasSchedule: json['has_schedule'] == true,
      sessions: sessions,
    );
  }
}

enum AvailabilitySessionStatus { available, full, ended, closed, unknown }

AvailabilitySessionStatus availabilitySessionStatusFromString(String? raw) {
  switch (raw) {
    case 'available':
      return AvailabilitySessionStatus.available;
    case 'full':
      return AvailabilitySessionStatus.full;
    case 'ended':
      return AvailabilitySessionStatus.ended;
    case 'closed':
      return AvailabilitySessionStatus.closed;
    default:
      return AvailabilitySessionStatus.unknown;
  }
}

class AvailabilitySession {
  const AvailabilitySession({
    required this.sessionKey,
    this.startTime = '',
    this.endTime = '',
    this.sessionStart = '',
    this.sessionEnd = '',
    this.capacity = 0,
    this.booked = 0,
    this.remaining = 0,
    this.nextSerial,
    this.estimatedTime = '',
    this.status = AvailabilitySessionStatus.unknown,
    this.note = '',
  });

  final String sessionKey;
  final String startTime;
  final String endTime;
  final String sessionStart;
  final String sessionEnd;
  final int capacity;
  final int booked;
  final int remaining;
  final int? nextSerial;
  final String estimatedTime;
  final AvailabilitySessionStatus status;
  final String note;

  bool get isAvailable => status == AvailabilitySessionStatus.available;

  factory AvailabilitySession.fromJson(Map<String, dynamic> json) {
    return AvailabilitySession(
      sessionKey: json['session_key'] as String? ?? '',
      startTime: json['start_time'] as String? ?? '',
      endTime: json['end_time'] as String? ?? '',
      sessionStart: json['session_start'] as String? ?? '',
      sessionEnd: json['session_end'] as String? ?? '',
      capacity: (json['capacity'] as num?)?.toInt() ?? 0,
      booked: (json['booked'] as num?)?.toInt() ?? 0,
      remaining: (json['remaining'] as num?)?.toInt() ?? 0,
      nextSerial: (json['next_serial'] as num?)?.toInt(),
      estimatedTime: json['estimated_time'] as String? ?? '',
      status: availabilitySessionStatusFromString(json['status'] as String?),
      note: json['note'] as String? ?? '',
    );
  }
}
