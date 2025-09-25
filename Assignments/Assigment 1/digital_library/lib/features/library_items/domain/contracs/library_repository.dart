import 'package:digital_library/features/library_items/domain/entities/library_item.dart';

abstract class LibraryRepository {
  Future<List<LibraryItem>> getAllItems();
  Future<LibraryItem> getItem(String id);
  Future<List<LibraryItem>> searchItems(String query);
  Future<List<LibraryItem>> getItemsByCategory(String category);
  Future<List<LibraryItem>> getAvailableItems();
  Future<List<LibraryItem>> getItemsByAuthor(String authorId);
}
