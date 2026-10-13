import 'package:intl/intl.dart';

import '../../../l10n/app_localizations.dart';
import '../../doctors/domain/models/chamber.dart';

/// Pure view model for the doctor booking flow, by chamber `booking_mode`.
///
/// `badgeKey` / `buttonKey` name ARB keys; screens resolve them with
/// [bookingModeLabel].
class BookingModeView {
  const BookingModeView({
    required this.mode,
    this.badgeKey,
    this.buttonKey,
    required this.showSessions,
    required this.showSeatCounts,
    required this.showSerial,
    required this.canBook,
  });

  final BookingMode mode;
  final String? badgeKey;
  final String? buttonKey;
  final bool showSessions;
  final bool showSeatCounts;
  final bool showSerial;

  /// True for `instant` and `request`: the booking form can be submitted.
  final bool canBook;
}

BookingModeView bookingModeView(Chamber chamber) {
  switch (chamber.bookingMode) {
    case BookingMode.instant:
      return const BookingModeView(
        mode: BookingMode.instant,
        badgeKey: 'badgeInstantBooking',
        buttonKey: 'ctaBookAppointment',
        showSessions: true,
        showSeatCounts: true,
        showSerial: true,
        canBook: true,
      );
    case BookingMode.request:
      return const BookingModeView(
        mode: BookingMode.request,
        badgeKey: 'badgeBookingByRequest',
        buttonKey: 'ctaRequestAppointment',
        showSessions: true,
        showSeatCounts: true,
        showSerial: false,
        canBook: true,
      );
    case BookingMode.callOnly:
      return const BookingModeView(
        mode: BookingMode.callOnly,
        badgeKey: 'badgeBookByPhone',
        buttonKey: 'ctaGetPhoneNumber',
        showSessions: false,
        showSeatCounts: false,
        showSerial: false,
        canBook: false,
      );
    case BookingMode.unknown:
      return const BookingModeView(
        mode: BookingMode.unknown,
        showSessions: false,
        showSeatCounts: false,
        showSerial: false,
        canBook: false,
      );
  }
}

/// "Next: Thu · 5:00 PM · 12 left" for instant and request chambers, or null
/// when the chamber has no `next_available` (or is call-only / unknown).
String? nextAvailableLabel(Chamber chamber, AppLocalizations l10n) {
  if (chamber.bookingMode != BookingMode.instant &&
      chamber.bookingMode != BookingMode.request) {
    return null;
  }
  final next = chamber.nextAvailable;
  if (next == null || next.date == null || next.sessionStart == null) {
    return null;
  }
  final date = DateTime.tryParse(next.date!);
  final day = date == null ? '' : DateFormat('EEE').format(date);
  final time = formatHm(next.sessionStart!);
  return l10n.nextAvailableShort(day, time, next.remaining ?? 0);
}

/// Formats "HH:MM" / "HH:MM:SS" as "5:00 PM".
String formatHm(String time) {
  final parts = time.split(':');
  if (parts.isEmpty) return time;
  final hour = int.tryParse(parts[0]) ?? 0;
  final minute = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;
  return DateFormat('h:mm a').format(DateTime(2000, 1, 1, hour, minute));
}

/// Resolves a `badgeKey` / `buttonKey` from [BookingModeView] to copy.
String? bookingModeLabel(String? key, AppLocalizations l10n) {
  switch (key) {
    case 'badgeInstantBooking':
      return l10n.badgeInstantBooking;
    case 'badgeBookingByRequest':
      return l10n.badgeBookingByRequest;
    case 'badgeBookByPhone':
      return l10n.badgeBookByPhone;
    case 'ctaBookAppointment':
      return l10n.ctaBookAppointment;
    case 'ctaRequestAppointment':
      return l10n.ctaRequestAppointment;
    case 'ctaGetPhoneNumber':
      return l10n.ctaGetPhoneNumber;
    case 'ctaSendRequest':
      return l10n.ctaSendRequest;
    default:
      return null;
  }
}
