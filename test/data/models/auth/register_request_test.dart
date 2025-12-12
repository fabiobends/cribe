import 'package:cribe/data/models/auth/register_request.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RegisterRequest', () {
    test('should create RegisterRequest from constructor', () {
      final request = RegisterRequest(
        email: 'test@example.com',
        password: 'password123',
        firstName: 'John',
        lastName: 'Doe',
      );

      expect(request.email, 'test@example.com');
      expect(request.password, 'password123');
      expect(request.firstName, 'John');
      expect(request.lastName, 'Doe');
    });

    test('should convert RegisterRequest to JSON', () {
      final request = RegisterRequest(
        email: 'test@example.com',
        password: 'password123',
        firstName: 'John',
        lastName: 'Doe',
      );

      final json = request.toJson();

      expect(json['email'], 'test@example.com');
      expect(json['password'], 'password123');
      expect(json['first_name'], 'John');
      expect(json['last_name'], 'Doe');
      expect(json.length, 4);
    });
  });
}
