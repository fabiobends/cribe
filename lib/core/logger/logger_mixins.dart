import 'package:cribe/core/constants/logger_constants.dart';
import 'package:cribe/data/services/logger_service.dart';

/// Logger wrapper that automatically adds entity type and tag context
class ContextualLogger {
  final LoggerService _loggerService;
  final EntityType _entityType;
  final String _defaultTag;

  const ContextualLogger(
    this._loggerService,
    this._entityType,
    this._defaultTag,
  );

  void debug(String message, {String? tag, Map<String, dynamic>? extra}) {
    _loggerService.debug(
      message,
      tag: tag ?? _defaultTag,
      entityType: _entityType,
      extra: extra,
    );
  }

  void info(String message, {String? tag, Map<String, dynamic>? extra}) {
    _loggerService.info(
      message,
      tag: tag ?? _defaultTag,
      entityType: _entityType,
      extra: extra,
    );
  }

  void warn(String message, {String? tag, Map<String, dynamic>? extra}) {
    _loggerService.warn(
      message,
      tag: tag ?? _defaultTag,
      entityType: _entityType,
      extra: extra,
    );
  }

  void error(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
    Map<String, dynamic>? extra,
  }) {
    _loggerService.error(
      message,
      tag: tag ?? _defaultTag,
      entityType: _entityType,
      error: error,
      stackTrace: stackTrace,
      extra: extra,
    );
  }
}

/// Mixin for ViewModels to easily access logging
mixin ViewModelLogger {
  ContextualLogger get logger => ContextualLogger(
        LoggerService.instance,
        EntityType.viewModel,
        runtimeType.toString(),
      );
}

/// Mixin for Screens to easily access logging
mixin ScreenLogger {
  ContextualLogger get logger => ContextualLogger(
        LoggerService.instance,
        EntityType.screen,
        runtimeType.toString(),
      );
}

/// Mixin for Services to easily access logging
mixin ServiceLogger {
  ContextualLogger get logger => ContextualLogger(
        LoggerService.instance,
        EntityType.service,
        runtimeType.toString(),
      );
}

/// Mixin for Repositories to easily access logging
mixin RepositoryLogger {
  ContextualLogger get logger => ContextualLogger(
        LoggerService.instance,
        EntityType.repository,
        runtimeType.toString(),
      );
}

/// Mixin for Models to easily access logging
mixin ModelLogger {
  ContextualLogger get logger => ContextualLogger(
        LoggerService.instance,
        EntityType.model,
        runtimeType.toString(),
      );
}

/// Mixin for Providers to easily access logging
mixin ProviderLogger {
  ContextualLogger get logger => ContextualLogger(
        LoggerService.instance,
        EntityType.provider,
        runtimeType.toString(),
      );
}
