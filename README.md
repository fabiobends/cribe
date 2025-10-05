# Cribe Flutter App

Flutter mobile app with authentication, user management, and development tools.

## 📱 What it does

- User authentication (login/register/logout)
- Feature flags configuration
- Built-in development tools (storybook, component testing)
- Cross-platform support (iOS, Android, Web, Desktop)

## 🛠️ Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install)
- [Cribe Server](../cribe-server/README.md) running

## ⚙️ Quick Setup

1. **Install dependencies:**
   ```bash
   flutter pub get
   ```

2. **Setup Git hooks:**
   ```bash
   make setup-hooks  # run once or when hook scripts change
   ```

3. **Start developing:**
   ```bash
   flutter run # or run it using Flutter Dev Tools
   ```

## ⚙️ Environment

Create a `.env` file with the following info, you can edit it if needed.

```bash
API_BASE_URL=http://localhost:8080
DEFAULT_EMAIL=dev@example.com
DEFAULT_PASSWORD=password123
```

## 🚀 Commands

```bash
make test             # Run tests with coverage
make format-fix       # Format and fix code
```

## 🛠️ Dev Helper

This is a floating button in debug mode that lets you adjust/see:
- Feature flags configuration
- UI component storybook
- Screen previews

## 📚 Documentation

- [Authentication Flow](docs/AUTH_DOCUMENTATION.md)
- [Home Screen](docs/HOME_DOCUMENTATION.md)
- [Dev Helper](docs/DEV_HELPER_DOCUMENTATION.md)
- [Logger](docs/LOGGER_ARCHITECTURE.md)
- [AI Instructions](docs/AI_INSTRUCTIONS.md)

That's it! A Flutter app with authentication, development tools, and clean architecture.
