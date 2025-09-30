import 'package:cribe/core/constants/storage_keys.dart';
import 'package:cribe/data/services/base_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesProvider {
  Future<SharedPreferences> getInstance() {
    return SharedPreferences.getInstance();
  }
}

class StorageService extends BaseService {
  SharedPreferences? _prefs;
  final _secureStorage = const FlutterSecureStorage();
  final SharedPreferencesProvider _prefsProvider;

  StorageService({SharedPreferencesProvider? prefsProvider})
      : _prefsProvider = prefsProvider ?? SharedPreferencesProvider();

  @override
  Future<void> init() async {
    try {
      logger.info('Initializing StorageService');
      _prefs = await _prefsProvider.getInstance();
      logger.info('StorageService initialized successfully');
    } catch (e) {
      logger.error('Failed to initialize StorageService', error: e);
      rethrow;
    }
  }

  @override
  Future<void> dispose() async {
    logger.info('Disposing StorageService');
    _prefs = null;
  }

  String getValue(StorageKey key) {
    final value = _prefs?.getString(key.name) ?? '';
    logger.debug(
      'Retrieved value from storage',
      extra: {key.name: value.isEmpty ? '<empty>' : value},
    );
    return value;
  }

  Future<String> getSecureValue(SecureStorageKey key) async {
    try {
      logger
          .debug('Retrieving secure value', extra: {key.name: 'requesting...'});

      final value = await _secureStorage.read(key: key.name) ?? '';
      logger.debug(
        'Retrieved secure value',
        extra: {key.name: value.isEmpty ? '<empty>' : value},
      );
      return value;
    } catch (e) {
      logger.error(
        'Failed to retrieve secure value',
        error: e,
        extra: {key.name: 'failed'},
      );
      return '';
    }
  }

  Future<bool> setSecureValue(SecureStorageKey key, String value) async {
    try {
      logger.debug(
        'Setting secure value',
        extra: {key.name: value.isEmpty ? '<empty>' : value},
      );

      await _secureStorage.write(key: key.name, value: value);
      logger.debug('Secure value set successfully', extra: {key.name: 'saved'});
      return true;
    } catch (e) {
      logger.error(
        'Failed to set secure value',
        error: e,
        extra: {key.name: 'failed'},
      );
      return false;
    }
  }

  Future<bool> setValue(StorageKey key, String value) async {
    try {
      logger.debug(
        'Setting value',
        extra: {key.name: value.isEmpty ? '<empty>' : value},
      );

      final result = await _prefs?.setString(key.name, value) ?? false;
      if (result) {
        logger.debug('Value set successfully', extra: {key.name: 'saved'});
      } else {
        logger.warn('Failed to set value', extra: {key.name: 'failed'});
      }
      return result;
    } catch (e) {
      logger.error(
        'Exception while setting value',
        error: e,
        extra: {'key': key.name},
      );
      return false;
    }
  }
}
