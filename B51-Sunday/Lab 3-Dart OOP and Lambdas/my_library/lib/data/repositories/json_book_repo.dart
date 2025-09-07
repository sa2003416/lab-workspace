import 'package:my_library/domain/contracts/book_repo.dart';
import 'package:my_library/domain/entities/book.dart';

class JsonBookRepo implements BookRepo {
  List<Book> books = [];

  // method that will read from the json

  @override
  void addBook(Book book) {
    books.add(book);
  }

  @override
  void deleteBook(String name) {
    // challenge
  }

  @override
  List<Book> getBooks() {
    return books;
  }

  @override
  void updateBook(Book book) {
    // challenge
  }
}
