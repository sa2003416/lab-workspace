import 'package:digital_library/features/library_items/domain/entities/audiobook.dart';
import 'package:digital_library/features/library_items/domain/entities/book.dart';
import 'package:digital_library/features/library_items/domain/entities/library_item.dart';

extension LibraryItemExtensions on List<LibraryItem> {
  List<LibraryItem> filterByAuthor(String authorName) {
    final q = authorName.toLowerCase();
    return where(
      (i) => i.authors.any((a) => a.name.toLowerCase().contains(q)),
    ).toList(growable: false);
  }

  List<LibraryItem> filterByCategory(String category) {
    final c = category.toLowerCase();
    return where((i) => i.category.toLowerCase() == c).toList(growable: false);
  }

  List<LibraryItem> sortByRating() => toList(growable: false)
    ..sort((a, b) {
      final ar = a.getAverageRating();
      final br = b.getAverageRating();
      final byRating = br.compareTo(ar);
      return byRating != 0
          ? byRating
          : b.getReviewCount().compareTo(a.getReviewCount());
    });

  Map<String, List<LibraryItem>> groupByCategory() =>
      fold<Map<String, List<LibraryItem>>>(
        <String, List<LibraryItem>>{},
        (map, item) => {
          ...map,
          item.category: [
            ...(map[item.category] ?? const <LibraryItem>[]),
            item,
          ],
        },
      );

  double getPopularityScore() {
    // Weighted: 70% average rating (scaled 0..1), 30% normalized review count
    if (isEmpty) return 0.0;
    final avgRating =
        fold<double>(0.0, (acc, i) => acc + i.getAverageRating()) / length;
    final maxReviews = fold<int>(
      0,
      (m, i) => i.getReviewCount() > m ? i.getReviewCount() : m,
    );
    final reviewFactor = maxReviews == 0
        ? 0.0
        : fold<double>(
                0.0,
                (acc, i) => acc + (i.getReviewCount() / maxReviews),
              ) /
              length;
    final score = 0.7 * (avgRating / 5.0) + 0.3 * reviewFactor;
    return double.parse(score.toStringAsFixed(4));
  }

  List<LibraryItem> findSimilarItems(LibraryItem item, int maxResults) => where(
    (i) =>
        i.id != item.id &&
        (i.category.toLowerCase() == item.category.toLowerCase() ||
            i.authors.any((a) => item.authors.any((b) => b.id == a.id))),
  ).toList(growable: false).take(maxResults).toList(growable: false);

  Map<String, dynamic> getReadingTimeEstimate() {
    // Books: 250 wpp, 200 wpm => minutes = pages * 250 / 200
    // Audiobooks: duration hours as-is
    final books = whereType<Book>();
    final audiobooks = whereType<AudioBook>();

    final bookMinutes = books
        .map((b) => (b.pageCount * 250) / 200)
        .fold<double>(0.0, (acc, m) => acc + m);
    final audioHours = audiobooks
        .map((a) => a.duration)
        .fold<double>(0.0, (acc, h) => acc + h);

    return {
      'totalBookMinutes': bookMinutes,
      'totalAudioHours': audioHours,
      'itemsCount': length,
    };
  }

  Map<String, dynamic> analyzeCollectionHealth() {
    if (isEmpty) {
      return {
        'total': 0,
        'availabilityPct': 0.0,
        'avgRating': 0.0,
        'categories': <String, int>{},
      };
    }
    final total = length;
    final available = where((i) => i.isAvailable).length;
    final avgRating =
        fold<double>(0.0, (acc, i) => acc + i.getAverageRating()) / total;
    final categories = fold<Map<String, int>>(
      <String, int>{},
      (map, item) => {...map, item.category: (map[item.category] ?? 0) + 1},
    );
    return {
      'total': total,
      'availabilityPct': double.parse(
        ((available / total) * 100).toStringAsFixed(2),
      ),
      'avgRating': double.parse(avgRating.toStringAsFixed(2)),
      'categories': categories,
    };
  }
}
