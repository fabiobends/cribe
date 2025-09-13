import 'package:cribe/core/constants/ui_state.dart';
import 'package:cribe/data/repositories/auth_repository.dart';
import 'package:cribe/data/services/validation_service.dart';
import 'package:cribe/ui/shared/view_models/base_view_model.dart';

class LoginViewModel extends BaseViewModel {
  final AuthRepository _authRepository;

  LoginViewModel(this._authRepository) {
    logger.info('LoginViewModel initialized');
  }

  UiState _state = UiState.initial;
  String _errorMessage = '';

  UiState get state => _state;
  String get errorMessage => _errorMessage;
  bool get hasError => _state == UiState.error;

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
    _setState(UiState.loading);

    try {
      await _authRepository.login(email, password);
      logger.info('Login successful');
      _setState(UiState.success);
    } catch (e) {
      logger.error('Login failed', error: e, extra: {'email': email});
      _errorMessage = e.toString();
      _setState(UiState.error);
    }
  }

  void clearError() {
    logger.debug('Clearing error state');
    if (_state == UiState.error) {
      _setState(UiState.initial);
    }
  }

  void _setState(UiState newState) {
    logger.debug(
      'State transition',
      extra: {'from': _state.name, 'to': newState.name},
    );
    _state = newState;
    setLoading(newState == UiState.loading);
    if (newState == UiState.error) {
      setError(_errorMessage);
    } else {
      setError(null);
    }
  }
}
