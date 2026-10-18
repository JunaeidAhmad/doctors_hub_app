/// Asia/Dhaka (UTC+6, no DST) helpers. The backend's date windows are in
/// Asia/Dhaka, not the device zone.
class DhakaTime {
  const DhakaTime._();

  static const Duration offset = Duration(hours: 6);

  /// "Now" on the Dhaka wall clock, as a UTC DateTime shifted by +6h.
  static DateTime now() => DateTime.now().toUtc().add(offset);

  static String _two(int value) => value.toString().padLeft(2, '0');

  static String isoDate(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-${_two(date.month)}-${_two(date.day)}';

  static String todayIso() => isoDate(now());

  /// Parses a v1 `date` + `HH:MM` pair as a Dhaka wall-clock instant.
  static DateTime parseDhaka(String dateIso, String time) {
    final date = DateTime.parse(dateIso);
    final parts = time.split(':');
    final hour = parts.isNotEmpty ? int.tryParse(parts[0]) ?? 0 : 0;
    final minute = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;
    return DateTime.utc(date.year, date.month, date.day, hour, minute)
        .subtract(offset);
  }

  /// True when a request-mode session has reached its cutoff.
  /// Morning sessions (start before 12:00 Dhaka) close 2 hours before start;
  /// every other session closes 1 hour before start (backend Part 8
  /// `request_rules.py`). The boundary itself counts as closed; the server
  /// still has the final say.
  static bool requestCutoffReached({
    required DateTime now,
    required String dateIso,
    required String sessionStart,
  }) {
    final start = parseDhaka(dateIso, sessionStart);
    final parts = sessionStart.split(':');
    final hour = parts.isNotEmpty ? int.tryParse(parts[0]) ?? 0 : 0;
    final cutoff = Duration(hours: hour < 12 ? 2 : 1);
    return !start.isAfter(now.add(cutoff));
  }
}
