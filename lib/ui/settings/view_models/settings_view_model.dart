import 'package:cribe/core/constants/storage_keys.dart';
import 'package:cribe/core/constants/ui_state.dart';
import 'package:cribe/data/services/storage_service.dart';
import 'package:cribe/ui/shared/view_models/base_view_model.dart';

class SettingsViewModel extends BaseViewModel {
  final StorageService _storageService;

  SettingsViewModel(this._storageService) {
    logger.info('SettingsViewModel initialized');
  }

  UiState _state = UiState.initial;
  String _errorMessage = '';

  UiState get state => _state;
  String get errorMessage => _errorMessage;
  bool get hasError => _state == UiState.error;

  Future<void> logout() async {
    logger.info('Starting user logout process');
    _setState(UiState.loading);

    try {
      logger.debug('Clearing tokens from secure storage');
      // Clear tokens from storage
      await _storageService.setSecureValue(SecureStorageKey.accessToken, '');
      await _storageService.setSecureValue(SecureStorageKey.refreshToken, '');

      logger.info('User logout successful');
      _setState(UiState.success);
    } catch (e) {
      logger.error('Logout failed', error: e);
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
  }
}
