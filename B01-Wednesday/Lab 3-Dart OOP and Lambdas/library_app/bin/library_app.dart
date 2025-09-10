import 'package:library_app/data/repositories/json_book_repo.dart';
import 'package:library_app/library_app.dart' as library_app;

void main(List<String> arguments) {
  JsonBookRepo repo = JsonBookRepo();
  print(repo.getBooks());
}
