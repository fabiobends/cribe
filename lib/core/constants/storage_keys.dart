enum StorageKey {
  featureFlags,
}

enum SecureStorageKey {
  accessToken,
  refreshToken,
}

extension StorageKeyExtension on StorageKey {
  String get name {
    switch (this) {
      case StorageKey.featureFlags:
        return 'cribe_feature_flags';
    }
  }
}

extension SecureStorageKeyExtension on SecureStorageKey {
  String get name {
    switch (this) {
      case SecureStorageKey.accessToken:
        return 'cribe_access_token';
      case SecureStorageKey.refreshToken:
        return 'cribe_refresh_token';
    }
  }
}
