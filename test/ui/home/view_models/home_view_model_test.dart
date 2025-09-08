import 'package:cribe/core/constants/storage_keys.dart';
import 'package:cribe/core/constants/ui_state.dart';
import 'package:cribe/data/repositories/auth_repository.dart';
import 'package:cribe/data/services/storage_service.dart';
import 'package:cribe/ui/home/view_models/home_view_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'home_view_model_test.mocks.dart';

@GenerateMocks([AuthRepository, StorageService])
void main() {
  late HomeViewModel homeViewModel;
  late MockAuthRepository mockAuthRepository;
  late MockStorageService mockStorageService;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    mockStorageService = MockStorageService();
    homeViewModel = HomeViewModel(mockAuthRepository, mockStorageService);
  });

  group('HomeViewModel', () {
    group('initial state', () {
      test('should have correct initial values', () {
        expect(homeViewModel.state, equals(UiState.initial));
        expect(homeViewModel.errorMessage, equals(''));
        expect(homeViewModel.isLoading, isFalse);
        expect(homeViewModel.hasError, isFalse);
      });
    });

    group('logout', () {
      test('should update state to loading when logout starts', () async {
        // Arrange
        when(
          mockStorageService.setSecureValue(
            SecureStorageKey.accessToken,
            '',
          ),
        ).thenAnswer((_) async => true);
        when(
          mockStorageService.setSecureValue(
            SecureStorageKey.refreshToken,
            '',
          ),
        ).thenAnswer((_) async => true);

        // Act
        final logoutFuture = homeViewModel.logout();

        // Assert - Check loading state immediately
        expect(homeViewModel.state, equals(UiState.loading));
        expect(homeViewModel.isLoading, isTrue);
        expect(homeViewModel.hasError, isFalse);

        // Wait for completion
        await logoutFuture;
      });

      test('should update state to success when logout succeeds', () async {
        // Arrange
        when(
          mockStorageService.setSecureValue(
            SecureStorageKey.accessToken,
            '',
          ),
        ).thenAnswer((_) async => true);
        when(
          mockStorageService.setSecureValue(
            SecureStorageKey.refreshToken,
            '',
          ),
        ).thenAnswer((_) async => true);

        // Act
        await homeViewModel.logout();

        // Assert
        expect(homeViewModel.state, equals(UiState.success));
        expect(homeViewModel.isLoading, isFalse);
        expect(homeViewModel.hasError, isFalse);
        expect(homeViewModel.errorMessage, equals(''));
      });

      test('should call StorageService.setValue with correct parameters',
          () async {
        // Arrange
        when(
          mockStorageService.setSecureValue(
            SecureStorageKey.accessToken,
            '',
          ),
        ).thenAnswer((_) async => true);
        when(
          mockStorageService.setSecureValue(
            SecureStorageKey.refreshToken,
            '',
          ),
        ).thenAnswer((_) async => true);

        // Act
        await homeViewModel.logout();

        // Assert
        verify(
          mockStorageService.setSecureValue(SecureStorageKey.accessToken, ''),
        ).called(1);
        verify(
          mockStorageService.setSecureValue(SecureStorageKey.refreshToken, ''),
        ).called(1);
      });

      test('should update state to error when logout fails', () async {
        // Arrange
        const errorMessage = 'Logout failed: Storage error';
        when(
          mockStorageService.setSecureValue(
            SecureStorageKey.accessToken,
            '',
          ),
        ).thenThrow(Exception(errorMessage));

        // Act
        await homeViewModel.logout();

        // Assert
        expect(homeViewModel.state, equals(UiState.error));
        expect(homeViewModel.isLoading, isFalse);
        expect(homeViewModel.hasError, isTrue);
        expect(homeViewModel.errorMessage, contains(errorMessage));
      });

      test('should notify listeners during state changes', () async {
        // Arrange
        when(
          mockStorageService.setSecureValue(
            SecureStorageKey.accessToken,
            '',
          ),
        ).thenAnswer((_) async => true);
        when(
          mockStorageService.setSecureValue(
            SecureStorageKey.refreshToken,
            '',
          ),
        ).thenAnswer((_) async => true);

        int notificationCount = 0;
        homeViewModel.addListener(() {
          notificationCount++;
        });

        // Act
        await homeViewModel.logout();

        // Assert
        expect(notificationCount, equals(2)); // loading -> success
      });
    });

    group('clearError', () {
      test('should clear error state and reset to initial', () async {
        // Arrange - First set the view model to error state
        when(
          mockStorageService.setSecureValue(
            SecureStorageKey.accessToken,
            '',
          ),
        ).thenThrow(Exception('Storage error'));

        await homeViewModel.logout();

        // Verify we're in error state
        expect(homeViewModel.state, equals(UiState.error));
        expect(homeViewModel.hasError, isTrue);

        // Act
        homeViewModel.clearError();

        // Assert
        expect(homeViewModel.state, equals(UiState.initial));
        expect(homeViewModel.hasError, isFalse);
        expect(homeViewModel.isLoading, isFalse);
      });

      test('should not change state if not in error state', () {
        // Arrange - ViewModel is in initial state
        expect(homeViewModel.state, equals(UiState.initial));

        // Act
        homeViewModel.clearError();

        // Assert - State should remain unchanged
        expect(homeViewModel.state, equals(UiState.initial));
      });

      test('should notify listeners when clearing error', () async {
        // Arrange - Set to error state first
        when(
          mockStorageService.setSecureValue(
            SecureStorageKey.accessToken,
            '',
          ),
        ).thenThrow(Exception('Storage error'));

        await homeViewModel.logout();

        int notificationCount = 0;
        homeViewModel.addListener(() {
          notificationCount++;
        });

        // Act
        homeViewModel.clearError();

        // Assert
        expect(notificationCount, equals(1));
      });
    });

    group('state getters', () {
      test('isLoading should return true only when state is loading', () async {
        // Arrange
        when(
          mockStorageService.setSecureValue(
            SecureStorageKey.accessToken,
            '',
          ),
        ).thenAnswer((_) async {
          await Future.delayed(const Duration(milliseconds: 100));
          return true;
        });
        when(
          mockStorageService.setSecureValue(
            SecureStorageKey.refreshToken,
            '',
          ),
        ).thenAnswer((_) async => true);

        // Initial state
        expect(homeViewModel.isLoading, isFalse);

        // Act
        final logoutFuture = homeViewModel.logout();

        // Assert - Should be loading
        expect(homeViewModel.isLoading, isTrue);

        // Wait for completion
        await logoutFuture;

        // Should no longer be loading
        expect(homeViewModel.isLoading, isFalse);
      });

      test('hasError should return true only when state is error', () async {
        // Initial state
        expect(homeViewModel.hasError, isFalse);

        // Set to error state
        when(mockStorageService.setValue(any, any))
            .thenThrow(Exception('Error'));

        await homeViewModel.logout();
        expect(homeViewModel.hasError, isTrue);
      });
    });

    group('setLoading', () {
      test('should set loading state to true', () {
        // Act
        homeViewModel.setLoading(true);

        // Assert
        expect(homeViewModel.state, equals(UiState.loading));
        expect(homeViewModel.isLoading, isTrue);
      });

      test('should set loading state to false', () {
        // Arrange - First set to loading
        homeViewModel.setLoading(true);
        expect(homeViewModel.isLoading, isTrue);

        // Act
        homeViewModel.setLoading(false);

        // Assert
        expect(homeViewModel.state, equals(UiState.initial));
        expect(homeViewModel.isLoading, isFalse);
      });

      test('should notify listeners when setting loading state', () {
        int notificationCount = 0;
        homeViewModel.addListener(() {
          notificationCount++;
        });

        // Act
        homeViewModel.setLoading(true);

        // Assert
        expect(notificationCount, equals(1));
      });
    });
  });
}
