// what the app should do not how it should do it
import 'package:library_app/domain/entities/book.dart';

abstract class BookRepo {
  List<Book> getBooks();
  Book addBook(Book book);
  String deleteBook(String name);
  Book updateBook(Book book);
  Book getBook(String name);
}
