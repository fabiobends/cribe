# Logger Architecture Documentation

## Overview

The Cribe application implements a comprehensive, platform-agnostic logging system designed for scalability, flexibility, and ease of use across all application layers.

## Core Components

### 1. LoggerInterface

The abstract interface that defines the contract for all logging implementations.

```mermaid
classDiagram
    class LoggerInterface {
        <<abstract>>
        +debug(String message, String tag, EntityType entityType, Map extra)
        +info(String message, String tag, EntityType entityType, Map extra)
        +warn(String message, String tag, EntityType entityType, Map extra)
        +error(String message, String tag, EntityType entityType, Object error, StackTrace stackTrace, Map extra)
        +setMinLevel(LogLevel level) void
        +setEnabled(bool enabled) void
        +init() Future~void~
        +dispose() void
    }
    
    class ConsoleLogger {
        -LogLevel _minLevel
        -bool _enabled
        +setMinLevel(LogLevel level) void
        +setEnabled(bool enabled) void
        +debug(String message, ...)
        +info(String message, ...)
        +warn(String message, ...)
        +error(String message, ...)
        +init() Future~void~
        +dispose() void
        -_shouldLog(LogLevel level) bool
        -_getLevelIndicator(LogLevel level) String
        -_maskSensitiveData(String data) String
        -_maskSensitiveMap(Map data) Map
    }
    
    LoggerInterface <|-- ConsoleLogger
```

### 2. LoggerService (Singleton)

Central service that manages logging across the application and integrates with feature flags.

```mermaid
sequenceDiagram
    participant App as Application
    participant LS as LoggerService
    participant FF as FeatureFlags
    participant CL as ConsoleLogger
    
    App->>LS: Initialize
    LS->>FF: Get log filter
    App->>LS: Log message
    LS->>FF: Check filter level
    alt Message passes filter
        LS->>CL: Forward to implementation
        CL->>Console: Output with emojis
    else Message filtered out
        LS-->>App: Ignore
    end
```

### 3. ContextualLogger & Mixins

Provides convenient access to logging with automatic context injection.

**How it works:**
1. Your class uses a mixin (e.g., `ViewModelLogger`)
2. The mixin provides a `logger` property
3. The logger automatically knows your entity type and class name
4. You just call `logger.info()` and context is added automatically

**Available mixins:**
- `ViewModelLogger` → Tags logs as `[VIEW_MODEL]`
- `ScreenLogger` → Tags logs as `[SCREEN]`
- `ServiceLogger` → Tags logs as `[SERVICE]`
- `RepositoryLogger` → Tags logs as `[REPOSITORY]`
- `ModelLogger` → Tags logs as `[MODEL]`
- `ProviderLogger` → Tags logs as `[PROVIDER]`

## Hierarchical Log Levels & Visual Indicators

The logging system uses severity-based hierarchical filtering where each level includes all higher severity levels:

| Level | Severity | Emoji | Shows | Usage |
|-------|----------|-------|-------|-------|
| DEBUG | 0 | 🔍 | All messages | Development debugging |
| INFO | 1 | ℹ️ | Info, Warn, Error | General information |
| WARN | 2 | ⚠️ | Warn, Error | Warning conditions |
| ERROR | 3 | ❌ | Error only | Error conditions |
| NONE | - | - | Nothing | Disable all logging |

## Security Features

### Sensitive Data Masking

The logger automatically masks sensitive information:

- **Emails**: `user***@exam***`
- **Passwords/Tokens**: `****`
- **Recursive**: Works with nested objects and arrays


## Usage Patterns

### Basic Usage

```dart
class LoginViewModel extends ChangeNotifier with ViewModelLogger {
  Future<void> authenticate() async {
    logger.info('Starting authentication');
    
    try {
      await authRepository.login(email, password);
      logger.info('Authentication successful');
    } catch (e) {
      logger.error('Authentication failed', error: e);
    }
  }
}
```

### Entity Type Automatic Tagging

```mermaid
graph LR
    A[RepositoryLogger] --> B[Tag: Repository]
    C[ServiceLogger] --> D[Tag: Service]
    E[ViewModelLogger] --> F[Tag: ViewModel]
    G[ScreenLogger] --> H[Tag: Screen]
    I[ModelLogger] --> J[Tag: Model]
    K[ProviderLogger] --> L[Tag: Provider]
```

## Platform Extensions

The logger system is designed to be easily extended with platform-specific implementations:

```mermaid
graph TB
    A[LoggerInterface] --> B[ConsoleLogger]
    A --> C[SentryLogger]
    A --> D[CrashlyticsLogger]
    A --> E[CustomLogger]
    
    subgraph Current ["Currently Implemented"]
        B
    end
    
    subgraph Future ["Future Extensions"]
        C
        D
        E
    end
```

## File Structure

```
lib/core/logger/
├── logger_interface.dart      # Abstract interface (no LoggerContext)
├── console_logger.dart        # Console implementation with masking
└── logger_mixins.dart         # Entity mixins & ContextualLogger

lib/core/constants/
└── logger_constants.dart      # LogLevel, LogFilter, EntityType

lib/data/services/
└── logger_service.dart        # Central logging service with filtering
```

## Configuration

```bash
# .env file
LOG_LEVEL=INFO  # Options: DEBUG, INFO, WARN, ERROR, NONE
```

### Hierarchical Filtering

The logger uses severity-based filtering:
- **DEBUG**: Shows all messages (debug, info, warn, error)
- **INFO**: Shows info, warn, and error messages
- **WARN**: Shows warn and error messages  
- **ERROR**: Shows only error messages
- **NONE**: Disables all logging

### Feature Flag Configuration

The logger level is managed through the existing feature flag system, allowing runtime configuration through the dev helper UI.

```mermaid
graph TD
    A[Dev Helper UI] --> B[Log Level Dropdown]
    B --> C{User Selection}
    C -->|DEBUG| D[severity >= 0: All logs]
    C -->|INFO| E[severity >= 1: Info, Warn, Error]
    C -->|WARN| F[severity >= 2: Warn, Error]
    C -->|ERROR| G[severity >= 3: Error only]
    C -->|NONE| H[_enabled = false: No logs]
    
    D --> I[LoggerService.setLogLevelByName]
    E --> I
    F --> I
    G --> I
    H --> J[LoggerService.setEnabled false]
    
    I --> K[Hierarchical Severity Check]
    J --> K
    K --> L[Persistent Storage]
```