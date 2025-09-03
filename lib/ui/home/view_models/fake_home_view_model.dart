import 'package:cribe/core/constants/ui_state.dart';
import 'package:flutter/foundation.dart';

class FakeHomeViewModel extends ChangeNotifier {
  UiState _state = UiState.initial;
  String _errorMessage = '';

  UiState get state => _state;
  String get errorMessage => _errorMessage;

  bool get isLoading => _state == UiState.loading;
  bool get hasError => _state == UiState.error;

  Future<void> logout() async {
    _setState(UiState.loading);

    // Simulate logout delay
    await Future.delayed(const Duration(seconds: 1));

    // Fake logout logic - always succeeds in storybook
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

  void simulateError() {
    _errorMessage = 'Fake error for testing';
    _setState(UiState.error);
  }

  void _setState(UiState newState) {
    _state = newState;
    notifyListeners();
  }
}
