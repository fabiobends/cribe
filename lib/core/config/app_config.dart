import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static String get apiUrl {
    return dotenv.env['API_URL'] ?? '';
  }
}
