import 'package:cribe/core/constants/ui_state.dart';
import 'package:cribe/data/model/auth/login_response.dart';
import 'package:cribe/data/repositories/auth_repository.dart';
import 'package:cribe/data/services/api_service.dart';
import 'package:cribe/ui/auth/view_model/login_view_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'login_view_model_test.mocks.dart';

@GenerateMocks([AuthRepository])
void main() {
  late LoginViewModel loginViewModel;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    loginViewModel = LoginViewModel(mockAuthRepository);
  });

  group('LoginViewModel', () {
    group('initial state', () {
      test('should have correct initial values', () {
        expect(loginViewModel.state, equals(UiState.initial));
        expect(loginViewModel.errorMessage, equals(''));
        expect(loginViewModel.isLoading, isFalse);
        expect(loginViewModel.hasError, isFalse);
      });
    });

    group('login', () {
      test('should update state to loading when login starts', () async {
        // Arrange
        const email = 'test@example.com';
        const password = 'password123';

        final mockResponse = ApiResponse<LoginResponse>(
          data: LoginResponse(
            accessToken: 'access_token',
            refreshToken: 'refresh_token',
          ),
          statusCode: 200,
        );

        Future<ApiResponse<LoginResponse>> mockLoginCall() =>
            mockAuthRepository.login(email, password);

        when(mockLoginCall()).thenAnswer((_) async => mockResponse);

        // Act
        final loginFuture = loginViewModel.login(email, password);

        // Assert - Check loading state immediately
        expect(loginViewModel.state, equals(UiState.loading));
        expect(loginViewModel.isLoading, isTrue);
        expect(loginViewModel.hasError, isFalse);

        // Wait for completion
        await loginFuture;
      });

      test('should update state to success when login succeeds', () async {
        // Arrange
        const email = 'test@example.com';
        const password = 'password123';

        final mockResponse = ApiResponse<LoginResponse>(
          data: LoginResponse(
            accessToken: 'access_token',
            refreshToken: 'refresh_token',
          ),
          statusCode: 200,
        );

        Future<ApiResponse<LoginResponse>> mockLoginCall() =>
            mockAuthRepository.login(email, password);

        when(mockLoginCall()).thenAnswer((_) async => mockResponse);

        // Act
        await loginViewModel.login(email, password);

        // Assert
        expect(loginViewModel.state, equals(UiState.success));
        expect(loginViewModel.isLoading, isFalse);
        expect(loginViewModel.hasError, isFalse);
        expect(loginViewModel.errorMessage, equals(''));
      });

      test('should call AuthRepository.login with correct parameters',
          () async {
        // Arrange
        const email = 'test@example.com';
        const password = 'password123';

        final mockResponse = ApiResponse<LoginResponse>(
          data: LoginResponse(
            accessToken: 'access_token',
            refreshToken: 'refresh_token',
          ),
          statusCode: 200,
        );

        Future<ApiResponse<LoginResponse>> mockLoginCall() =>
            mockAuthRepository.login(email, password);

        when(mockLoginCall()).thenAnswer((_) async => mockResponse);

        // Act
        await loginViewModel.login(email, password);

        // Assert
        verify(mockLoginCall());
      });

      test('should update state to error when login fails', () async {
        // Arrange
        const email = 'test@example.com';
        const password = 'password123';
        const errorMessage = 'Login failed: Invalid credentials';

        Future<ApiResponse<LoginResponse>> mockLoginCall() =>
            mockAuthRepository.login(email, password);

        when(mockLoginCall())
            .thenThrow(ApiException(errorMessage, statusCode: 401));

        // Act
        await loginViewModel.login(email, password);

        // Assert
        expect(loginViewModel.state, equals(UiState.error));
        expect(loginViewModel.isLoading, isFalse);
        expect(loginViewModel.hasError, isTrue);
        expect(loginViewModel.errorMessage, contains(errorMessage));
      });

      test('should notify listeners during state changes', () async {
        // Arrange
        const email = 'test@example.com';
        const password = 'password123';

        final mockResponse = ApiResponse<LoginResponse>(
          data: LoginResponse(
            accessToken: 'access_token',
            refreshToken: 'refresh_token',
          ),
          statusCode: 200,
        );

        Future<ApiResponse<LoginResponse>> mockLoginCall() =>
            mockAuthRepository.login(email, password);

        when(mockLoginCall()).thenAnswer((_) async => mockResponse);

        int notificationCount = 0;
        loginViewModel.addListener(() {
          notificationCount++;
        });

        // Act
        await loginViewModel.login(email, password);

        // Assert
        expect(notificationCount, equals(2)); // loading -> success
      });
    });

    group('clearError', () {
      test('should clear error state and reset to initial', () async {
        // Arrange - First set the view model to error state
        const email = 'test@example.com';
        const password = 'password123';
        const errorMessage = 'Login failed';

        Future<ApiResponse<LoginResponse>> mockLoginCall() =>
            mockAuthRepository.login(email, password);

        when(mockLoginCall())
            .thenThrow(ApiException(errorMessage, statusCode: 401));

        await loginViewModel.login(email, password);

        // Verify we're in error state
        expect(loginViewModel.state, equals(UiState.error));
        expect(loginViewModel.hasError, isTrue);

        // Act
        loginViewModel.clearError();

        // Assert
        expect(loginViewModel.state, equals(UiState.initial));
        expect(loginViewModel.hasError, isFalse);
        expect(loginViewModel.isLoading, isFalse);
      });

      test('should not change state if not in error state', () {
        // Arrange - ViewModel is in initial state
        expect(loginViewModel.state, equals(UiState.initial));

        // Act
        loginViewModel.clearError();

        // Assert - State should remain unchanged
        expect(loginViewModel.state, equals(UiState.initial));
      });

      test('should notify listeners when clearing error', () async {
        // Arrange - Set to error state first
        const email = 'test@example.com';
        const password = 'password123';

        Future<ApiResponse<LoginResponse>> mockLoginCall() =>
            mockAuthRepository.login(email, password);

        when(mockLoginCall())
            .thenThrow(ApiException('Login failed', statusCode: 401));

        await loginViewModel.login(email, password);

        int notificationCount = 0;
        loginViewModel.addListener(() {
          notificationCount++;
        });

        // Act
        loginViewModel.clearError();

        // Assert
        expect(notificationCount, equals(1));
      });
    });

    group('state getters', () {
      test('isLoading should return true only when state is loading', () async {
        // Arrange
        const email = 'test@example.com';
        const password = 'password123';

        // Initial state
        expect(loginViewModel.isLoading, isFalse);

        Future<ApiResponse<LoginResponse>> mockLoginCall() =>
            mockAuthRepository.login(email, password);

        when(mockLoginCall()).thenAnswer((_) async {
          await Future.delayed(const Duration(milliseconds: 100));
          return ApiResponse<LoginResponse>(
            data: LoginResponse(
              accessToken: 'access_token',
              refreshToken: 'refresh_token',
            ),
            statusCode: 200,
          );
        });

        // Act
        final loginFuture = loginViewModel.login(email, password);

        // Assert - Should be loading
        expect(loginViewModel.isLoading, isTrue);

        // Wait for completion
        await loginFuture;

        // Should no longer be loading
        expect(loginViewModel.isLoading, isFalse);
      });

      test('hasError should return true only when state is error', () async {
        // Initial state
        expect(loginViewModel.hasError, isFalse);

        Future<ApiResponse<LoginResponse>> mockLoginCall() =>
            mockAuthRepository.login(any, any);

        // Set to error state
        when(mockLoginCall()).thenThrow(ApiException('Error', statusCode: 400));

        await loginViewModel.login('test@test.com', 'password');
        expect(loginViewModel.hasError, isTrue);
      });
    });
  });
}
