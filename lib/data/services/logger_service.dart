import 'package:cribe/core/config/env_vars.dart';
import 'package:cribe/core/constants/logger_constants.dart';
import 'package:cribe/core/logger/console_logger.dart';
import 'package:cribe/core/logger/logger_interface.dart';
import 'package:cribe/data/services/base_service.dart';

/// Main logger service that manages logging across the application
class LoggerService extends BaseService {
  static LoggerService? _instance;
  static LoggerService get instance => _instance ??= LoggerService._();

  LoggerService._();

  LoggerInterface? _logger;
  LogLevel _minLevel = LogLevel.info;
  bool _enabled = true;

  @override
  Future<void> init() async {
    _logger = ConsoleLogger();
    await _logger?.init();
    _configureFromEnv();
  }

  /// Configure logging based on LOG_LEVEL environment variable
  void _configureFromEnv() {
    final logLevel = EnvVars.logLevel.toUpperCase().trim();

    if (logLevel == 'NONE') {
      setEnabled(false);
      return;
    }

    setLogLevelByName(logLevel);
  }

  /// Set log level by enum
  void setLogLevel(LogLevel level) {
    _minLevel = level;
    _logger?.setMinLevel(_minLevel);
  }

  /// Set log level by string name
  void setLogLevelByName(String levelName) {
    try {
      switch (levelName.toUpperCase().trim()) {
        case 'DEBUG':
          setEnabled(true);
          setLogLevel(LogLevel.debug);
          break;
        case 'INFO':
          setEnabled(true);
          setLogLevel(LogLevel.info);
          break;
        case 'WARN':
        case 'WARNING':
          setEnabled(true);
          setLogLevel(LogLevel.warn);
          break;
        case 'ERROR':
          setEnabled(true);
          setLogLevel(LogLevel.error);
          break;
        case 'NONE':
          info(
            'Disabling logging (NONE level set)',
            entityType: EntityType.service,
          );
          setEnabled(false);
          return;
        default:
          setEnabled(true);
          setLogLevel(LogLevel.info);
      }
    } catch (e) {
      error('Failed to set log level by name: $levelName', error: e);
    }
  }

  LogLevel get minLevel => _minLevel;
  bool get enabled => _enabled;

  void setEnabled(bool enabled) {
    _enabled = enabled;
    _logger?.setEnabled(enabled);
  }

  bool _shouldLog(LogLevel level) =>
      _enabled && level.severity >= _minLevel.severity;

  // --- Logging methods ---

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

  @override
  Future<void> dispose() async {
    _logger?.dispose();
  }
}
