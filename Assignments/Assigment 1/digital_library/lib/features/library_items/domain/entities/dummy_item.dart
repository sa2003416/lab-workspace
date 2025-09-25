import 'package:digital_library/features/library_items/data/repositories/json_library_repository.dart';

import 'library_item.dart';
import 'author.dart';

class DummyItem extends LibraryItem {
  DummyItem({
    required super.id,
    required super.title,
    required super.authors,
    required super.publishedYear,
    required super.category,
    required super.isAvailable,
    super.coverImageUrl,
    super.description,
  });

  @override
  String getItemType() => "Dummy";

  @override
  String getDisplayInfo() => "Dummy item: $title";

  @override
  Map<String, dynamic> toJson() => {"type": "Dummy", "id": id, "title": title};
}

//i used get this main code from ChatGPT to test my files.
void main() {
  final item = DummyItem(
    id: "1",
    title: "Test Title",
    authors: [Author(id: "a1", name: "Am Faisal")],
    publishedYear: 2025,
    category: "Testing",
    isAvailable: true,
  );

  print(item.getItemType());
  print(item.getDisplayInfo());
  print(item.toJson());
}
