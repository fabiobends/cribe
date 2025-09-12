// ignore_for_file: avoid_print

import 'dart:developer' as developer;
import 'package:cribe/core/constants/logger_constants.dart';
import 'package:cribe/core/logger/logger_interface.dart';
import 'package:validators/validators.dart';

/// Console-based logger implementation
/// Can be extended to integrate with Sentry, Crashlytics, etc.
class ConsoleLogger implements LoggerInterface {
  LogFilter _currentFilter = LogFilter.all;

  void setLogFilter(LogFilter filter) {
    _currentFilter = filter;
  }

  LogFilter get currentFilter => _currentFilter;

  @override
  Future<void> init() async {
    // Initialize any platform-specific loggers here
    // e.g., await Sentry.init(), FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true)
  }
  @override
  void dispose() {
    // Cleanup platform-specific loggers
  }

  @override
  void debug(
    String message, {
    String? tag,
    EntityType? entityType,
    Map<String, dynamic>? extra,
  }) {
    _log(
      LogLevel.debug,
      message,
      tag: tag,
      entityType: entityType,
      extra: extra,
    );
  }

  @override
  void info(
    String message, {
    String? tag,
    EntityType? entityType,
    Map<String, dynamic>? extra,
  }) {
    _log(
      LogLevel.info,
      message,
      tag: tag,
      entityType: entityType,
      extra: extra,
    );
  }

  @override
  void warn(
    String message, {
    String? tag,
    EntityType? entityType,
    Map<String, dynamic>? extra,
  }) {
    _log(
      LogLevel.warn,
      message,
      tag: tag,
      entityType: entityType,
      extra: extra,
    );
  }

  @override
  void error(
    String message, {
    String? tag,
    EntityType? entityType,
    Object? error,
    StackTrace? stackTrace,
    Map<String, dynamic>? extra,
  }) {
    _log(
      LogLevel.error,
      message,
      tag: tag,
      entityType: entityType,
      error: error,
      stackTrace: stackTrace,
      extra: extra,
    );
  }

  void _log(
    LogLevel level,
    String message, {
    String? tag,
    EntityType? entityType,
    Object? error,
    StackTrace? stackTrace,
    Map<String, dynamic>? extra,
  }) {
    if (!_shouldLog(level)) return;

    final now = DateTime.now();
    final timestamp =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';
    final entityTag = _getEntityTag(entityType);
    final levelTag = level.name.toUpperCase().padRight(5);
    final tagString = tag != null ? '[$tag]' : '';
    final indicator = _getLevelIndicator(level);

    // Mask sensitive data in the message
    final maskedMessage = _maskSensitiveData(message);

    final logMessage =
        '$indicator[$timestamp] $levelTag $entityTag $tagString $maskedMessage';

    // Console output
    print(logMessage);

    // Developer log for better IDE integration
    developer.log(
      message,
      time: DateTime.now(),
      level: _getDeveloperLogLevel(level),
      name: tag ?? entityTag,
      error: error,
      stackTrace: stackTrace,
    );

    // TODO: Add platform-specific logging here
    // e.g., Sentry.captureMessage(message, level: _getSentryLevel(level));
    // e.g., FirebaseCrashlytics.instance.log(logMessage);

    if (extra != null && extra.isNotEmpty) {
      final maskedExtra = _maskSensitiveMap(extra);
      print('$indicator  $maskedExtra');
    }

    if (error != null) {
      final maskedError = _maskSensitiveData(error);
      print('$indicator  Error: $maskedError');
    }

    if (stackTrace != null) {
      print('$indicator  StackTrace: $stackTrace');
    }
  }

  bool _shouldLog(LogLevel level) {
    switch (_currentFilter) {
      case LogFilter.none:
        return false;
      case LogFilter.all:
        return true;
      case LogFilter.debug:
        return true; // Debug and above (all levels)
      case LogFilter.info:
        return level.index >= LogLevel.info.index; // Info and above
      case LogFilter.warn:
        return level.index >= LogLevel.warn.index; // Warn and above
      case LogFilter.error:
        return level == LogLevel.error; // Error only
    }
  }

  String _getLevelIndicator(LogLevel level) {
    // Visual indicators for clean console output
    switch (level) {
      case LogLevel.debug:
        return '🔍'; // Debug
      case LogLevel.info:
        return 'ℹ️'; // Info
      case LogLevel.warn:
        return '⚠️'; // Warning
      case LogLevel.error:
        return '❌'; // Error
    }
  }

  /// Masks sensitive information in strings and maps
  /// Uses the validators package to properly identify emails instead of hardcoded regex
  String _maskSensitiveData(dynamic data) {
    if (data == null) return 'null';

    String dataStr = data.toString();

    // Email masking using validators package: user@example.com → u***@e***.com
    final words = dataStr.split(RegExp(r'\s+'));
    final maskedWords = words.map((word) {
      // Clean word of punctuation for validation
      final cleanWord = word.replaceAll(RegExp(r'[^\w@.-]'), '');

      if (isEmail(cleanWord)) {
        final parts = cleanWord.split('@');
        final username = parts[0];
        final domain = parts[1];

        final maskedUsername =
            username.length > 4 ? '${username.substring(0, 4)}****' : username;

        final maskedDomain =
            domain.length > 4 ? '${domain.substring(0, 4)}****' : domain;

        return word.replaceAll(cleanWord, '$maskedUsername@$maskedDomain');
      }
      return word;
    }).toList();

    dataStr = maskedWords.join(' ');

    // Token masking: long alphanumeric strings (tokens, passwords, etc.)
    dataStr = dataStr.replaceAllMapped(
      RegExp(r'\b[A-Za-z0-9+/]{20,}={0,2}\b'), // Base64 tokens
      (match) => '${match.group(0)!.substring(0, 4)}****',
    );

    // API Key masking: keys starting with common prefixes
    dataStr = dataStr.replaceAllMapped(
      RegExp(r'\b(sk_|pk_|key_|api_|token_)[A-Za-z0-9_-]{10,}\b'),
      (match) => '${match.group(1)}****',
    );

    // Password field masking in maps
    dataStr = dataStr.replaceAllMapped(
        RegExp(
          r'(password|pwd|secret|token|access_token|refresh_token):\s*[^,}]+',
          caseSensitive: false,
        ), (match) {
      final field = match.group(0)!;
      final colonIndex = field.indexOf(':');
      return '${field.substring(0, colonIndex + 1)} ****';
    });

    return dataStr;
  }

  /// Recursively masks sensitive data in maps
  Map<String, dynamic> _maskSensitiveMap(Map<String, dynamic> map) {
    final sensitiveKeys = {
      'password',
      'pwd',
      'secret',
      'token',
      'access_token',
      'refresh_token',
      'email',
      'auth',
      'authorization',
      'credential',
    };

    return map.map((key, value) {
      final lowerKey = key.toLowerCase();

      if (sensitiveKeys.any((sensitive) => lowerKey.contains(sensitive))) {
        if (lowerKey.contains('email')) {
          return MapEntry(key, _maskSensitiveData(value));
        } else {
          return MapEntry(key, '****');
        }
      }

      if (value is Map<String, dynamic>) {
        return MapEntry(key, _maskSensitiveMap(value));
      }

      return MapEntry(key, value);
    });
  }

  String _getEntityTag(EntityType? entityType) {
    if (entityType == null) return '[UNKNOWN]';

    switch (entityType) {
      case EntityType.viewModel:
        return '[VIEW_MODEL]';
      case EntityType.screen:
        return '[SCREEN]';
      case EntityType.service:
        return '[SERVICE]';
      case EntityType.repository:
        return '[REPOSITORY]';
      case EntityType.model:
        return '[MODEL]';
      case EntityType.provider:
        return '[PROVIDER]';
      case EntityType.unknown:
        return '[UNKNOWN]';
    }
  }

  int _getDeveloperLogLevel(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return 500;
      case LogLevel.info:
        return 800;
      case LogLevel.warn:
        return 900;
      case LogLevel.error:
        return 1000;
    }
  }
}
