import 'package:digital_library/features/borrowing/domain/entities/borrowed_item.dart';
import 'package:digital_library/features/library_items/domain/entities/library_item.dart';

abstract class Member {
  final String memberId;
  final String name;
  final String email;
  final DateTime joinDate;
  final List<BorrowedItem> borrowedItems;
  final int maxBorrowLimit;
  final int borrowPeriod; // days
  final String? profileImageUrl;

  Member({
    required this.memberId,
    required this.name,
    required this.email,
    required this.joinDate,
    required this.maxBorrowLimit,
    required this.borrowPeriod,
    this.profileImageUrl,
    List<BorrowedItem>? borrowedItems,
  }) : borrowedItems = borrowedItems ?? <BorrowedItem>[];

  String getMemberType();

  bool canBorrowItem(LibraryItem item) {
    final withinLimit =
        borrowedItems.where((b) => !b.isReturned).length < maxBorrowLimit;
    return withinLimit && item.isAvailable;
  }

  List<BorrowedItem> getBorrowingHistory() =>
      borrowedItems.toList(growable: false);

  List<BorrowedItem> getOverdueItems(DateTime now) =>
      borrowedItems.where((b) => b.isOverdue(now)).toList(growable: false);

  String getMembershipSummary(DateTime now) {
    final active = borrowedItems.where((b) => !b.isReturned).length;
    final overdue = getOverdueItems(now).length;
    return '$name [$memberId] · ${getMemberType()} · Active: $active · Overdue: $overdue';
  }
}
