import 'dart:convert';

import 'package:cribe/core/config/env_vars.dart';
import 'package:cribe/core/constants/feature_flags.dart';
import 'package:cribe/core/constants/logger_constants.dart';
import 'package:cribe/core/constants/storage_keys.dart';
import 'package:cribe/core/logger/logger_mixins.dart';
import 'package:cribe/data/services/logger_service.dart';
import 'package:cribe/data/services/storage_service.dart';
import 'package:flutter/foundation.dart';

class FeatureFlagsProvider extends ChangeNotifier with ProviderLogger {
  final StorageService _storageService;
  static const StorageKey _storageKey = StorageKey.featureFlags;
  static final Map<String, dynamic> _initialFlags = {
    FeatureFlagKey.booleanFlag.name: true,
    FeatureFlagKey.abTestVariant.name: 'A',
    FeatureFlagKey.apiEndpoint.name: EnvVars.apiUrl,
    FeatureFlagKey.defaultEmail.name: EnvVars.defaultEmail,
    FeatureFlagKey.defaultPassword.name: EnvVars.defaultPassword,
    FeatureFlagKey.logFilter.name: EnvVars.defaultLogFilter,
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

    // If setting log filter, update the logger service
    if (key == FeatureFlagKey.logFilter) {
      _updateLogFilter(value.toString());
    }

    _saveToStorage();
    notifyListeners();
  }

  // Update log filter in the logger service
  void _updateLogFilter(String filterValue) {
    try {
      LogFilter filter;
      switch (filterValue.toLowerCase()) {
        case 'debug':
          filter = LogFilter.debug;
          break;
        case 'info':
          filter = LogFilter.info;
          break;
        case 'warn':
          filter = LogFilter.warn;
          break;
        case 'error':
          filter = LogFilter.error;
          break;
        case 'none':
          filter = LogFilter.none;
          break;
        case 'all':
        default:
          filter = LogFilter.all;
          break;
      }
      LoggerService.instance.setLogFilter(filter);
      logger.info('Log filter updated', extra: {'filter': filterValue});
    } catch (e) {
      logger.error(
        'Failed to update log filter',
        error: e,
        extra: {'filter': filterValue},
      );
    }
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
    logger.debug('Loading feature flags from storage');
    try {
      final flagsJson = _storageService.getValue(_storageKey);
      if (flagsJson.isNotEmpty) {
        final flagsMap = jsonDecode(flagsJson) as Map<String, dynamic>;
        _flags.addAll(flagsMap);
        logger.info(
          'Feature flags loaded from storage',
          extra: {'count': flagsMap.length},
        );
        notifyListeners();
      } else {
        logger.debug('No feature flags found in storage, using defaults');
      }
    } catch (e) {
      logger.error('Failed to load feature flags from storage', error: e);
    }
  }

  // Save flags to persistent storage
  Future<void> _saveToStorage() async {
    logger.debug('Saving feature flags to storage');
    try {
      final flagsJson = jsonEncode(_flags);
      await _storageService.setValue(_storageKey, flagsJson);
      logger.debug('Feature flags saved successfully');
    } catch (e) {
      logger.error('Failed to save feature flags to storage', error: e);
    }
  }
}
