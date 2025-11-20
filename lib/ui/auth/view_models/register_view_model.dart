import 'package:cribe/data/repositories/auth_repository.dart';
import 'package:cribe/data/services/validation_service.dart';
import 'package:cribe/ui/shared/view_models/base_view_model.dart';

class RegisterViewModel extends BaseViewModel {
  final AuthRepository _authRepository;

  RegisterViewModel(this._authRepository) {
    logger.info('RegisterViewModel initialized');
  }

  String? validateFirstName(String? firstName) {
    final result = ValidationService.validateName(firstName ?? '');
    return result.isValid ? null : result.errorMessage;
  }

  String? validateLastName(String? lastName) {
    final result = ValidationService.validateName(lastName ?? '');
    return result.isValid ? null : result.errorMessage;
  }

  String? validateEmail(String? email) {
    final result = ValidationService.validateEmail(email ?? '');
    return result.isValid ? null : result.errorMessage;
  }

  String? validatePassword(String? password) {
    final result = ValidationService.validatePassword(password ?? '');
    return result.isValid ? null : result.errorMessage;
  }

  String? validateName(String name) {
    final result = ValidationService.validateName(name);
    return result.isValid ? null : result.errorMessage;
  }

  String? validateConfirmPassword(String? password, String? confirmPassword) {
    final result = ValidationService.validateConfirmPassword(
      password ?? '',
      confirmPassword ?? '',
    );
    return result.isValid ? null : result.errorMessage;
  }

  Future<void> register(
    String email,
    String password,
    String firstName,
    String lastName,
  ) async {
    logger.info('Starting user registration process');
    setLoading(true);

    try {
      logger.debug('Calling auth repository register method');
      await _authRepository.register(
        email,
        password,
        firstName,
        lastName,
      );
      logger.info('User registration successful');
    } catch (e) {
      final errorMessage = 'Registration failed';
      logger.error(errorMessage, error: e);
      setError(errorMessage);
    } finally {
      setLoading(false);
    }
  }
}
