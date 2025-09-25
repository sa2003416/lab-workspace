import 'library_item.dart';

class AudioBook extends LibraryItem {
  final double duration; // hours
  final String narrator;
  final double fileSize; // MB

  AudioBook({
    required super.id,
    required super.title,
    required super.authors,
    required super.publishedYear,
    required super.category,
    required super.isAvailable,
    super.coverImageUrl,
    super.description,
    required this.duration,
    required this.narrator,
    required this.fileSize,
  });

  @override
  String getItemType() => 'AudioBook';

  @override
  String getDisplayInfo() =>
      '"$title" narrated by $narrator · ${duration.toStringAsFixed(1)}h · $publishedYear';

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'type': 'AudioBook',
    'title': title,
    'authorIds': authors.map((a) => a.id).toList(),
    'publishedYear': publishedYear,
    'category': category,
    'isAvailable': isAvailable,
    'coverImageUrl': coverImageUrl,
    'description': description,
    'duration': duration,
    'narrator': narrator,
    'fileSize': fileSize,
  };
}
