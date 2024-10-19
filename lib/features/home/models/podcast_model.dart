class Podcast {
  final String id;
  final String name;
  final String author;
  final String audioUrl;
  final String thumbnailUrl;

  Podcast({
    required this.id,
    required this.name,
    required this.author,
    required this.audioUrl,
    required this.thumbnailUrl,
  });

  // Factory constructor to create a Podcast object from a JSON map
  factory Podcast.fromJson(Map<String, dynamic> json) {
    return Podcast(
      id: json['id'] as String,
      name: json['name'] as String,
      author: json['author'] as String,
      audioUrl: json['audio_url'] as String,
      thumbnailUrl: json['thumbnail_url'] as String,
    );
  }

  // Method to convert Podcast object to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'author': author,
      'audio_url': audioUrl,
      'thumbnail_url': thumbnailUrl,
    };
  }

  // Override toString for easy printing of Podcast objects
  @override
  String toString() {
    return 'Podcast{ name: $name, author: $author, audioUrl: $audioUrl, thumbnailUrl: $thumbnailUrl';
  }

  // Override == operator for comparison
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Podcast &&
        other.name == name &&
        other.author == author &&
        other.audioUrl == audioUrl &&
        other.thumbnailUrl == thumbnailUrl;
  }

  // Override hashCode
  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        author.hashCode ^
        audioUrl.hashCode ^
        thumbnailUrl.hashCode;
  }

  // Copywidth method for creating a new Podcast object with some updated fields
  Podcast copyWith({
    String? id,
    String? name,
    String? author,
    String? audioUrl,
    String? thumbnailUrl,
    String? userId,
  }) {
    return Podcast(
      id: id ?? this.id,
      name: name ?? this.name,
      author: author ?? this.author,
      audioUrl: audioUrl ?? this.audioUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
    );
  }
}
