import 'package:url_launcher/url_launcher.dart';

/// Opens the store URL from the update gate. Does nothing when empty;
/// failures are swallowed (the copy still tells the patient to update).
Future<void> openStoreUrl(String? storeUrl) async {
  if (storeUrl == null || storeUrl.isEmpty) return;
  final uri = Uri.tryParse(storeUrl);
  if (uri == null) return;
  try {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  } catch (_) {
    // Ignore: the message is still shown.
  }
}
