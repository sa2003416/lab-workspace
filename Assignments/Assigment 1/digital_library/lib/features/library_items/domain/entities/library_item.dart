import 'book.dart';
import 'audiobook.dart';
import 'author.dart';
import '../mixins/reviewable.dart';

abstract class LibraryItem
    with Reviewable
    implements JsonSerializable<LibraryItem> {
  final String id;
  final String title;
  final List<Author> authors;
  final int publishedYear;
  final String category;
  bool isAvailable;
  final String? coverImageUrl;
  final String? description;

  LibraryItem({
    required this.id,
    required this.title,
    required this.authors,
    required this.publishedYear,
    required this.category,
    required this.isAvailable,
    this.coverImageUrl,
    this.description,
  });

  String getItemType();
  String getDisplayInfo();

  factory LibraryItem.fromJson(
    Map<String, dynamic> json,
    Map<String, Author> authorsById,
  ) {
    final type = json['type'] as String? ?? 'Book';
    final authorIds =
        (json['authorIds'] as List?)?.cast<String>() ?? const <String>[];
    final itemAuthors = authorIds
        .map((id) => authorsById[id])
        .whereType<Author>()
        .toList();

    switch (type) {
      case 'AudioBook':
        return AudioBook(
          id: json['id'] as String,
          title: json['title'] as String,
          authors: itemAuthors,
          publishedYear: json['publishedYear'] as int,
          category: json['category'] as String,
          isAvailable: json['isAvailable'] as bool? ?? true,
          coverImageUrl: json['coverImageUrl'] as String?,
          description: json['description'] as String?,
          duration: (json['duration'] as num?)?.toDouble() ?? 0.0,
          narrator: json['narrator'] as String? ?? 'Unknown',
          fileSize: (json['fileSize'] as num?)?.toDouble() ?? 0.0,
        );
      case 'Book':
      default:
        return Book(
          id: json['id'] as String,
          title: json['title'] as String,
          authors: itemAuthors,
          publishedYear: json['publishedYear'] as int,
          category: json['category'] as String,
          isAvailable: json['isAvailable'] as bool? ?? true,
          coverImageUrl: json['coverImageUrl'] as String?,
          description: json['description'] as String?,
          pageCount: json['pageCount'] is int
              ? json['pageCount'] as int
              : (json['pageCount'] as num?)?.toInt() ?? 0,
          isbn: json['isbn'] as String? ?? '',
          publisher: json['publisher'] as String? ?? '',
        );
    }
  }
}
