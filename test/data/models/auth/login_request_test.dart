import 'package:cribe/data/models/auth/login_request.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LoginRequest', () {
    test('should create LoginRequest from constructor', () {
      final request = LoginRequest(
        email: 'test@example.com',
        password: 'password123',
      );

      expect(request.email, 'test@example.com');
      expect(request.password, 'password123');
    });

    test('should convert LoginRequest to JSON', () {
      final request = LoginRequest(
        email: 'test@example.com',
        password: 'password123',
      );

      final json = request.toJson();

      expect(json['email'], 'test@example.com');
      expect(json['password'], 'password123');
      expect(json.length, 2);
    });
  });
}
