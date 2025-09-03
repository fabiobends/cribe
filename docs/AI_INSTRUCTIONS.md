# AI Instructions

## Code Structure
- Place all screens/features in `/ui`, named with `_screen.dart`.
- Each screen must have:
  - A corresponding **ViewModel** in `/view_models` (extending BaseViewModel).
  - Corresponding **Widgets** in `/widgets`.
- **ViewModels** should handle all business logic and UI logic.
- **Widgets** should be dumb widgets and should not have any business logic.
- **Screens** should handle only UI logic and should not have any business logic.

## Testing
- **Screens** → integration tests (cover both happy and unhappy paths).
- **ViewModels** → unit tests (cover both happy and unhappy paths).

## Feature Management
- Add a feature flag in `/core/constants/feature_flags.dart` for every new feature.
- Include the new feature in **Storybook** (component or screen).

## Code Quality
- Add comments only in **ViewModels** and **Services** (business logic).
- Run all code quality checks available in _pre-commit_ and _pre-push_ hooks.
- Verify the project has no broken files or failing tests before finishing.

## Restrictions
- Don't add comments in widget trees.
- Do not run `flutter build` or `flutter run` (execution not visible in this environment).
- Keep all summaries of changes straightforward and concise.