class Episode {
  final int id;
  final String externalId;
  final int podcastId;
  final String name;
  final String description;
  final String audioUrl;
  final String imageUrl;
  final String datePublished;
  final int duration;
  final DateTime createdAt;
  final DateTime updatedAt;

  Episode({
    required this.id,
    required this.externalId,
    required this.podcastId,
    required this.name,
    required this.description,
    required this.audioUrl,
    required this.imageUrl,
    required this.datePublished,
    required this.duration,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Episode.fromJson(dynamic json) {
    final map = json as Map<String, dynamic>;
    return Episode(
      id: map['id'] as int? ?? 0,
      externalId: map['externalId'] as String? ?? '',
      podcastId: map['podcastId'] as int? ?? 0,
      name: map['name'] as String? ?? '',
      description: map['description'] as String? ?? '',
      audioUrl: map['audioUrl'] as String? ?? '',
      imageUrl: map['imageUrl'] as String? ?? '',
      datePublished: map['datePublished'] as String? ?? '',
      duration: map['duration'] as int? ?? 0,
      createdAt: DateTime.parse(map['createdAt'] as String? ?? ''),
      updatedAt: DateTime.parse(map['updatedAt'] as String? ?? ''),
    );
  }
}
