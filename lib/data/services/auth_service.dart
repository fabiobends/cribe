import 'package:cribe/core/constants/storage_keys.dart';
import 'package:cribe/data/services/base_service.dart';
import 'package:cribe/data/services/storage_service.dart';

class AuthService extends BaseService {
  final StorageService _storageService;

  AuthService(this._storageService) {
    logger.info('AuthService initialized');
  }

  @override
  Future<void> init() async {
    logger.debug('AuthService init called');
    // No specific initialization needed
  }

  @override
  Future<void> dispose() async {
    logger.debug('AuthService dispose called');
    // No specific cleanup needed
  }

  Future<bool> get isAuthenticated async {
    logger.debug('Checking authentication status');
    final accessToken =
        await _storageService.getSecureValue(SecureStorageKey.accessToken);
    final isAuth = accessToken.isNotEmpty;
    logger.debug('Authentication status: $isAuth');
    return isAuth;
  }

  Future<String> get accessToken async {
    logger.debug('Retrieving access token');
    return await _storageService.getSecureValue(SecureStorageKey.accessToken);
  }

  Future<String> get refreshToken async {
    logger.debug('Retrieving refresh token');
    return await _storageService.getSecureValue(SecureStorageKey.refreshToken);
  }
}
