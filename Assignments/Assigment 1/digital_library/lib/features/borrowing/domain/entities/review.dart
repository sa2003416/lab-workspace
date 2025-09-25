import 'package:digital_library/features/library_items/domain/entities/author.dart';

class Review implements JsonSerializable<Review> {
  final int rating; // 1..5
  final String comment;
  final String reviewerName;
  final DateTime reviewDate;
  final String itemId;

  const Review({
    required this.rating,
    required this.comment,
    required this.reviewerName,
    required this.reviewDate,
    required this.itemId,
  });

  bool isValidRating() => rating >= 1 && rating <= 5;

  int getWordCount() =>
      comment.trim().split(RegExp(r"\s+")).where((w) => w.isNotEmpty).length;

  @override
  Map<String, dynamic> toJson() => {
    'rating': rating,
    'comment': comment,
    'reviewerName': reviewerName,
    'reviewDate': reviewDate.toIso8601String(),
    'itemId': itemId,
  };

  factory Review.fromJson(Map<String, dynamic> json) => Review(
    rating: json['rating'] as int,
    comment: json['comment'] as String,
    reviewerName: json['reviewerName'] as String,
    reviewDate: DateTime.parse(json['reviewDate'] as String),
    itemId: json['itemId'] as String,
  );
}
