import 'package:cribe/core/constants/ui_state.dart';
import 'package:cribe/ui/shared/view_models/base_view_model.dart';

class FakeHomeViewModel extends BaseViewModel {
  UiState _state = UiState.initial;
  String _errorMessage = '';

  UiState get state => _state;
  String get errorMessage => _errorMessage;
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

  void simulateError() {
    _errorMessage = 'Fake error for testing';
    _setState(UiState.error);
  }

  void _setState(UiState newState) {
    _state = newState;
    setLoading(newState == UiState.loading);
    if (newState == UiState.error) {
      setError(_errorMessage);
    } else {
      setError(null);
    }
  }
}
