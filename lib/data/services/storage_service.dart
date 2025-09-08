import 'package:cribe/core/constants/storage_keys.dart';
import 'package:cribe/data/services/base_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService extends BaseService {
  SharedPreferences? _prefs;
  final _secureStorage = const FlutterSecureStorage();

  @override
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  @override
  Future<void> dispose() async {
    _prefs = null;
  }

  String getValue(StorageKey key) {
    return _prefs?.getString(key.name) ?? '';
  }

  Future<String> getSecureValue(SecureStorageKey key) async {
    return await _secureStorage.read(key: key.name) ?? '';
  }

  Future<bool> setSecureValue(SecureStorageKey key, String value) async {
    try {
      await _secureStorage.write(key: key.name, value: value);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> setValue(StorageKey key, String value) async {
    return await _prefs?.setString(key.name, value) ?? false;
  }
}
