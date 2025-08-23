import 'package:cribe/core/constants/api_path.dart';
import 'package:cribe/data/model/auth/login_request.dart';
import 'package:cribe/data/model/auth/login_response.dart';
import 'package:cribe/data/model/auth/register_request.dart';
import 'package:cribe/data/model/auth/register_response.dart';
import 'package:cribe/data/repositories/auth_repository.dart';
import 'package:cribe/data/services/api_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'auth_repository_test.mocks.dart';

@GenerateMocks([ApiService])
void main() {
  late AuthRepository authRepository;
  late MockApiService mockApiService;

  setUp(() {
    mockApiService = MockApiService();
    authRepository = AuthRepository(mockApiService);
  });

  group('AuthRepository', () {
    group('login', () {
      test(
          'should call ApiService.post with correct parameters and set tokens on success',
          () async {
        // Arrange
        const email = 'test@example.com';
        const password = 'password123';
        const accessToken = 'access_token_123';
        const refreshToken = 'refresh_token_123';

        final loginRequest = LoginRequest(email: email, password: password);

        final mockLoginResponse = LoginResponse(
          accessToken: accessToken,
          refreshToken: refreshToken,
        );

        final mockApiResponse = ApiResponse<LoginResponse>(
          data: mockLoginResponse,
          statusCode: 200,
          message: 'Success',
        );

        Future<ApiResponse<LoginResponse>> mockLoginCall() =>
            mockApiService.post<LoginResponse>(
              ApiPath.login,
              LoginResponse.fromJson,
              body: loginRequest.toJson(),
            );

        when(mockLoginCall()).thenAnswer((_) async => mockApiResponse);

        // Act
        final result = await authRepository.login(email, password);

        // Assert
        verify(mockLoginCall());
        verify(mockApiService.setTokens(any));

        expect(result, equals(mockApiResponse));
        expect(result.data.accessToken, equals(accessToken));
        expect(result.data.refreshToken, equals(refreshToken));
      });

      test('should throw exception when ApiService.post fails', () async {
        // Arrange
        const email = 'test@example.com';
        const password = 'password123';

        final loginRequest = LoginRequest(email: email, password: password);

        Future<ApiResponse<LoginResponse>> mockLoginCall() =>
            mockApiService.post<LoginResponse>(
              ApiPath.login,
              LoginResponse.fromJson,
              body: loginRequest.toJson(),
            );

        when(mockLoginCall())
            .thenThrow(ApiException('Login failed', statusCode: 401));

        // Act & Assert
        expect(
          () => authRepository.login(email, password),
          throwsA(isA<ApiException>()),
        );

        verify(mockLoginCall());
        verifyNever(mockApiService.setTokens(any));
      });
    });

    group('register', () {
      test('should call ApiService.post with correct parameters', () async {
        // Arrange
        const email = 'test@example.com';
        const password = 'password123';
        const firstName = 'John';
        const lastName = 'Doe';

        final registerRequest = RegisterRequest(
          email: email,
          password: password,
          firstName: firstName,
          lastName: lastName,
        );

        final mockRegisterResponse = RegisterResponse(
          id: 1,
        );

        final mockApiResponse = ApiResponse<RegisterResponse>(
          data: mockRegisterResponse,
          statusCode: 201,
          message: 'User created successfully',
        );

        Future<ApiResponse<RegisterResponse>> mockRegisterCall() =>
            mockApiService.post<RegisterResponse>(
              ApiPath.register,
              RegisterResponse.fromJson,
              body: registerRequest.toJson(),
            );

        when(mockRegisterCall()).thenAnswer((_) async => mockApiResponse);

        // Act
        final result = await authRepository.register(
          email,
          password,
          firstName,
          lastName,
        );

        // Assert
        verify(mockRegisterCall());

        expect(result, equals(mockApiResponse));
        expect(result.data.id, equals(mockRegisterResponse.id));
      });

      test('should throw exception when ApiService.post fails', () async {
        // Arrange
        const email = 'test@example.com';
        const password = 'password123';
        const firstName = 'John';
        const lastName = 'Doe';

        final registerRequest = RegisterRequest(
          email: email,
          password: password,
          firstName: firstName,
          lastName: lastName,
        );

        Future<ApiResponse<RegisterResponse>> mockRegisterCall() =>
            mockApiService.post<RegisterResponse>(
              ApiPath.register,
              RegisterResponse.fromJson,
              body: registerRequest.toJson(),
            );

        when(mockRegisterCall())
            .thenThrow(ApiException('Registration failed', statusCode: 400));

        // Act & Assert
        expect(
          () => authRepository.register(email, password, firstName, lastName),
          throwsA(isA<ApiException>()),
        );

        verify(mockRegisterCall());
      });
    });
  });
}
