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
  LogLevel _minLevel = LogLevel.info;
  bool _enabled = true;

  /// Initialize the logger service
  @override
  Future<void> init({StorageService? storageService}) async {
    _storageService = storageService;
    _logger = ConsoleLogger();
    await _logger?.init();

    // Configure logging based on LOG_LEVEL environment variable
    _configure();
  }

  /// Configure the logger service based on environment variables
  void _configure() {
    // Check if logging is enabled via environment variable
    final logLevel = EnvVars.logLevel.toUpperCase().trim();

    // Handle NONE as explicit disable, but empty or invalid defaults to INFO
    if (logLevel == 'NONE') {
      _enabled = false;
      return;
    }

    // Set minimum log level following severity hierarchy
    switch (logLevel) {
      case 'DEBUG':
        _minLevel = LogLevel.debug;
        break;
      case 'INFO':
        _minLevel = LogLevel.info;
        break;
      case 'WARN':
      case 'WARNING':
        _minLevel = LogLevel.warn;
        break;
      case 'ERROR':
        _minLevel = LogLevel.error;
        break;
      case '': // Empty LOG_LEVEL defaults to INFO level behavior
        _minLevel = LogLevel.info;
        break;
      default:
        // For unknown log levels, default to INFO
        _minLevel = LogLevel.info;
    }

    _enabled = true;

    // Update the console logger to use hierarchical filtering
    final logger = _logger;
    if (logger is ConsoleLogger) {
      logger.setMinLevel(_minLevel);
      logger.setEnabled(_enabled);
    }
  }

  /// Update log level and persist to feature flags
  void setLogLevel(LogLevel level) {
    _minLevel = level;

    final logger = _logger;
    if (logger is ConsoleLogger) {
      logger.setMinLevel(_minLevel);
    }

    // Persist to feature flags if storage service is available
    try {
      if (_storageService != null) {
        final flagsJson = _storageService!.getValue(StorageKey.featureFlags);
        Map<String, dynamic> flags = {};

        if (flagsJson.isNotEmpty) {
          flags = jsonDecode(flagsJson) as Map<String, dynamic>;
        }

        flags[FeatureFlagKey.logFilter.name] = level.name;
        _storageService?.setValue(StorageKey.featureFlags, jsonEncode(flags));
      }
    } catch (e) {
      // Log error but don't crash - only if logger is available
      _logger?.error(
        'Failed to persist log level',
        entityType: EntityType.service,
        error: e,
      );
    }
  }

  /// Get current minimum log level
  LogLevel get minLevel => _minLevel;

  /// Get current enabled state
  bool get enabled => _enabled;

  /// Check if logging is enabled and meets minimum level
  bool _shouldLog(LogLevel level) {
    return _enabled && level.severity >= _minLevel.severity;
  }

  /// Debug log
  void debug(
    String message, {
    String? tag,
    EntityType? entityType,
    Map<String, dynamic>? extra,
  }) {
    if (_shouldLog(LogLevel.debug)) {
      _logger?.debug(message, tag: tag, entityType: entityType, extra: extra);
    }
  }

  /// Info log
  void info(
    String message, {
    String? tag,
    EntityType? entityType,
    Map<String, dynamic>? extra,
  }) {
    if (_shouldLog(LogLevel.info)) {
      _logger?.info(message, tag: tag, entityType: entityType, extra: extra);
    }
  }

  /// Warning log
  void warn(
    String message, {
    String? tag,
    EntityType? entityType,
    Map<String, dynamic>? extra,
  }) {
    if (_shouldLog(LogLevel.warn)) {
      _logger?.warn(message, tag: tag, entityType: entityType, extra: extra);
    }
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
    if (_shouldLog(LogLevel.error)) {
      _logger?.error(
        message,
        tag: tag,
        entityType: entityType,
        error: error,
        stackTrace: stackTrace,
        extra: extra,
      );
    }
  }

  /// Dispose the logger service
  @override
  Future<void> dispose() async {
    _logger?.dispose();
  }
}
