import 'package:validators/validators.dart';

class ValidationService {
  static ValidationResult validateEmail(String email) {
    if (email.isEmpty) {
      return ValidationResult(
        isValid: false,
        errorMessage: 'Email is required',
      );
    }

    if (!isEmail(email)) {
      return ValidationResult(
        isValid: false,
        errorMessage: 'Please enter a valid email address',
      );
    }

    return ValidationResult(isValid: true);
  }

  static ValidationResult validatePassword(String password) {
    if (password.isEmpty) {
      return ValidationResult(
        isValid: false,
        errorMessage: 'Password is required',
      );
    }

    if (password.length < 8) {
      return ValidationResult(
        isValid: false,
        errorMessage: 'Password must be at least 8 characters long',
      );
    }

    // Check for at least one uppercase letter
    if (!password.contains(RegExp(r'[A-Z]'))) {
      return ValidationResult(
        isValid: false,
        errorMessage: 'Password must contain at least one uppercase letter',
      );
    }

    // Check for at least one lowercase letter
    if (!password.contains(RegExp(r'[a-z]'))) {
      return ValidationResult(
        isValid: false,
        errorMessage: 'Password must contain at least one lowercase letter',
      );
    }

    // Check for at least one digit
    if (!password.contains(RegExp(r'[0-9]'))) {
      return ValidationResult(
        isValid: false,
        errorMessage: 'Password must contain at least one number',
      );
    }

    return ValidationResult(isValid: true);
  }

  static ValidationResult validateConfirmPassword(
    String password,
    String confirmPassword,
  ) {
    if (confirmPassword.isEmpty) {
      return ValidationResult(
        isValid: false,
        errorMessage: 'Please confirm your password',
      );
    }

    if (password != confirmPassword) {
      return ValidationResult(
        isValid: false,
        errorMessage: 'Passwords do not match',
      );
    }

    return ValidationResult(isValid: true);
  }

  static ValidationResult validateLoginPassword(String password) {
    if (password.isEmpty) {
      return ValidationResult(
        isValid: false,
        errorMessage: 'Password is required',
      );
    }

    if (password.length < 8) {
      return ValidationResult(
        isValid: false,
        errorMessage: 'Password must be at least 8 characters',
      );
    }

    return ValidationResult(isValid: true);
  }

  static ValidationResult validateName(String name) {
    if (name.isEmpty) {
      return ValidationResult(
        isValid: false,
        errorMessage: 'Name is required',
      );
    }

    if (name.trim().length < 2) {
      return ValidationResult(
        isValid: false,
        errorMessage: 'Name must be at least 2 characters long',
      );
    }

    return ValidationResult(isValid: true);
  }
}

class ValidationResult {
  final bool isValid;
  final String? errorMessage;

  ValidationResult({
    required this.isValid,
    this.errorMessage,
  });
}
