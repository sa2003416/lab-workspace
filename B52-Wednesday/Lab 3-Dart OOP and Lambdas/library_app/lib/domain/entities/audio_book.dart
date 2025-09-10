import 'package:library_app/domain/entities/book.dart';

class AudioBook extends Book {
  int size;
  int length;
  String artistName;

  AudioBook({
    required super.name,
    required super.author,
    required super.yearOfPublication,
    required this.size,
    required this.length,
    required this.artistName,
  });

  
}
