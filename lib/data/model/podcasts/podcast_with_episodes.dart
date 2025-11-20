import 'package:cribe/domain/models/podcast.dart';

class PodcastWithEpisodes {
  final int id;
  final String authorName;
  final String name;
  final String imageUrl;
  final String description;
  final String externalId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<Episode> episodes;

  PodcastWithEpisodes({
    required this.id,
    required this.authorName,
    required this.name,
    required this.imageUrl,
    required this.description,
    required this.externalId,
    required this.createdAt,
    required this.updatedAt,
    required this.episodes,
  });

  factory PodcastWithEpisodes.fromJson(dynamic json) {
    final map = json as Map<String, dynamic>;
    return PodcastWithEpisodes(
      id: map['id'] as int? ?? 0,
      authorName: map['authorName'] as String? ?? '',
      name: map['name'] as String? ?? '',
      imageUrl: map['imageUrl'] as String? ?? '',
      description: map['description'] as String? ?? '',
      externalId: map['externalId'] as String? ?? '',
      createdAt: DateTime.parse(map['createdAt'] as String? ?? ''),
      updatedAt: DateTime.parse(map['updatedAt'] as String? ?? ''),
      episodes: (map['episodes'] as List<dynamic>? ?? [])
          .map((e) => Episode.fromJson(e))
          .toList(),
    );
  }
}
