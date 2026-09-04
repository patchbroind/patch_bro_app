String normalizePhone(String value) {
  final phone = value.trim();

  if (phone.isEmpty) {
    return '';
  }

  if (phone.startsWith('+')) {
    final digits = phone.substring(1).replaceAll(RegExp(r'\D'), '');

    return '+$digits';
  }

  final digits = phone.replaceAll(RegExp(r'\D'), '');

  if (digits.startsWith('91') && digits.length == 12) {
    return '+$digits';
  }

  return '+91$digits';
}