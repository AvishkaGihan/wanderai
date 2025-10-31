class Validators {
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Enter a valid email';
    }
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  static String? required(String? value, {String fieldName = 'Field'}) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  static String? positiveNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a number';
    }
    final number = double.tryParse(value);
    if (number == null || number <= 0) {
      return 'Please enter a positive number';
    }
    return null;
  }

  static String? dateRange(DateTime? start, DateTime? end) {
    if (start == null || end == null) {
      return 'Please select both dates';
    }
    if (end.isBefore(start)) {
      return 'End date must be after start date';
    }
    return null;
  }
}
