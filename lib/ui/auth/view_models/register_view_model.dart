import 'package:cribe/core/constants/ui_state.dart';
import 'package:cribe/core/logger/logger_mixins.dart';
import 'package:cribe/data/repositories/auth_repository.dart';
import 'package:cribe/data/services/validation_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

class RegisterViewModel extends ChangeNotifier with ViewModelLogger {
  final AuthRepository _authRepository;

  RegisterViewModel(this._authRepository) {
    logger.info('RegisterViewModel initialized');
  }

  UiState _state = UiState.initial;
  String _errorMessage = '';

  UiState get state => _state;
  String get errorMessage => _errorMessage;

  bool get isLoading => _state == UiState.loading;
  bool get hasError => _state == UiState.error;

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
    _setState(UiState.loading);

    try {
      logger.debug('Calling auth repository register method');
      await _authRepository.register(
        email,
        password,
        firstName,
        lastName,
      );
      logger.info('User registration successful');
      _setState(UiState.success);
    } catch (e) {
      logger.error('Registration failed: ${e.toString()}');
      _errorMessage = e.toString();
      _setState(UiState.error);
    }
  }

  void clearError() {
    if (_state == UiState.error) {
      logger.debug('Clearing error state');
      _setState(UiState.initial);
    }
  }

  // For testing purposes
  void setLoading(bool loading) {
    logger.debug('Setting loading state: $loading');
    _setState(loading ? UiState.loading : UiState.initial);
  }

  void _setState(UiState newState) {
    logger.debug('State changed: $_state -> $newState');
    _state = newState;
    notifyListeners();
  }
}
