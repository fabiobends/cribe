import 'package:cribe/core/constants/ui_state.dart';
import 'package:cribe/data/repositories/auth_repository.dart';
import 'package:cribe/data/services/validation_service.dart';
import 'package:flutter/foundation.dart';

class LoginViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;

  LoginViewModel(this._authRepository);

  UiState _state = UiState.initial;
  String _errorMessage = '';

  UiState get state => _state;
  String get errorMessage => _errorMessage;

  bool get isLoading => _state == UiState.loading;
  bool get hasError => _state == UiState.error;

  String? validateEmail(String? email) {
    final result = ValidationService.validateEmail(email ?? '');
    return result.isValid ? null : result.errorMessage;
  }

  String? validatePassword(String? password) {
    final result = ValidationService.validateLoginPassword(password ?? '');
    return result.isValid ? null : result.errorMessage;
  }

  Future<void> login(String email, String password) async {
    _setState(UiState.loading);

    try {
      await _authRepository.login(email, password);
      _setState(UiState.success);
    } catch (e) {
      _errorMessage = e.toString();
      _setState(UiState.error);
    }
  }

  void clearError() {
    if (_state == UiState.error) {
      _setState(UiState.initial);
    }
  }

  // For testing purposes
  void setLoading(bool loading) {
    _setState(loading ? UiState.loading : UiState.initial);
  }

  void _setState(UiState newState) {
    _state = newState;
    notifyListeners();
  }
}
