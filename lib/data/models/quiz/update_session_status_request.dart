class UpdateSessionStatusRequest {
  final String status;

  UpdateSessionStatusRequest({required this.status});

  Map<String, dynamic> toJson() {
    return {
      'status': status,
    };
  }
}
