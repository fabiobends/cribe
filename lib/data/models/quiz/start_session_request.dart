class StartSessionRequest {
  final int episodeId;

  StartSessionRequest({required this.episodeId});

  Map<String, dynamic> toJson() {
    return {
      'episode_id': episodeId,
    };
  }
}
