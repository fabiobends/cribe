# AI Instructions

## Role & Responsibilities
- Flutter development assistant focused on performance, best practices, and security
- Follow clean architecture principles and maintain existing code patterns
- Use the comprehensive logging system for all new code
- Prioritize code quality and maintainability over quick solutions

## Project Structure
```
lib/
├── core/           # Core utilities and constants
│   ├── config/     # Environment configuration  
│   ├── constants/  # App constants and feature flags
│   ├── logger/     # Logging system (interface, mixins, console logger)
│   └── ui/         # Core UI utilities
├── data/           # Data layer
│   ├── model/      # Data models
│   ├── providers/  # State providers
│   ├── repositories/ # Data repositories (extend BaseRepository)
│   └── services/   # Business services (extend BaseService)
├── domain/         # Business logic layer
├── ui/             # Presentation layer
│   ├── [feature]/  # Feature-based organization
│   │   ├── view_models/ # ViewModels (extend ChangeNotifier + ViewModelLogger)
│   │   └── widgets/     # Screens and widgets
│   └── shared/     # Shared UI components
└── main.dart
```

## Code Guidelines

### Architecture Rules
- **ViewModels**: Handle business logic, extend `BaseViewModel` (includes logging)
- **Screens**: Handle UI logic only, use `ScreenLogger` for major screens
- **Widgets**: Dumb components, no business logic
- **Services**: Extend `BaseService`
- **Repositories**: Extend `BaseRepository`
- **Models**: Data classes, use `ModelLogger` if containing logic
- **Providers**: State management, use `ProviderLogger`

### Logging System
- Use appropriate logger mixins: `ViewModelLogger`, `ScreenLogger`, `ServiceLogger`, etc.
- Logger automatically masks sensitive data (emails, passwords, tokens)
- Feature flag controlled filtering (all/debug/info/warn/error/none)

## Testing & Quality

### Testing Strategy
- **Screens** → integration tests (happy/unhappy paths)
- **ViewModels** → unit tests (happy/unhappy paths)
- **Services/Repositories** → unit tests for business logic

### Code Quality
- Use logging mixins for appropriate visibility
- Add comments only in **ViewModels** and **Services** (business logic)
- Remove anything you've created that's not used in any file
- Run `pre-commit` and `pre-push` hooks before submission
- Verify no broken files or failing tests

## Feature Development
- Add feature flags in `/core/constants/feature_flags.dart`
- Include new features in **Storybook** documentation
- Follow clean architecture principles
- Use existing logger system for debugging and monitoring

## Restrictions
- Don't add comments in widget trees.
- Do not run `flutter build` or `flutter run` (execution not visible in this environment).
- Keep all summaries of changes straightforward and concise.