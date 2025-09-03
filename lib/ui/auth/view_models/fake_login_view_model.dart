import 'package:cribe/core/constants/ui_state.dart';
import 'package:flutter/foundation.dart';

class FakeLoginViewModel extends ChangeNotifier {
  UiState _state = UiState.initial;
  String _errorMessage = '';

  UiState get state => _state;
  String get errorMessage => _errorMessage;

  bool get isLoading => _state == UiState.loading;
  bool get hasError => _state == UiState.error;

  Future<void> login(String email, String password) async {
    _setState(UiState.loading);

    // Simulate API call delay
    await Future.delayed(const Duration(seconds: 2));

    // Fake validation logic
    if (email.isEmpty || password.isEmpty) {
      _errorMessage = 'Email and password are required';
      _setState(UiState.error);
      return;
    }

    if (email == 'demo@example.com' && password == 'password') {
      _setState(UiState.success);
    } else {
      _errorMessage = 'Invalid credentials. Try demo@example.com / password';
      _setState(UiState.error);
    }
  }

  void clearError() {
    _errorMessage = '';
    if (_state == UiState.error) {
      _setState(UiState.initial);
    }
  }

  void _setState(UiState newState) {
    _state = newState;
    notifyListeners();
  }
}
