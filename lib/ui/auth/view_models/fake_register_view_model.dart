import 'package:cribe/core/constants/ui_state.dart';
import 'package:flutter/foundation.dart';

class FakeRegisterViewModel extends ChangeNotifier {
  UiState _state = UiState.initial;
  String _errorMessage = '';

  UiState get state => _state;
  String get errorMessage => _errorMessage;

  bool get isLoading => _state == UiState.loading;
  bool get hasError => _state == UiState.error;

  Future<void> register(
    String firstName,
    String lastName,
    String email,
    String password,
  ) async {
    _setState(UiState.loading);

    // Simulate API call delay
    await Future.delayed(const Duration(seconds: 2));

    // Fake validation logic
    if (firstName.isEmpty ||
        lastName.isEmpty ||
        email.isEmpty ||
        password.isEmpty) {
      _errorMessage = 'All fields are required';
      _setState(UiState.error);
      return;
    }

    if (email == 'existing@example.com') {
      _errorMessage = 'Email already exists. Try a different email.';
      _setState(UiState.error);
      return;
    }

    if (password.length < 8) {
      _errorMessage = 'Password must be at least 8 characters long';
      _setState(UiState.error);
      return;
    }

    // Fake success
    _setState(UiState.success);
  }

  void clearError() {
    _errorMessage = '';
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
