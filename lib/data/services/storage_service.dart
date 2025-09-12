import 'package:cribe/core/constants/storage_keys.dart';
import 'package:cribe/core/logger/logger_mixins.dart';
import 'package:cribe/data/services/base_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService extends BaseService with ServiceLogger {
  SharedPreferences? _prefs;
  final _secureStorage = const FlutterSecureStorage();

  @override
  Future<void> init() async {
    logger.info('Initializing StorageService');
    try {
      _prefs = await SharedPreferences.getInstance();
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
      extra: {
        'key': key.name,
        'hasValue': value.isNotEmpty,
        'valueLength': value.length,
      },
    );
    return value;
  }

  Future<String> getSecureValue(SecureStorageKey key) async {
    logger.debug('Retrieving secure value', extra: {'key': key.name});
    try {
      final value = await _secureStorage.read(key: key.name) ?? '';
      logger.debug(
        'Retrieved secure value',
        extra: {
          'key': key.name,
          'hasValue': value.isNotEmpty,
          'valueLength': value.length,
        },
      );
      return value;
    } catch (e) {
      logger.error(
        'Failed to retrieve secure value',
        error: e,
        extra: {'key': key.name},
      );
      return '';
    }
  }

  Future<bool> setSecureValue(SecureStorageKey key, String value) async {
    logger.debug(
      'Setting secure value',
      extra: {
        'key': key.name,
        'valueLength': value.length,
      },
    );

    try {
      await _secureStorage.write(key: key.name, value: value);
      logger.debug('Secure value set successfully', extra: {'key': key.name});
      return true;
    } catch (e) {
      logger.error(
        'Failed to set secure value',
        error: e,
        extra: {'key': key.name},
      );
      return false;
    }
  }

  Future<bool> setValue(StorageKey key, String value) async {
    logger.debug(
      'Setting value',
      extra: {
        'key': key.name,
        'valueLength': value.length,
      },
    );

    try {
      final result = await _prefs?.setString(key.name, value) ?? false;
      if (result) {
        logger.debug('Value set successfully', extra: {'key': key.name});
      } else {
        logger.warn('Failed to set value', extra: {'key': key.name});
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
