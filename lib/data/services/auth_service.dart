import 'package:cribe/core/enums/storage_key.dart';
import 'package:cribe/data/services/storage_service.dart';

class AuthService {
  final StorageService _storageService;

  AuthService(this._storageService);

  bool get isAuthenticated {
    final accessToken = _storageService.getValue(StorageKey.accessToken);
    return accessToken.isNotEmpty;
  }

  String get accessToken {
    return _storageService.getValue(StorageKey.accessToken);
  }

  String get refreshToken {
    return _storageService.getValue(StorageKey.refreshToken);
  }
}
