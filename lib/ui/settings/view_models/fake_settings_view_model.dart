import 'package:cribe/core/constants/storage_keys.dart';
import 'package:cribe/data/services/storage_service.dart';
import 'package:cribe/ui/settings/view_models/settings_view_model.dart';

class FakeSettingsViewModel extends SettingsViewModel {
  FakeSettingsViewModel() : super(storageService: _FakeStorageService());

  @override
  Future<void> logout() async {
    logger.info('Starting fake user logout process');
    setLoading(true);
    await Future.delayed(const Duration(seconds: 1));

    try {
      logger.info('Fake user logout successful');
      setSuccess(true);
    } catch (e) {
      final errorMessage = 'Fake logout failed';
      logger.error(errorMessage, error: e);
      setError(errorMessage);
    } finally {
      setLoading(false);
    }
  }
}

class _FakeStorageService extends StorageService {
  @override
  Future<void> init() async {}

  @override
  Future<void> dispose() async {}

  @override
  String getValue(StorageKey key) => '';

  @override
  Future<String> getSecureValue(SecureStorageKey key) async => '';

  @override
  Future<bool> setSecureValue(SecureStorageKey key, String value) async => true;

  @override
  Future<bool> setValue(StorageKey key, String value) async => true;
}
