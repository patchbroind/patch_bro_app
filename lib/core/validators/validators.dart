abstract final class Validators {
  Validators._();

  // ============================================================
  // Required
  // ============================================================

  static String? required(
    String? value, {
    String fieldName = 'This field',
  }) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }

    return null;
  }

  // ============================================================
  // Phone
  // ============================================================

  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }

    final phone = value.trim();

    if (!RegExp(r'^[0-9]{10}$').hasMatch(phone)) {
      return 'Enter a valid phone number';
    }

    return null;
  }

  // ============================================================
  // Email
  // ============================================================

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }

    final email = value.trim();

    final emailRegex = RegExp(
      r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
    );

    if (!emailRegex.hasMatch(email)) {
      return 'Enter a valid email';
    }

    return null;
  }

  // ============================================================
  // Password
  // ============================================================

  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < 6) {
      return 'Password must contain at least 6 characters';
    }

    return null;
  }

  // ============================================================
  // Confirm Password
  // ============================================================

  static String? confirmPassword(
    String? value,
    String password,
  ) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }

    if (value != password) {
      return 'Passwords do not match';
    }

    return null;
  }

  // ============================================================
  // PIN Code
  // ============================================================

  static String? pinCode(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Pin Code is required';
    }

    if (!RegExp(r'^[0-9]{6}$').hasMatch(value.trim())) {
      return 'Enter a valid 6-digit pin code';
    }

    return null;
  }
}