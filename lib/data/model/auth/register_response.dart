class RegisterResponse {
  final int id;

  RegisterResponse({
    required this.id,
  });

  factory RegisterResponse.fromJson(dynamic json) {
    final map = json as Map<String, dynamic>;
    return RegisterResponse(
      id: map['id'] as int? ?? 0,
    );
  }
}
