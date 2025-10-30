import 'package:cribe/core/constants/storage_keys.dart';
import 'package:cribe/core/constants/ui_state.dart';
import 'package:cribe/data/services/storage_service.dart';
import 'package:cribe/ui/settings/view_models/settings_view_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'settings_view_model_test.mocks.dart';

@GenerateMocks([StorageService])
void main() {
  late SettingsViewModel viewModel;
  late MockStorageService mockStorageService;

  setUp(() {
    mockStorageService = MockStorageService();
    viewModel = SettingsViewModel(mockStorageService);
  });

  group('SettingsViewModel', () {
    group('initial state', () {
      test('should have correct initial values', () {
        expect(viewModel.state, equals(UiState.initial));
        expect(viewModel.errorMessage, equals(''));
        expect(viewModel.isLoading, isFalse);
        expect(viewModel.hasError, isFalse);
      });
    });

    group('logout', () {
      test('should update state to loading when logout starts', () async {
        when(mockStorageService.setSecureValue(
          SecureStorageKey.accessToken,
          '',
        ),).thenAnswer((_) async => true);
        when(mockStorageService.setSecureValue(
          SecureStorageKey.refreshToken,
          '',
        ),).thenAnswer((_) async => true);

        final logoutFuture = viewModel.logout();

        expect(viewModel.state, equals(UiState.loading));
        expect(viewModel.isLoading, isTrue);
        expect(viewModel.hasError, isFalse);

        await logoutFuture;
      });

      test('should update state to success when logout succeeds', () async {
        when(mockStorageService.setSecureValue(
          SecureStorageKey.accessToken,
          '',
        ),).thenAnswer((_) async => true);
        when(mockStorageService.setSecureValue(
          SecureStorageKey.refreshToken,
          '',
        ),).thenAnswer((_) async => true);

        await viewModel.logout();

        expect(viewModel.state, equals(UiState.success));
        expect(viewModel.isLoading, isFalse);
        expect(viewModel.hasError, isFalse);
        expect(viewModel.errorMessage, equals(''));
      });

      test('should call StorageService.setSecureValue with correct parameters',
          () async {
        when(mockStorageService.setSecureValue(
          SecureStorageKey.accessToken,
          '',
        ),).thenAnswer((_) async => true);
        when(mockStorageService.setSecureValue(
          SecureStorageKey.refreshToken,
          '',
        ),).thenAnswer((_) async => true);

        await viewModel.logout();

        verify(mockStorageService.setSecureValue(
          SecureStorageKey.accessToken,
          '',
        ),).called(1);
        verify(mockStorageService.setSecureValue(
          SecureStorageKey.refreshToken,
          '',
        ),).called(1);
      });

      test('should update state to error when logout fails', () async {
        const errorMessage = 'Storage error';
        when(mockStorageService.setSecureValue(
          SecureStorageKey.accessToken,
          '',
        ),).thenThrow(Exception(errorMessage));

        await viewModel.logout();

        expect(viewModel.state, equals(UiState.error));
        expect(viewModel.isLoading, isFalse);
        expect(viewModel.hasError, isTrue);
        expect(viewModel.errorMessage, contains(errorMessage));
      });

      test('should notify listeners during state changes', () async {
        when(mockStorageService.setSecureValue(
          SecureStorageKey.accessToken,
          '',
        ),).thenAnswer((_) async => true);
        when(mockStorageService.setSecureValue(
          SecureStorageKey.refreshToken,
          '',
        ),).thenAnswer((_) async => true);

        int notificationCount = 0;
        viewModel.addListener(() {
          notificationCount++;
        });

        await viewModel.logout();

        expect(notificationCount, equals(2)); // loading -> success
      });
    });

    group('clearError', () {
      test('should clear error state and reset to initial', () async {
        when(mockStorageService.setSecureValue(
          SecureStorageKey.accessToken,
          '',
        ),).thenThrow(Exception('Storage error'));

        await viewModel.logout();

        expect(viewModel.state, equals(UiState.error));
        expect(viewModel.hasError, isTrue);

        viewModel.clearError();

        expect(viewModel.state, equals(UiState.initial));
        expect(viewModel.hasError, isFalse);
        expect(viewModel.isLoading, isFalse);
      });

      test('should not change state if not in error state', () {
        expect(viewModel.state, equals(UiState.initial));

        viewModel.clearError();

        expect(viewModel.state, equals(UiState.initial));
      });

      test('should notify listeners when clearing error', () async {
        when(mockStorageService.setSecureValue(
          SecureStorageKey.accessToken,
          '',
        ),).thenThrow(Exception('Storage error'));

        await viewModel.logout();

        int notificationCount = 0;
        viewModel.addListener(() {
          notificationCount++;
        });

        viewModel.clearError();

        expect(notificationCount, equals(1));
      });
    });

    group('state getters', () {
      test('isLoading should return true only when state is loading', () async {
        when(mockStorageService.setSecureValue(
          SecureStorageKey.accessToken,
          '',
        ),).thenAnswer((_) async {
          await Future.delayed(const Duration(milliseconds: 100));
          return true;
        });
        when(mockStorageService.setSecureValue(
          SecureStorageKey.refreshToken,
          '',
        ),).thenAnswer((_) async => true);

        expect(viewModel.isLoading, isFalse);

        final logoutFuture = viewModel.logout();

        expect(viewModel.isLoading, isTrue);

        await logoutFuture;

        expect(viewModel.isLoading, isFalse);
      });

      test('hasError should return true only when state is error', () async {
        expect(viewModel.hasError, isFalse);

        when(mockStorageService.setSecureValue(any, any))
            .thenThrow(Exception('Error'));

        await viewModel.logout();
        expect(viewModel.hasError, isTrue);
      });
    });

    group('BaseViewModel integration', () {
      test('setLoading should update loading state', () {
        viewModel.setLoading(true);
        expect(viewModel.isLoading, isTrue);

        viewModel.setLoading(false);
        expect(viewModel.isLoading, isFalse);
      });

      test('setError should update error state', () {
        viewModel.setError('Test error');
        expect(viewModel.error, equals('Test error'));

        viewModel.setError(null);
        expect(viewModel.error, isNull);
      });

      test('should notify listeners when setting loading state', () {
        int notificationCount = 0;
        viewModel.addListener(() {
          notificationCount++;
        });

        viewModel.setLoading(true);

        expect(notificationCount, equals(1));
      });
    });
  });
}
