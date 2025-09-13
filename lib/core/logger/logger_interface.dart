import 'package:cribe/core/constants/logger_constants.dart';

/// Abstract interface for platform-agnostic logging
/// Can be implemented for different platforms like Sentry, Crashlytics, etc.
abstract class LoggerInterface {
  void debug(
    String message, {
    String? tag,
    EntityType? entityType,
    Map<String, dynamic>? extra,
  });
  void info(
    String message, {
    String? tag,
    EntityType? entityType,
    Map<String, dynamic>? extra,
  });
  void warn(
    String message, {
    String? tag,
    EntityType? entityType,
    Map<String, dynamic>? extra,
  });
  void error(
    String message, {
    String? tag,
    EntityType? entityType,
    Object? error,
    StackTrace? stackTrace,
    Map<String, dynamic>? extra,
  });

  /// Platform-specific initialization
  Future<void> init();

  /// Platform-specific cleanup
  void dispose();
}
