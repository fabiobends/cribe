import 'package:cribe/core/constants/api_path.dart';
import 'package:cribe/core/logger/logger_mixins.dart';
import 'package:cribe/data/model/auth/login_request.dart';
import 'package:cribe/data/model/auth/login_response.dart';
import 'package:cribe/data/model/auth/register_request.dart';
import 'package:cribe/data/model/auth/register_response.dart';
import 'package:cribe/data/services/api_service.dart';

class AuthRepository with RepositoryLogger {
  final ApiService _apiService;

  AuthRepository(this._apiService) {
    logger.info('AuthRepository initialized');
  }

  Future<ApiResponse<LoginResponse>> login(
    String email,
    String password,
  ) async {
    logger.info('Starting login request', extra: {'email': email});

    try {
      final request = LoginRequest(email: email, password: password);
      final response = await _apiService.post(
        ApiPath.login,
        LoginResponse.fromJson,
        body: request.toJson(),
      );

      logger.info('Login request successful');

      _apiService.setTokens(
        LoginResponse(
          accessToken: response.data.accessToken,
          refreshToken: response.data.refreshToken,
        ),
      );

      logger.debug('Tokens set in API service');
      return response;
    } catch (e) {
      logger.error('Login request failed', error: e, extra: {'email': email});
      rethrow;
    }
  }

  Future<ApiResponse<RegisterResponse>> register(
    String email,
    String password,
    String firstName,
    String lastName,
  ) async {
    logger.info(
      'Starting register request',
      extra: {
        'email': email,
        'firstName': firstName,
        'lastName': lastName,
      },
    );

    try {
      final request = RegisterRequest(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
      );

      final response = await _apiService.post(
        ApiPath.register,
        RegisterResponse.fromJson,
        body: request.toJson(),
      );

      logger.info('Register request successful');
      return response;
    } catch (e) {
      logger.error(
        'Register request failed',
        error: e,
        extra: {
          'email': email,
          'firstName': firstName,
          'lastName': lastName,
        },
      );
      rethrow;
    }
  }
}
