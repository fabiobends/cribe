import 'package:cribe/core/logger/logger_mixins.dart';

class LoginRequest with ModelLogger {
  final String email;
  final String password;

  LoginRequest({
    required this.email,
    required this.password,
  }) {
    logger.debug(
      'LoginRequest created',
      extra: {
        'email': email,
        'passwordLength': password.length,
      },
    );
  }

  Map<String, dynamic> toJson() {
    logger.debug('Converting LoginRequest to JSON');
    final json = {
      'email': email,
      'password': password,
    };
    logger.debug(
      'LoginRequest JSON conversion completed',
      extra: {
        'fieldCount': json.length,
      },
    );
    return json;
  }
}
