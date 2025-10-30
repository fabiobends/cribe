import 'package:cribe/core/constants/ui_state.dart';
import 'package:cribe/ui/shared/view_models/base_view_model.dart';

class FakeSettingsViewModel extends BaseViewModel {
  FakeSettingsViewModel() {
    logger.info('FakeSettingsViewModel initialized');
  }

  UiState _state = UiState.initial;
  String _errorMessage = '';

  UiState get state => _state;
  String get errorMessage => _errorMessage;
  bool get hasError => _state == UiState.error;

  Future<void> logout() async {
    logger.info('Starting fake user logout process');
    _setState(UiState.loading);

    // Simulate async logout
    await Future.delayed(const Duration(seconds: 1));

    try {
      logger.info('Fake user logout successful');
      _setState(UiState.success);
    } catch (e) {
      logger.error('Fake logout failed', error: e);
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

  void _setState(UiState newState) {
    logger.debug('State changed: $_state -> $newState');
    _state = newState;
    setLoading(newState == UiState.loading);
    if (newState == UiState.error) {
      setError(_errorMessage);
    } else {
      setError(null);
    }
    notifyListeners();
  }
}
