import 'package:cribe/domain/models/user.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('User', () {
    test('should create User from constructor - happy path', () {
      final user = User(
        id: '123',
        email: 'test@example.com',
        firstName: 'John',
        lastName: 'Doe',
      );

      expect(user.id, '123');
      expect(user.email, 'test@example.com');
      expect(user.firstName, 'John');
      expect(user.lastName, 'Doe');
    });

    test('should create User from JSON - happy path', () {
      final json = {
        'id': '123',
        'email': 'test@example.com',
        'first_name': 'John',
        'last_name': 'Doe',
      };

      final user = User.fromJson(json);

      expect(user.id, '123');
      expect(user.email, 'test@example.com');
      expect(user.firstName, 'John');
      expect(user.lastName, 'Doe');
    });

    test('should handle missing fields in JSON - unhappy path', () {
      final json = <String, dynamic>{};

      final user = User.fromJson(json);

      expect(user.id, '');
      expect(user.email, '');
      expect(user.firstName, '');
      expect(user.lastName, '');
    });

    test('should convert User to JSON - happy path', () {
      final user = User(
        id: '123',
        email: 'test@example.com',
        firstName: 'John',
        lastName: 'Doe',
      );

      final json = user.toJson();

      expect(json['id'], '123');
      expect(json['email'], 'test@example.com');
      expect(json['firstName'], 'John');
      expect(json['lastName'], 'Doe');
    });
  });
}
