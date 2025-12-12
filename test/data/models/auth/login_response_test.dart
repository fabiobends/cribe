import 'package:cribe/data/models/auth/login_response.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LoginResponse', () {
    test('should create LoginResponse from constructor', () {
      final response = LoginResponse(
        accessToken: 'access_token_123',
        refreshToken: 'refresh_token_456',
      );

      expect(response.accessToken, 'access_token_123');
      expect(response.refreshToken, 'refresh_token_456');
    });

    test('should create LoginResponse from JSON', () {
      final json = {
        'access_token': 'access_token_123',
        'refresh_token': 'refresh_token_456',
      };

      final response = LoginResponse.fromJson(json);

      expect(response.accessToken, 'access_token_123');
      expect(response.refreshToken, 'refresh_token_456');
    });

    test('should handle missing fields in JSON', () {
      final json = <String, dynamic>{};

      final response = LoginResponse.fromJson(json);

      expect(response.accessToken, '');
      expect(response.refreshToken, '');
    });
  });
}
