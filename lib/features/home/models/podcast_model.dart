class Podcast {
  final String id;
  final String name;
  final String author;
  final String audioUrl;
  final String thumbnailUrl;
  final String color;

  Podcast({
    required this.id,
    required this.name,
    required this.author,
    required this.audioUrl,
    required this.thumbnailUrl,
    required this.color,
  });

  // Factory constructor to create a Podcast object from a JSON map
  factory Podcast.fromJson(Map<String, dynamic> json) {
    return Podcast(
      id: json['id'] as String,
      name: json['podcast_name'] as String,
      author: json['author'] as String,
      audioUrl: json['podcast_audio'] as String,
      thumbnailUrl: json['thumbnail'] as String,
      color: json['color'] as String,
    );
  }

  // Method to convert Podcast object to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'podcast_name': name,
      'author': author,
      'podcast_audio': audioUrl,
      'thumbnail': thumbnailUrl,
      'color': color,
    };
  }

  // Override toString for easy printing of Podcast objects
  @override
  String toString() {
    return 'Podcast{ id: $id, name: $name, author: $author, audioUrl: $audioUrl, thumbnailUrl: $thumbnailUrl, color: $color }';
  }

  // Override == operator for comparison
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Podcast &&
        other.id == id &&
        other.name == name &&
        other.author == author &&
        other.audioUrl == audioUrl &&
        other.thumbnailUrl == thumbnailUrl &&
        other.color == color;
  }

  // Override hashCode
  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        author.hashCode ^
        audioUrl.hashCode ^
        thumbnailUrl.hashCode ^
        color.hashCode;
  }

  // Copywidth method for creating a new Podcast object with some updated fields
  Podcast copyWith({
    String? id,
    String? name,
    String? author,
    String? audioUrl,
    String? thumbnailUrl,
    String? color,
  }) {
    return Podcast(
      id: id ?? this.id,
      name: name ?? this.name,
      author: author ?? this.author,
      audioUrl: audioUrl ?? this.audioUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      color: color ?? this.color,
    );
  }
}
