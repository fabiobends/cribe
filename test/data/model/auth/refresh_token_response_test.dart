import 'package:cribe/data/models/auth/refresh_token_response.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RefreshTokenResponse', () {
    group('constructor', () {
      test('should create RefreshTokenResponse with required accessToken', () {
        // Arrange
        const accessToken = 'new_access_token';

        // Act
        final response = RefreshTokenResponse(accessToken: accessToken);

        // Assert
        expect(response.accessToken, equals(accessToken));
      });

      test('should create RefreshTokenResponse with empty accessToken', () {
        // Arrange
        const accessToken = '';

        // Act
        final response = RefreshTokenResponse(accessToken: accessToken);

        // Assert
        expect(response.accessToken, equals(''));
      });
    });

    group('fromJson', () {
      test('should create RefreshTokenResponse from valid JSON map', () {
        // Arrange
        final json = {
          'access_token': 'refreshed_access_token',
        };

        // Act
        final response = RefreshTokenResponse.fromJson(json);

        // Assert
        expect(response.accessToken, equals('refreshed_access_token'));
      });

      test('should handle null access_token in JSON', () {
        // Arrange
        final json = {
          'access_token': null,
        };

        // Act
        final response = RefreshTokenResponse.fromJson(json);

        // Assert
        expect(response.accessToken, equals(''));
      });

      test('should handle missing access_token field in JSON', () {
        // Arrange
        final json = <String, dynamic>{};

        // Act
        final response = RefreshTokenResponse.fromJson(json);

        // Assert
        expect(response.accessToken, equals(''));
      });

      test('should handle non-string access_token by converting to string', () {
        // Arrange
        final json = {
          'access_token': 12345,
        };

        // Act
        final response = RefreshTokenResponse.fromJson(json);

        // Assert
        expect(response.accessToken, equals('12345'));
      });

      test('should handle boolean access_token by converting to string', () {
        // Arrange
        final json = {
          'access_token': true,
        };

        // Act
        final response = RefreshTokenResponse.fromJson(json);

        // Assert
        expect(response.accessToken, equals('true'));
      });

      test('should handle JSON with extra fields', () {
        // Arrange
        final json = {
          'access_token': 'token_with_extras',
          'expires_in': 3600,
          'token_type': 'Bearer',
          'scope': 'read write',
        };

        // Act
        final response = RefreshTokenResponse.fromJson(json);

        // Assert
        expect(response.accessToken, equals('token_with_extras'));
      });

      test('should handle empty string access_token in JSON', () {
        // Arrange
        final json = {
          'access_token': '',
        };

        // Act
        final response = RefreshTokenResponse.fromJson(json);

        // Assert
        expect(response.accessToken, equals(''));
      });

      test('should handle whitespace-only access_token', () {
        // Arrange
        final json = {
          'access_token': '   ',
        };

        // Act
        final response = RefreshTokenResponse.fromJson(json);

        // Assert
        expect(response.accessToken, equals('   '));
      });
    });

    group('integration tests', () {
      test('should work in typical token refresh flow', () {
        // Arrange - Simulate API response after token refresh
        final apiResponseJson = {
          'access_token': 'new_jwt_access_token_here',
          'expires_in': 3600,
          'token_type': 'Bearer',
        };

        // Act - Parse response
        final refreshResponse = RefreshTokenResponse.fromJson(apiResponseJson);

        // Create new instance with same token
        final responseCopy =
            RefreshTokenResponse(accessToken: refreshResponse.accessToken);

        // Assert
        expect(
          refreshResponse.accessToken,
          equals('new_jwt_access_token_here'),
        );
        expect(responseCopy.accessToken, equals(refreshResponse.accessToken));
      });

      test('should handle typical OAuth2 refresh response structure', () {
        // Arrange - Common OAuth2 token refresh response
        final oauthJson = {
          'access_token': 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...',
          'token_type': 'Bearer',
          'expires_in': 1800,
          'scope': 'user:read user:write',
        };

        // Act - Parse response
        final refreshResponse = RefreshTokenResponse.fromJson(oauthJson);

        // Assert
        expect(
          refreshResponse.accessToken,
          equals('eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...'),
        );
      });

      test('should handle error response gracefully', () {
        // Arrange - Simulate error response that might not have access_token
        final errorJson = {
          'error': 'invalid_grant',
          'error_description': 'The provided authorization grant is invalid',
        };

        // Act - Parse response (should default to empty string)
        final refreshResponse = RefreshTokenResponse.fromJson(errorJson);

        // Assert
        expect(refreshResponse.accessToken, equals(''));
      });
    });
  });
}
