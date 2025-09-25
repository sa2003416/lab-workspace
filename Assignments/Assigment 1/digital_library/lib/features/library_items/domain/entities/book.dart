import 'library_item.dart';

class Book extends LibraryItem {
  final int pageCount;
  final String isbn;
  final String publisher;

  Book({
    required super.id,
    required super.title,
    required super.authors,
    required super.publishedYear,
    required super.category,
    required super.isAvailable,
    super.coverImageUrl,
    super.description,
    required this.pageCount,
    required this.isbn,
    required this.publisher,
  });

  @override
  String getItemType() => 'Book';

  @override
  String getDisplayInfo() =>
      '"$title" by ${authors.map((a) => a.getDisplayName()).join(', ')} · $pageCount pages · $publisher ($publishedYear)';

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'type': 'Book',
    'title': title,
    'authorIds': authors.map((a) => a.id).toList(),
    'publishedYear': publishedYear,
    'category': category,
    'isAvailable': isAvailable,
    'coverImageUrl': coverImageUrl,
    'description': description,
    'pageCount': pageCount,
    'isbn': isbn,
    'publisher': publisher,
  };
}
