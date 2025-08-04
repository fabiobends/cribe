import 'package:cribe/core/enums/storage_key.dart';
import 'package:cribe/data/services/base_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService extends BaseService {
  SharedPreferences? _prefs;

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

  Future<bool> setValue(StorageKey key, String value) async {
    return await _prefs?.setString(key.name, value) ?? false;
  }
}
