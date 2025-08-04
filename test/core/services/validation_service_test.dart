import 'package:cribe/core/services/validation_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ValidationService', () {
    group('validateEmail', () {
      test('should accept valid email with plus sign', () {
        // Act
        final result = ValidationService.validateEmail('user+01@email.com');

        // Assert
        expect(result.isValid, isTrue);
        expect(result.errorMessage, isNull);
      });

      test('should accept standard email formats', () {
        final validEmails = [
          'test@example.com',
          'user.name@example.com',
          'user+tag@gmail.com',
          'firstname.lastname@domain.co.uk',
          '123@domain.com',
          'user@sub.domain.org',
        ];

        for (final email in validEmails) {
          final result = ValidationService.validateEmail(email);
          expect(result.isValid, isTrue, reason: '$email should be valid');
        }
      });

      test('should reject invalid email formats', () {
        final invalidEmails = [
          '',
          'invalid-email',
          '@domain.com',
          'user@',
          'user.domain.com',
          'user @domain.com',
        ];

        for (final email in invalidEmails) {
          final result = ValidationService.validateEmail(email);
          expect(result.isValid, isFalse, reason: '$email should be invalid');
          expect(result.errorMessage, isNotNull);
        }
      });
    });

    group('validatePassword', () {
      test('should require strong password for registration', () {
        // Act
        final result = ValidationService.validatePassword('Password123');

        // Assert
        expect(result.isValid, isTrue);
        expect(result.errorMessage, isNull);
      });

      test('should reject weak passwords', () {
        final weakPasswords = [
          '',
          '123', // too short
          'password', // no uppercase or numbers
          'PASSWORD', // no lowercase or numbers
          'Password', // no numbers
          '12345678', // no letters
        ];

        for (final password in weakPasswords) {
          final result = ValidationService.validatePassword(password);
          expect(
            result.isValid,
            isFalse,
            reason: '$password should be invalid',
          );
          expect(result.errorMessage, isNotNull);
        }
      });
    });

    group('validateConfirmPassword', () {
      test('should match when passwords are identical', () {
        // Act
        final result = ValidationService.validateConfirmPassword(
          'Password123',
          'Password123',
        );

        // Assert
        expect(result.isValid, isTrue);
        expect(result.errorMessage, isNull);
      });

      test('should fail when passwords do not match', () {
        // Act
        final result = ValidationService.validateConfirmPassword(
          'Password123',
          'Different123',
        );

        // Assert
        expect(result.isValid, isFalse);
        expect(result.errorMessage, equals('Passwords do not match'));
      });
    });

    group('validateName', () {
      test('should accept valid names', () {
        final validNames = ['John', 'Mary Jane', 'José', 'Anne-Marie'];

        for (final name in validNames) {
          final result = ValidationService.validateName(name);
          expect(result.isValid, isTrue, reason: '$name should be valid');
        }
      });

      test('should reject invalid names', () {
        final invalidNames = ['', ' ', 'A'];

        for (final name in invalidNames) {
          final result = ValidationService.validateName(name);
          expect(result.isValid, isFalse, reason: '$name should be invalid');
          expect(result.errorMessage, isNotNull);
        }
      });
    });

    group('validateLoginPassword', () {
      test('should accept password with minimum length for login', () {
        // Act
        final result = ValidationService.validateLoginPassword('password');

        // Assert
        expect(result.isValid, isTrue);
        expect(result.errorMessage, isNull);
      });

      test('should reject empty password for login', () {
        // Act
        final result = ValidationService.validateLoginPassword('');

        // Assert
        expect(result.isValid, isFalse);
        expect(result.errorMessage, equals('Password is required'));
      });

      test('should reject password shorter than 8 characters for login', () {
        // Act
        final result = ValidationService.validateLoginPassword(
          '1234567',
        );

        // Assert
        expect(result.isValid, isFalse);
        expect(
          result.errorMessage,
          equals('Password must be at least 8 characters'),
        );
      });
    });
  });
}
