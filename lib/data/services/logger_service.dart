import 'dart:convert';

import 'package:cribe/core/config/env_vars.dart';
import 'package:cribe/core/constants/feature_flags.dart';
import 'package:cribe/core/constants/logger_constants.dart';
import 'package:cribe/core/constants/storage_keys.dart';
import 'package:cribe/core/logger/console_logger.dart';
import 'package:cribe/core/logger/logger_interface.dart';
import 'package:cribe/data/services/base_service.dart';
import 'package:cribe/data/services/storage_service.dart';

/// Main logger service that manages logging across the application
class LoggerService extends BaseService {
  static LoggerService? _instance;
  static LoggerService get instance => _instance ??= LoggerService._();

  LoggerService._();

  LoggerInterface? _logger;
  StorageService? _storageService;

  /// Initialize the logger service
  @override
  Future<void> init({StorageService? storageService}) async {
    _storageService = storageService;
    _logger = ConsoleLogger();
    await _logger!.init();

    // Set initial log filter from feature flags or env
    _updateLogFilter();
  }

  /// Update log filter from feature flags or default
  void _updateLogFilter() {
    if (_logger == null) return;

    try {
      if (_storageService != null) {
        final flagsJson = _storageService!.getValue(StorageKey.featureFlags);
        if (flagsJson.isNotEmpty) {
          final map = jsonDecode(flagsJson) as Map<String, dynamic>;
          final filterValue = map[FeatureFlagKey.logFilter.name]?.toString();
          if (filterValue != null) {
            final filter = _parseLogFilter(filterValue);
            if (_logger is ConsoleLogger) {
              (_logger! as ConsoleLogger).setLogFilter(filter);
            }
            return;
          }
        }
      }
    } catch (e) {
      // Fallback to env default
    }

    // Use default from env
    final defaultFilter = _parseLogFilter(EnvVars.defaultLogFilter);
    if (_logger is ConsoleLogger) {
      (_logger! as ConsoleLogger).setLogFilter(defaultFilter);
    }
  }

  LogFilter _parseLogFilter(String value) {
    switch (value.toLowerCase()) {
      case 'debug':
        return LogFilter.debug;
      case 'info':
        return LogFilter.info;
      case 'warn':
        return LogFilter.warn;
      case 'error':
        return LogFilter.error;
      case 'none':
        return LogFilter.none;
      case 'all':
      default:
        return LogFilter.all;
    }
  }

  /// Update log filter and persist to feature flags
  void setLogFilter(LogFilter filter) {
    if (_logger is ConsoleLogger) {
      (_logger! as ConsoleLogger).setLogFilter(filter);
    }

    // Persist to feature flags if storage service is available
    try {
      if (_storageService != null) {
        final flagsJson = _storageService!.getValue(StorageKey.featureFlags);
        Map<String, dynamic> flags = {};

        if (flagsJson.isNotEmpty) {
          flags = jsonDecode(flagsJson) as Map<String, dynamic>;
        }

        flags[FeatureFlagKey.logFilter.name] = filter.name;
        _storageService!.setValue(StorageKey.featureFlags, jsonEncode(flags));
      }
    } catch (e) {
      // Log error but don't crash - only if logger is available
      _logger?.error(
        'Failed to persist log filter',
        entityType: EntityType.service,
        error: e,
      );
    }
  }

  /// Get current log filter
  LogFilter get currentFilter {
    if (_logger is ConsoleLogger) {
      return (_logger! as ConsoleLogger).currentFilter;
    }
    return LogFilter.all;
  }

  /// Debug log
  void debug(
    String message, {
    String? tag,
    EntityType? entityType,
    Map<String, dynamic>? extra,
  }) {
    _logger?.debug(message, tag: tag, entityType: entityType, extra: extra);
  }

  /// Info log
  void info(
    String message, {
    String? tag,
    EntityType? entityType,
    Map<String, dynamic>? extra,
  }) {
    _logger?.info(message, tag: tag, entityType: entityType, extra: extra);
  }

  /// Warning log
  void warn(
    String message, {
    String? tag,
    EntityType? entityType,
    Map<String, dynamic>? extra,
  }) {
    _logger?.warn(message, tag: tag, entityType: entityType, extra: extra);
  }

  /// Error log
  void error(
    String message, {
    String? tag,
    EntityType? entityType,
    Object? error,
    StackTrace? stackTrace,
    Map<String, dynamic>? extra,
  }) {
    _logger?.error(
      message,
      tag: tag,
      entityType: entityType,
      error: error,
      stackTrace: stackTrace,
      extra: extra,
    );
  }

  /// Dispose the logger service
  @override
  Future<void> dispose() async {
    _logger?.dispose();
  }
}
