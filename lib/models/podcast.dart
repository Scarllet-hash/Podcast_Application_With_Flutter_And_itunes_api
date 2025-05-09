class Podcast {
  final String title;
  final String imageUrl;
  final String author;
  final String audioUrl;

  Podcast({required this.title, required this.imageUrl, required this.author, required this.audioUrl});

  factory Podcast.fromJson(Map<String, dynamic> json) {
    return Podcast(
      title: json['collectionName'] ?? 'No title',
      imageUrl: json['artworkUrl600'] ?? '',
      author: json['artistName'] ?? 'Unknown author',
      audioUrl: json['feedUrl'] ?? '',
    );
  }
}
