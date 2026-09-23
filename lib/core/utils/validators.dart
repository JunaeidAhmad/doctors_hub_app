class Validators {
  const Validators._();

  static final RegExp _bdPhoneRegExp = RegExp(r'^01[3-9]\d{8}$');

  /// Validates Bangladesh phone number (11 digits, starts with 013-019)
  static bool isValidBdPhone(String? phone) {
    if (phone == null) return false;
    final cleaned = phone.replaceAll(RegExp(r'[\s\-\+]'), '');
    final normalized = cleaned.startsWith('88') ? cleaned.substring(2) : cleaned;
    return _bdPhoneRegExp.hasMatch(normalized);
  }

  /// Normalizes phone number to 11 digits without 88 prefix
  static String normalizePhone(String phone) {
    final cleaned = phone.replaceAll(RegExp(r'[\s\-\+]'), '');
    return cleaned.startsWith('88') ? cleaned.substring(2) : cleaned;
  }
}
