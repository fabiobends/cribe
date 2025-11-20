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
        expect(registerViewModel.isLoading, isFalse);
        expect(registerViewModel.error, isNull);
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
        expect(registerViewModel.isLoading, isTrue);
        expect(registerViewModel.error, isNull);

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
        expect(registerViewModel.isLoading, isFalse);
        expect(registerViewModel.error, isNull);
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
        const errorMessage = 'Registration failed';

        Future<ApiResponse<RegisterResponse>> mockRegisterCall() =>
            mockAuthRepository.register(email, password, firstName, lastName);

        when(mockRegisterCall())
            .thenThrow(ApiException(errorMessage, statusCode: 409));

        // Act
        await registerViewModel.register(email, password, firstName, lastName);

        // Assert
        expect(registerViewModel.isLoading, isFalse);
        expect(registerViewModel.error, equals(errorMessage));
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
  });
}
