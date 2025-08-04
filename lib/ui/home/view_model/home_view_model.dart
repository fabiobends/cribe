import 'package:cribe/core/enums/storage_key.dart';
import 'package:cribe/core/enums/ui_state.dart';
import 'package:cribe/data/repositories/auth_repository.dart';
import 'package:cribe/data/services/storage_service.dart';
import 'package:flutter/foundation.dart';

class HomeViewModel extends ChangeNotifier {
  final StorageService _storageService;

  HomeViewModel(AuthRepository authRepository, this._storageService);

  UiState _state = UiState.initial;
  String _errorMessage = '';

  UiState get state => _state;
  String get errorMessage => _errorMessage;

  bool get isLoading => _state == UiState.loading;
  bool get hasError => _state == UiState.error;

  Future<void> logout() async {
    _setState(UiState.loading);

    try {
      // Clear tokens from storage
      await _storageService.setValue(StorageKey.accessToken, '');
      await _storageService.setValue(StorageKey.refreshToken, '');

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
