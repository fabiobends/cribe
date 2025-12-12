import 'package:cribe/data/models/auth/login_response.dart';
import 'package:cribe/data/repositories/auth_repository.dart';
import 'package:cribe/data/services/api_service.dart';
import 'package:cribe/ui/auth/view_models/login_view_model.dart';
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
        expect(loginViewModel.isLoading, isFalse);
        expect(loginViewModel.error, isNull);
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
        expect(loginViewModel.isLoading, isTrue);
        expect(loginViewModel.error, isNull);

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
        expect(loginViewModel.isLoading, isFalse);
        expect(loginViewModel.error, isNull);
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
        const errorMessage = 'Login failed';

        Future<ApiResponse<LoginResponse>> mockLoginCall() =>
            mockAuthRepository.login(email, password);

        when(mockLoginCall())
            .thenThrow(ApiException(errorMessage, statusCode: 401));

        // Act
        await loginViewModel.login(email, password);

        // Assert
        expect(loginViewModel.isLoading, isFalse);
        expect(loginViewModel.error, contains(errorMessage));
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
        expect(
          notificationCount,
          equals(3),
        );
      });
    });
  });
}
