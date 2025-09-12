import 'package:cribe/core/constants/storage_keys.dart';
import 'package:cribe/core/constants/ui_state.dart';
import 'package:cribe/core/logger/logger_mixins.dart';
import 'package:cribe/data/repositories/auth_repository.dart';
import 'package:cribe/data/services/storage_service.dart';
import 'package:flutter/foundation.dart';

class HomeViewModel extends ChangeNotifier with ViewModelLogger {
  final StorageService _storageService;

  HomeViewModel(AuthRepository authRepository, this._storageService) {
    logger.info('HomeViewModel initialized');
  }

  UiState _state = UiState.initial;
  String _errorMessage = '';

  UiState get state => _state;
  String get errorMessage => _errorMessage;

  bool get isLoading => _state == UiState.loading;
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
      logger.error('Logout failed: ${e.toString()}');
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
