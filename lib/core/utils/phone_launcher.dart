import 'package:url_launcher/url_launcher.dart';

/// Opens a `tel:` link. No-op on failure (device has no dialer, etc.).
Future<void> launchPhone(String phone) async {
  if (phone.isEmpty) return;
  final uri = Uri(scheme: 'tel', path: phone);
  try {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  } catch (_) {
    // Ignore.
  }
}
