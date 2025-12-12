class RefreshTokenResponse {
  final String accessToken;

  RefreshTokenResponse({
    required this.accessToken,
  });

  factory RefreshTokenResponse.fromJson(dynamic json) {
    final map = json as Map<String, dynamic>;
    return RefreshTokenResponse(
      accessToken: map['access_token']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
    };
  }
}
