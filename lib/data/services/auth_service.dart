import 'package:cribe/core/constants/storage_keys.dart';
import 'package:cribe/data/services/storage_service.dart';

class AuthService {
  final StorageService _storageService;

  AuthService(this._storageService);

  Future<bool> get isAuthenticated async {
    final accessToken =
        await _storageService.getSecureValue(SecureStorageKey.accessToken);
    return accessToken.isNotEmpty;
  }

  Future<String> get accessToken async {
    return await _storageService.getSecureValue(SecureStorageKey.accessToken);
  }

  Future<String> get refreshToken async {
    return await _storageService.getSecureValue(SecureStorageKey.refreshToken);
  }
}
