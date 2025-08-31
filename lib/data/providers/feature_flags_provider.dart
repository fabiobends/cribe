import 'dart:convert';

import 'package:cribe/core/config/env_vars.dart';
import 'package:cribe/core/constants/feature_flags.dart';
import 'package:cribe/core/constants/storage_keys.dart';
import 'package:cribe/data/services/storage_service.dart';
import 'package:flutter/foundation.dart';

class FeatureFlagsProvider extends ChangeNotifier {
  final StorageService _storageService;
  static const StorageKey _storageKey = StorageKey.featureFlags;
  static final Map<String, dynamic> _initialFlags = {
    FeatureFlagKey.booleanFlag.name: true,
    FeatureFlagKey.abTestVariant.name: 'A',
    FeatureFlagKey.apiEndpoint.name: EnvVars.apiUrl,
    FeatureFlagKey.defaultEmail.name: EnvVars.defaultEmail,
    FeatureFlagKey.defaultPassword.name: EnvVars.defaultPassword,
  };

  // All feature flags stored in a single map
  final Map<String, dynamic> _flags = Map.from(_initialFlags);

  FeatureFlagsProvider(this._storageService) {
    _loadFromStorage();
  }

  // Generic getter for any flag
  T getFlag<T>(FeatureFlagKey key) {
    return _flags[key.name] as T;
  }

  // Generic setter for any flag
  void setFlag<T>(FeatureFlagKey key, T value) {
    _flags[key.name] = value;
    _saveToStorage();
    notifyListeners();
  }

  void resetToDefaults() {
    _flags.addAll(_initialFlags);
    _saveToStorage();
    notifyListeners();
  }

  // Get all flags as a map (useful for debugging)
  Map<String, dynamic> getAllFlags() => Map<String, dynamic>.from(_flags);

  // Load flags from persistent storage
  Future<void> _loadFromStorage() async {
    try {
      final flagsJson = _storageService.getValue(_storageKey);
      if (flagsJson.isNotEmpty) {
        final flagsMap = jsonDecode(flagsJson) as Map<String, dynamic>;
        _flags.addAll(flagsMap);
        notifyListeners();
      }
    } catch (e) {
      // If loading fails, use defaults
      debugPrint('Failed to load feature flags from storage: $e');
    }
  }

  // Save flags to persistent storage
  Future<void> _saveToStorage() async {
    try {
      final flagsJson = jsonEncode(_flags);
      await _storageService.setValue(_storageKey, flagsJson);
    } catch (e) {
      debugPrint('Failed to save feature flags to storage: $e');
    }
  }
}
