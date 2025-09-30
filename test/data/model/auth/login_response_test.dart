import 'package:cribe/data/model/auth/login_response.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LoginResponse', () {
    group('constructor', () {
      test('should create LoginResponse with required fields', () {
        // Arrange
        const accessToken = 'test_access_token';
        const refreshToken = 'test_refresh_token';

        // Act
        final response = LoginResponse(
          accessToken: accessToken,
          refreshToken: refreshToken,
        );

        // Assert
        expect(response.accessToken, equals(accessToken));
        expect(response.refreshToken, equals(refreshToken));
      });

      test('should create LoginResponse with empty tokens', () {
        // Arrange
        const accessToken = '';
        const refreshToken = '';

        // Act
        final response = LoginResponse(
          accessToken: accessToken,
          refreshToken: refreshToken,
        );

        // Assert
        expect(response.accessToken, equals(''));
        expect(response.refreshToken, equals(''));
      });
    });

    group('fromJson', () {
      test('should create LoginResponse from valid JSON map', () {
        // Arrange
        final json = {
          'access_token': 'sample_access_token',
          'refresh_token': 'sample_refresh_token',
        };

        // Act
        final response = LoginResponse.fromJson(json);

        // Assert
        expect(response.accessToken, equals('sample_access_token'));
        expect(response.refreshToken, equals('sample_refresh_token'));
      });

      test('should handle null access_token in JSON', () {
        // Arrange
        final json = {
          'access_token': null,
          'refresh_token': 'sample_refresh_token',
        };

        // Act
        final response = LoginResponse.fromJson(json);

        // Assert
        expect(response.accessToken, equals(''));
        expect(response.refreshToken, equals('sample_refresh_token'));
      });

      test('should handle null refresh_token in JSON', () {
        // Arrange
        final json = {
          'access_token': 'sample_access_token',
          'refresh_token': null,
        };

        // Act
        final response = LoginResponse.fromJson(json);

        // Assert
        expect(response.accessToken, equals('sample_access_token'));
        expect(response.refreshToken, equals(''));
      });

      test('should handle missing access_token field in JSON', () {
        // Arrange
        final json = {
          'refresh_token': 'sample_refresh_token',
        };

        // Act
        final response = LoginResponse.fromJson(json);

        // Assert
        expect(response.accessToken, equals(''));
        expect(response.refreshToken, equals('sample_refresh_token'));
      });

      test('should handle missing refresh_token field in JSON', () {
        // Arrange
        final json = {
          'access_token': 'sample_access_token',
        };

        // Act
        final response = LoginResponse.fromJson(json);

        // Assert
        expect(response.accessToken, equals('sample_access_token'));
        expect(response.refreshToken, equals(''));
      });

      test('should handle empty JSON map', () {
        // Arrange
        final json = <String, dynamic>{};

        // Act
        final response = LoginResponse.fromJson(json);

        // Assert
        expect(response.accessToken, equals(''));
        expect(response.refreshToken, equals(''));
      });

      test('should handle non-string token values by converting to string', () {
        // Arrange
        final json = {
          'access_token': 12345,
          'refresh_token': true,
        };

        // Act
        final response = LoginResponse.fromJson(json);

        // Assert
        expect(response.accessToken, equals('12345'));
        expect(response.refreshToken, equals('true'));
      });

      test('should handle JSON with extra fields', () {
        // Arrange
        final json = {
          'access_token': 'sample_access_token',
          'refresh_token': 'sample_refresh_token',
          'user_id': 123,
          'expires_in': 3600,
          'token_type': 'Bearer',
        };

        // Act
        final response = LoginResponse.fromJson(json);

        // Assert
        expect(response.accessToken, equals('sample_access_token'));
        expect(response.refreshToken, equals('sample_refresh_token'));
      });
    });

    group('AuthTokens typedef', () {
      test('should work as AuthTokens alias', () {
        // Arrange
        const accessToken = 'auth_access_token';
        const refreshToken = 'auth_refresh_token';

        // Act
        final tokens = AuthTokens(
          accessToken: accessToken,
          refreshToken: refreshToken,
        );

        // Assert
        expect(tokens, isA<LoginResponse>());
        expect(tokens.accessToken, equals(accessToken));
        expect(tokens.refreshToken, equals(refreshToken));
      });

      test('should work with fromJson as AuthTokens', () {
        // Arrange
        final json = {
          'access_token': 'auth_sample_access_token',
          'refresh_token': 'auth_sample_refresh_token',
        };

        // Act
        final tokens = AuthTokens.fromJson(json);

        // Assert
        expect(tokens, isA<LoginResponse>());
        expect(tokens.accessToken, equals('auth_sample_access_token'));
        expect(tokens.refreshToken, equals('auth_sample_refresh_token'));
      });
    });

    group('integration tests', () {
      test('should work in typical authentication flow', () {
        // Arrange - Simulate API response
        final apiResponseJson = {
          'access_token': 'jwt_access_token_here',
          'refresh_token': 'jwt_refresh_token_here',
        };

        // Act - Parse response
        final loginResponse = LoginResponse.fromJson(apiResponseJson);

        // Create new instance with same values
        final tokensCopy = LoginResponse(
          accessToken: loginResponse.accessToken,
          refreshToken: loginResponse.refreshToken,
        );

        // Assert
        expect(loginResponse.accessToken, equals('jwt_access_token_here'));
        expect(loginResponse.refreshToken, equals('jwt_refresh_token_here'));
        expect(tokensCopy.accessToken, equals(loginResponse.accessToken));
        expect(tokensCopy.refreshToken, equals(loginResponse.refreshToken));
      });
    });
  });
}
