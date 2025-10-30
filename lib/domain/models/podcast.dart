class Podcast {
  final int id;
  final String authorName;
  final String name;
  final String? imageUrl;
  final String description;
  final String externalId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<Episode>? episodes;

  Podcast({
    required this.id,
    required this.authorName,
    required this.name,
    this.imageUrl,
    required this.description,
    required this.externalId,
    required this.createdAt,
    required this.updatedAt,
    this.episodes,
  });

  factory Podcast.fromJson(Map<String, dynamic> json) {
    return Podcast(
      id: json['id'] as int,
      authorName: json['author_name'] as String,
      name: json['name'] as String,
      imageUrl: json['image_url'] as String?,
      description: json['description'] as String,
      externalId: json['external_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      episodes: json['episodes'] != null
          ? (json['episodes'] as List)
              .map((e) => Episode.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'author_name': authorName,
      'name': name,
      'image_url': imageUrl,
      'description': description,
      'external_id': externalId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'episodes': episodes?.map((e) => e.toJson()).toList(),
    };
  }
}

class Episode {
  final int id;
  final String externalId;
  final int podcastId;
  final String name;
  final String description;
  final String audioUrl;
  final String? imageUrl;
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
    this.imageUrl,
    required this.datePublished,
    required this.duration,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Episode.fromJson(Map<String, dynamic> json) {
    return Episode(
      id: json['id'] as int,
      externalId: json['external_id'] as String,
      podcastId: json['podcast_id'] as int,
      name: json['name'] as String,
      description: json['description'] as String,
      audioUrl: json['audio_url'] as String,
      imageUrl: json['image_url'] as String?,
      datePublished: json['date_published'] as String,
      duration: json['duration'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'external_id': externalId,
      'podcast_id': podcastId,
      'name': name,
      'description': description,
      'audio_url': audioUrl,
      'image_url': imageUrl,
      'date_published': datePublished,
      'duration': duration,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
