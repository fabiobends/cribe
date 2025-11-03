import 'package:cribe/core/constants/storage_keys.dart';
import 'package:cribe/data/services/storage_service.dart';
import 'package:cribe/ui/auth/widgets/auth_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

import 'auth_screen_test.mocks.dart';

@GenerateMocks([StorageService])
void main() {
  late MockStorageService mockStorageService;

  setUp(() {
    mockStorageService = MockStorageService();
  });

  Widget createAuthScreen() {
    return MaterialApp(
      home: Provider<StorageService>.value(
        value: mockStorageService,
        child: const AuthScreen(),
      ),
    );
  }

  group('AuthScreen', () {
    testWidgets('should show loading indicator initially - happy path',
        (tester) async {
      when(mockStorageService.getSecureValue(SecureStorageKey.accessToken))
          .thenAnswer((_) async => 'token');

      await tester.pumpWidget(createAuthScreen());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      verify(mockStorageService.getSecureValue(SecureStorageKey.accessToken))
          .called(1);
    });

    testWidgets('should call storage service on init - unhappy path',
        (tester) async {
      when(mockStorageService.getSecureValue(SecureStorageKey.accessToken))
          .thenAnswer((_) async => '');

      await tester.pumpWidget(createAuthScreen());

      verify(mockStorageService.getSecureValue(SecureStorageKey.accessToken))
          .called(1);
    });

    testWidgets('should handle storage errors - unhappy path', (tester) async {
      when(mockStorageService.getSecureValue(SecureStorageKey.accessToken))
          .thenThrow(Exception('Storage error'));

      await tester.pumpWidget(createAuthScreen());

      verify(mockStorageService.getSecureValue(SecureStorageKey.accessToken))
          .called(1);
    });
  });
}
