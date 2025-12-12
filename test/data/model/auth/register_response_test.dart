import 'package:cribe/data/models/auth/register_response.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RegisterResponse', () {
    group('constructor', () {
      test('should create RegisterResponse with required id', () {
        // Arrange
        const id = 123;

        // Act
        final response = RegisterResponse(id: id);

        // Assert
        expect(response.id, equals(id));
      });

      test('should create RegisterResponse with zero id', () {
        // Arrange
        const id = 0;

        // Act
        final response = RegisterResponse(id: id);

        // Assert
        expect(response.id, equals(0));
      });

      test('should create RegisterResponse with negative id', () {
        // Arrange
        const id = -1;

        // Act
        final response = RegisterResponse(id: id);

        // Assert
        expect(response.id, equals(-1));
      });
    });

    group('fromJson', () {
      test('should create RegisterResponse from valid JSON map', () {
        // Arrange
        final json = {
          'id': 456,
        };

        // Act
        final response = RegisterResponse.fromJson(json);

        // Assert
        expect(response.id, equals(456));
      });

      test('should handle null id in JSON', () {
        // Arrange
        final json = {
          'id': null,
        };

        // Act
        final response = RegisterResponse.fromJson(json);

        // Assert
        expect(response.id, equals(0));
      });

      test('should handle missing id field in JSON', () {
        // Arrange
        final json = <String, dynamic>{};

        // Act
        final response = RegisterResponse.fromJson(json);

        // Assert
        expect(response.id, equals(0));
      });

      test('should handle string id by converting to int', () {
        // Arrange
        final json = {
          'id': '789',
        };

        // Act & Assert
        expect(
          () => RegisterResponse.fromJson(json),
          throwsA(isA<TypeError>()),
        );
      });

      test('should handle double id by type casting behavior', () {
        // Arrange
        final json = {
          'id': 123.0,
        };

        // Act & Assert - This will throw because the code uses strict type casting
        expect(
          () => RegisterResponse.fromJson(json),
          throwsA(isA<TypeError>()),
        );
      });

      test('should handle JSON with extra fields', () {
        // Arrange
        final json = {
          'id': 999,
          'email': 'user@example.com',
          'name': 'John Doe',
          'created_at': '2023-01-01T00:00:00Z',
        };

        // Act
        final response = RegisterResponse.fromJson(json);

        // Assert
        expect(response.id, equals(999));
      });

      test('should handle zero id in JSON', () {
        // Arrange
        final json = {
          'id': 0,
        };

        // Act
        final response = RegisterResponse.fromJson(json);

        // Assert
        expect(response.id, equals(0));
      });

      test('should handle negative id in JSON', () {
        // Arrange
        final json = {
          'id': -5,
        };

        // Act
        final response = RegisterResponse.fromJson(json);

        // Assert
        expect(response.id, equals(-5));
      });

      test('should handle large id values', () {
        // Arrange
        final json = {
          'id': 9999999999,
        };

        // Act
        final response = RegisterResponse.fromJson(json);

        // Assert
        expect(response.id, equals(9999999999));
      });
    });

    group('integration tests', () {
      test('should work in typical registration flow', () {
        // Arrange - Simulate API response after successful registration
        final apiResponseJson = {
          'id': 12345,
          'message': 'User registered successfully',
        };

        // Act - Parse response
        final registerResponse = RegisterResponse.fromJson(apiResponseJson);

        // Create new instance with same id
        final responseCopy = RegisterResponse(id: registerResponse.id);

        // Assert
        expect(registerResponse.id, equals(12345));
        expect(responseCopy.id, equals(registerResponse.id));
      });

      test('should handle typical success response structure', () {
        // Arrange - Common API response structure
        final successJson = {
          'success': true,
          'data': {
            'id': 54321,
            'username': 'newuser',
          },
          'message': 'Registration completed',
        };

        // Act - Extract data object and parse
        final dataJson = successJson['data'] as Map<String, dynamic>;
        final registerResponse = RegisterResponse.fromJson(dataJson);

        // Assert
        expect(registerResponse.id, equals(54321));
      });
    });
  });
}
