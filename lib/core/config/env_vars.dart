import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvVars {
  static String get apiUrl {
    return dotenv.env['API_URL'] ?? '';
  }

  static String get defaultEmail {
    return dotenv.env['DEFAULT_EMAIL'] ?? '';
  }

  static String get defaultPassword {
    return dotenv.env['DEFAULT_PASSWORD'] ?? '';
  }

  static String get defaultLogFilter {
    return dotenv.env['DEFAULT_LOG_FILTER'] ?? 'all';
  }
}
