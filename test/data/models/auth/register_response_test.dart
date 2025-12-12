import 'package:cribe/data/models/auth/register_response.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RegisterResponse', () {
    test('should create RegisterResponse from constructor', () {
      final response = RegisterResponse(id: 42);

      expect(response.id, 42);
    });

    test('should create RegisterResponse from JSON', () {
      final json = {'id': 42};

      final response = RegisterResponse.fromJson(json);

      expect(response.id, 42);
    });

    test('should handle missing id in JSON', () {
      final json = <String, dynamic>{};

      final response = RegisterResponse.fromJson(json);

      expect(response.id, 0);
    });
  });
}
