import 'package:cribe/data/model/auth/login_response.dart';
import 'package:cribe/data/model/auth/register_response.dart';
import 'package:cribe/data/repositories/auth_repository.dart';
import 'package:cribe/data/services/api_service.dart';
import 'package:cribe/ui/auth/view_models/register_view_model.dart';

class FakeRegisterViewModel extends RegisterViewModel {
  FakeRegisterViewModel() : super(_FakeAuthRepo());

  @override
  Future<void> register(
    String email,
    String password,
    String firstName,
    String lastName,
  ) async {
    setLoading(true);
    await Future.delayed(const Duration(seconds: 2));

    if (firstName.isEmpty ||
        lastName.isEmpty ||
        email.isEmpty ||
        password.isEmpty) {
      setError('All fields are required');
      setLoading(false);
      return;
    }

    if (email == 'existing@example.com') {
      setError('Email already exists. Try a different email.');
      setLoading(false);
      return;
    }

    if (password.length < 8) {
      setError('Password must be at least 8 characters long');
      setLoading(false);
      return;
    }

    setSuccess(true);
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
