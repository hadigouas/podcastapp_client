import 'package:flutter_application_3/features/home/models/podcast_model.dart';

class Favorite {
  final String id;
  final String podcastId;
  final String userId;
  final Podcast podcast;

  Favorite({
    required this.id,
    required this.podcastId,
    required this.userId,
    required this.podcast,
  });

  factory Favorite.fromJson(Map<String, dynamic> json) {
    return Favorite(
      id: json['id'],
      podcastId: json['podcast_id'],
      userId: json['user_id'],
      podcast: Podcast.fromJson(json['podcast']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'podcast_id': podcastId,
      'user_id': userId,
      'podcast': podcast.toJson(),
    };
  }
}
