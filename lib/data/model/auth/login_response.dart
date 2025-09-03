class LoginResponse {
  final String accessToken;
  final String refreshToken;

  LoginResponse({
    required this.accessToken,
    required this.refreshToken,
  });

  factory LoginResponse.fromJson(dynamic json) {
    final map = json as Map<String, dynamic>;
    return LoginResponse(
      accessToken: map['access_token']?.toString() ?? '',
      refreshToken: map['refresh_token']?.toString() ?? '',
    );
  }
}

typedef AuthTokens = LoginResponse;
