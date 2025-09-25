import 'package:digital_library/features/borrowing/domain/entities/review.dart';

mixin Reviewable {
  final List<Review> reviews = <Review>[];

  void addReview(Review review) {
    if (!review.isValidRating()) {
      throw ArgumentError('Rating must be between 1 and 5');
    }
    if (hasReviewFromUser(review.reviewerName)) {
      throw StateError('Duplicate review from ${review.reviewerName}');
    }
    reviews.add(review);
  }

  bool hasReviewFromUser(String userName) => reviews.any(
    (r) => r.reviewerName.toLowerCase() == userName.toLowerCase(),
  );

  double getAverageRating() {
    if (reviews.isEmpty) return 0.0;
    final total = reviews.fold<int>(0, (acc, r) => acc + r.rating);
    return total / reviews.length;
  }

  int getReviewCount() => reviews.length;

  List<Review> getTopReviews(int count) => reviews.toList()
    ..sort((a, b) {
      final byRating = b.rating.compareTo(a.rating);
      return byRating != 0 ? byRating : b.reviewDate.compareTo(a.reviewDate);
    })
    ..sublist(0, count.clamp(0, reviews.length));
}
