import 'package:cribe/data/models/auth/refresh_token_response.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RefreshTokenResponse', () {
    test('should create RefreshTokenResponse from constructor', () {
      final response = RefreshTokenResponse(
        accessToken: 'new_access_token_123',
      );

      expect(response.accessToken, 'new_access_token_123');
    });

    test('should create RefreshTokenResponse from JSON', () {
      final json = {
        'access_token': 'new_access_token_123',
      };

      final response = RefreshTokenResponse.fromJson(json);

      expect(response.accessToken, 'new_access_token_123');
    });

    test('should handle missing fields in JSON', () {
      final json = <String, dynamic>{};

      final response = RefreshTokenResponse.fromJson(json);

      expect(response.accessToken, '');
    });

    test('should convert RefreshTokenResponse to JSON', () {
      final response = RefreshTokenResponse(
        accessToken: 'new_access_token_123',
      );

      final json = response.toJson();

      expect(json['access_token'], 'new_access_token_123');
      expect(json.length, 1);
    });
  });
}
