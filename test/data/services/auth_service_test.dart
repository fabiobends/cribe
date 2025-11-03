import 'package:cribe/core/constants/storage_keys.dart';
import 'package:cribe/data/services/auth_service.dart';
import 'package:cribe/data/services/storage_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'auth_service_test.mocks.dart';

@GenerateMocks([StorageService])
void main() {
  late MockStorageService mockStorageService;
  late AuthService authService;

  setUp(() {
    mockStorageService = MockStorageService();
    authService = AuthService(mockStorageService);
  });

  group('AuthService', () {
    test('should return true when access token exists - happy path', () async {
      when(mockStorageService.getSecureValue(SecureStorageKey.accessToken))
          .thenAnswer((_) async => 'valid_token');

      final isAuth = await authService.isAuthenticated;

      expect(isAuth, isTrue);
      verify(mockStorageService.getSecureValue(SecureStorageKey.accessToken))
          .called(1);
    });

    test('should return false when access token is empty - unhappy path',
        () async {
      when(mockStorageService.getSecureValue(SecureStorageKey.accessToken))
          .thenAnswer((_) async => '');

      final isAuth = await authService.isAuthenticated;

      expect(isAuth, isFalse);
    });

    test('should return access token - happy path', () async {
      const expectedToken = 'access_token_123';
      when(mockStorageService.getSecureValue(SecureStorageKey.accessToken))
          .thenAnswer((_) async => expectedToken);

      final token = await authService.accessToken;

      expect(token, expectedToken);
      verify(mockStorageService.getSecureValue(SecureStorageKey.accessToken))
          .called(1);
    });

    test('should return refresh token - happy path', () async {
      const expectedToken = 'refresh_token_456';
      when(mockStorageService.getSecureValue(SecureStorageKey.refreshToken))
          .thenAnswer((_) async => expectedToken);

      final token = await authService.refreshToken;

      expect(token, expectedToken);
      verify(mockStorageService.getSecureValue(SecureStorageKey.refreshToken))
          .called(1);
    });

    test('should initialize without errors', () async {
      await authService.init();
      // Should complete without throwing
    });

    test('should dispose without errors', () async {
      await authService.dispose();
      // Should complete without throwing
    });
  });
}
