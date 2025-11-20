import 'package:cribe/data/repositories/auth_repository.dart';
import 'package:cribe/data/services/validation_service.dart';
import 'package:cribe/ui/shared/view_models/base_view_model.dart';

class LoginViewModel extends BaseViewModel {
  final AuthRepository _authRepository;

  LoginViewModel(this._authRepository) {
    logger.info('LoginViewModel initialized');
  }

  String? validateEmail(String? email) {
    logger.debug('Validating email');
    final result = ValidationService.validateEmail(email ?? '');
    if (!result.isValid) {
      logger.warn(
        'Email validation failed',
        extra: {'error': result.errorMessage},
      );
    }
    return result.isValid ? null : result.errorMessage;
  }

  String? validatePassword(String? password) {
    logger.debug(
      'Validating password',
      extra: {'passwordLength': password?.length ?? 0},
    );
    final result = ValidationService.validateLoginPassword(password ?? '');
    if (!result.isValid) {
      logger.warn(
        'Password validation failed',
        extra: {'error': result.errorMessage},
      );
    }
    return result.isValid ? null : result.errorMessage;
  }

  Future<void> login(String email, String password) async {
    logger.info('Starting login process', extra: {'email': email});
    setLoading(true);

    try {
      await _authRepository.login(email, password);
      logger.info('Login successful');
      setSuccess(true);
    } catch (e) {
      final errorMessage = 'Login failed';
      logger.error(errorMessage, error: e, extra: {'email': email});
      setError(errorMessage);
    } finally {
      setLoading(false);
    }
  }
}
