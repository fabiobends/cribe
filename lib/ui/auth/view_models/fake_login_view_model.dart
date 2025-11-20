import 'package:cribe/data/model/auth/login_response.dart';
import 'package:cribe/data/model/auth/register_response.dart';
import 'package:cribe/data/repositories/auth_repository.dart';
import 'package:cribe/data/services/api_service.dart';
import 'package:cribe/ui/auth/view_models/login_view_model.dart';

class FakeLoginViewModel extends LoginViewModel {
  FakeLoginViewModel() : super(_FakeAuthRepo());

  @override
  Future<void> login(String email, String password) async {
    setLoading(true);
    await Future.delayed(const Duration(seconds: 2));

    if (email.isEmpty || password.isEmpty) {
      setError('Email and password are required');
      setLoading(false);
      return;
    }

    if (email == 'demo@example.com' && password == 'password') {
      setSuccess(true);
    } else {
      setError('Invalid credentials. Try demo@example.com / password');
    }
    setLoading(false);
  }
}

class _FakeAuthRepo extends AuthRepository {
  _FakeAuthRepo() : super(apiService: null);

  @override
  ApiService? get apiService => null;

  @override
  Future<ApiResponse<LoginResponse>> login(
    String email,
    String password,
  ) async =>
      throw UnimplementedError();

  @override
  Future<ApiResponse<RegisterResponse>> register(
    String email,
    String password,
    String firstName,
    String lastName,
  ) async =>
      throw UnimplementedError();

  @override
  Future<void> init() async {}

  @override
  Future<void> dispose() async {}
}
