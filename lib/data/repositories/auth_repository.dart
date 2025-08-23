import 'package:cribe/core/constants/api_path.dart';
import 'package:cribe/data/model/auth/login_request.dart';
import 'package:cribe/data/model/auth/login_response.dart';
import 'package:cribe/data/model/auth/register_request.dart';
import 'package:cribe/data/model/auth/register_response.dart';
import 'package:cribe/data/services/api_service.dart';
import 'package:cribe/domain/models/auth_tokens.dart';

class AuthRepository {
  final ApiService _apiService;

  AuthRepository(this._apiService);

  Future<ApiResponse<LoginResponse>> login(
    String email,
    String password,
  ) async {
    final request = LoginRequest(email: email, password: password);
    final response = await _apiService.post(
      ApiPath.login,
      LoginResponse.fromJson,
      body: request.toJson(),
    );
    _apiService.setTokens(
      AuthTokens(
        accessToken: response.data.accessToken,
        refreshToken: response.data.refreshToken,
      ),
    );
    return response;
  }

  Future<ApiResponse<RegisterResponse>> register(
    String email,
    String password,
    String firstName,
    String lastName,
  ) async {
    final request = RegisterRequest(
      email: email,
      password: password,
      firstName: firstName,
      lastName: lastName,
    );
    return await _apiService.post(
      ApiPath.register,
      RegisterResponse.fromJson,
      body: request.toJson(),
    );
  }
}
