import 'package:cribe/core/constants/ui_state.dart';
import 'package:cribe/data/model/auth/register_response.dart';
import 'package:cribe/data/repositories/auth_repository.dart';
import 'package:cribe/data/services/api_service.dart';
import 'package:cribe/ui/auth/view_models/register_view_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'register_view_model_test.mocks.dart';

@GenerateMocks([AuthRepository])
void main() {
  late RegisterViewModel registerViewModel;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    registerViewModel = RegisterViewModel(mockAuthRepository);
  });

  group('RegisterViewModel', () {
    group('initial state', () {
      test('should have correct initial values', () {
        expect(registerViewModel.state, equals(UiState.initial));
        expect(registerViewModel.errorMessage, equals(''));
        expect(registerViewModel.isLoading, isFalse);
        expect(registerViewModel.hasError, isFalse);
      });
    });

    group('register', () {
      test('should update state to loading when register starts', () async {
        // Arrange
        const email = 'test@example.com';
        const password = 'password123';
        const firstName = 'John';
        const lastName = 'Doe';

        final mockResponse = ApiResponse<RegisterResponse>(
          data: RegisterResponse(
            id: 123,
          ),
          statusCode: 201,
        );

        Future<ApiResponse<RegisterResponse>> mockRegisterCall() =>
            mockAuthRepository.register(email, password, firstName, lastName);

        when(mockRegisterCall()).thenAnswer((_) async => mockResponse);

        // Act
        final registerFuture =
            registerViewModel.register(email, password, firstName, lastName);

        // Assert - Check loading state immediately
        expect(registerViewModel.state, equals(UiState.loading));
        expect(registerViewModel.isLoading, isTrue);
        expect(registerViewModel.hasError, isFalse);

        // Wait for completion
        await registerFuture;
      });

      test('should update state to success when register succeeds', () async {
        // Arrange
        const email = 'test@example.com';
        const password = 'password123';
        const firstName = 'John';
        const lastName = 'Doe';

        final mockResponse = ApiResponse<RegisterResponse>(
          data: RegisterResponse(
            id: 123,
          ),
          statusCode: 201,
        );

        Future<ApiResponse<RegisterResponse>> mockRegisterCall() =>
            mockAuthRepository.register(email, password, firstName, lastName);

        when(mockRegisterCall()).thenAnswer((_) async => mockResponse);

        // Act
        await registerViewModel.register(email, password, firstName, lastName);

        // Assert
        expect(registerViewModel.state, equals(UiState.success));
        expect(registerViewModel.isLoading, isFalse);
        expect(registerViewModel.hasError, isFalse);
        expect(registerViewModel.errorMessage, equals(''));
      });

      test('should call AuthRepository.register with correct parameters',
          () async {
        // Arrange
        const email = 'test@example.com';
        const password = 'password123';
        const firstName = 'John';
        const lastName = 'Doe';

        final mockResponse = ApiResponse<RegisterResponse>(
          data: RegisterResponse(
            id: 123,
          ),
          statusCode: 201,
        );

        Future<ApiResponse<RegisterResponse>> mockRegisterCall() =>
            mockAuthRepository.register(email, password, firstName, lastName);

        when(mockRegisterCall()).thenAnswer((_) async => mockResponse);

        // Act
        await registerViewModel.register(email, password, firstName, lastName);

        // Assert
        verify(mockRegisterCall());
      });

      test('should update state to error when register fails', () async {
        // Arrange
        const email = 'test@example.com';
        const password = 'password123';
        const firstName = 'John';
        const lastName = 'Doe';
        const errorMessage = 'Registration failed: Email already exists';

        Future<ApiResponse<RegisterResponse>> mockRegisterCall() =>
            mockAuthRepository.register(email, password, firstName, lastName);

        when(mockRegisterCall())
            .thenThrow(ApiException(errorMessage, statusCode: 409));

        // Act
        await registerViewModel.register(email, password, firstName, lastName);

        // Assert
        expect(registerViewModel.state, equals(UiState.error));
        expect(registerViewModel.isLoading, isFalse);
        expect(registerViewModel.hasError, isTrue);
        expect(registerViewModel.errorMessage, contains(errorMessage));
      });

      test('should notify listeners during state changes', () async {
        // Arrange
        const email = 'test@example.com';
        const password = 'password123';
        const firstName = 'John';
        const lastName = 'Doe';

        final mockResponse = ApiResponse<RegisterResponse>(
          data: RegisterResponse(
            id: 123,
          ),
          statusCode: 201,
        );

        Future<ApiResponse<RegisterResponse>> mockRegisterCall() =>
            mockAuthRepository.register(email, password, firstName, lastName);

        when(mockRegisterCall()).thenAnswer((_) async => mockResponse);

        int notificationCount = 0;
        registerViewModel.addListener(() {
          notificationCount++;
        });

        // Act
        await registerViewModel.register(email, password, firstName, lastName);

        // Assert
        expect(notificationCount, equals(2)); // loading -> success
      });
    });

    group('clearError', () {
      test('should clear error state and reset to initial', () async {
        // Arrange - First set the view model to error state
        const email = 'test@example.com';
        const password = 'password123';
        const firstName = 'John';
        const lastName = 'Doe';
        const errorMessage = 'Registration failed';

        Future<ApiResponse<RegisterResponse>> mockRegisterCall() =>
            mockAuthRepository.register(email, password, firstName, lastName);

        when(mockRegisterCall())
            .thenThrow(ApiException(errorMessage, statusCode: 400));

        await registerViewModel.register(email, password, firstName, lastName);

        // Verify we're in error state
        expect(registerViewModel.state, equals(UiState.error));
        expect(registerViewModel.hasError, isTrue);

        // Act
        registerViewModel.clearError();

        // Assert
        expect(registerViewModel.state, equals(UiState.initial));
        expect(registerViewModel.hasError, isFalse);
        expect(registerViewModel.isLoading, isFalse);
      });

      test('should not change state if not in error state', () {
        // Arrange - ViewModel is in initial state
        expect(registerViewModel.state, equals(UiState.initial));

        // Act
        registerViewModel.clearError();

        // Assert - State should remain unchanged
        expect(registerViewModel.state, equals(UiState.initial));
      });

      test('should notify listeners when clearing error', () async {
        // Arrange - Set to error state first
        const email = 'test@example.com';
        const password = 'password123';
        const firstName = 'John';
        const lastName = 'Doe';

        Future<ApiResponse<RegisterResponse>> mockRegisterCall() =>
            mockAuthRepository.register(email, password, firstName, lastName);

        when(mockRegisterCall())
            .thenThrow(ApiException('Registration failed', statusCode: 400));

        await registerViewModel.register(email, password, firstName, lastName);

        int notificationCount = 0;
        registerViewModel.addListener(() {
          notificationCount++;
        });

        // Act
        registerViewModel.clearError();

        // Assert
        expect(notificationCount, equals(1));
      });
    });

    group('state getters', () {
      test('isLoading should return true only when state is loading', () async {
        // Arrange
        const email = 'test@example.com';
        const password = 'password123';
        const firstName = 'John';
        const lastName = 'Doe';

        // Initial state
        expect(registerViewModel.isLoading, isFalse);

        Future<ApiResponse<RegisterResponse>> mockRegisterCall() =>
            mockAuthRepository.register(email, password, firstName, lastName);

        when(mockRegisterCall()).thenAnswer((_) async {
          await Future.delayed(const Duration(milliseconds: 100));
          return ApiResponse<RegisterResponse>(
            data: RegisterResponse(
              id: 123,
            ),
            statusCode: 201,
          );
        });

        // Act
        final registerFuture =
            registerViewModel.register(email, password, firstName, lastName);

        // Assert - Should be loading
        expect(registerViewModel.isLoading, isTrue);

        // Wait for completion
        await registerFuture;

        // Should no longer be loading
        expect(registerViewModel.isLoading, isFalse);
      });

      test('hasError should return true only when state is error', () async {
        // Initial state
        expect(registerViewModel.hasError, isFalse);

        Future<ApiResponse<RegisterResponse>> mockRegisterCall() =>
            mockAuthRepository.register(any, any, any, any);

        // Set to error state
        when(mockRegisterCall())
            .thenThrow(ApiException('Error', statusCode: 400));

        await registerViewModel.register(
          'test@test.com',
          'password',
          'John',
          'Doe',
        );
        expect(registerViewModel.hasError, isTrue);
      });
    });

    group('setLoading', () {
      test('should set loading state to true', () {
        // Act
        registerViewModel.setLoading(true);

        // Assert
        expect(registerViewModel.isLoading, isTrue);
      });

      test('should set loading state to false', () {
        // Arrange - First set to loading
        registerViewModel.setLoading(true);
        expect(registerViewModel.isLoading, isTrue);

        // Act
        registerViewModel.setLoading(false);

        // Assert
        expect(registerViewModel.state, equals(UiState.initial));
        expect(registerViewModel.isLoading, isFalse);
      });

      test('should notify listeners when setting loading state', () {
        int notificationCount = 0;
        registerViewModel.addListener(() {
          notificationCount++;
        });

        // Act
        registerViewModel.setLoading(true);

        // Assert
        expect(notificationCount, equals(1));
      });
    });
  });
}
