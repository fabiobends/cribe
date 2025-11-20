import 'package:cribe/core/constants/storage_keys.dart';
import 'package:cribe/data/services/storage_service.dart';
import 'package:cribe/ui/shared/view_models/base_view_model.dart';

class SettingsViewModel extends BaseViewModel {
  final StorageService storageService;

  SettingsViewModel({required this.storageService}) {
    logger.info('SettingsViewModel initialized');
  }

  Future<void> logout() async {
    logger.info('Starting user logout process');
    setLoading(true);

    try {
      logger.debug('Clearing tokens from secure storage');
      // Clear tokens from storage
      await storageService.setSecureValue(SecureStorageKey.accessToken, '');
      await storageService.setSecureValue(SecureStorageKey.refreshToken, '');

      logger.info('User logout successful');
      setSuccess(true);
    } catch (e) {
      final errorMessage = 'Logout failed';
      logger.error(errorMessage, error: e);
      setError(errorMessage);
    } finally {
      logger.debug('Logout process completed');
      setLoading(false);
    }
  }
}
