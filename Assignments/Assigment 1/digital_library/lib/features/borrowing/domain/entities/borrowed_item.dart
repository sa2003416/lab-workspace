import 'package:digital_library/features/library_items/domain/entities/library_item.dart';

class BorrowedItem {
  final LibraryItem item;
  final DateTime borrowDate;
  DateTime dueDate;
  DateTime? returnDate;
  bool isReturned;

  BorrowedItem({
    required this.item,
    required this.borrowDate,
    required this.dueDate,
    this.returnDate,
    this.isReturned = false,
  });

  bool isOverdue(DateTime now) => !isReturned && now.isAfter(dueDate);

  int getDaysOverdue(DateTime now) =>
      isOverdue(now) ? now.difference(dueDate).inDays.clamp(1, 1000000) : 0;

  double calculateLateFee({
    int feePerDay = 2,
    int maxPerItem = 50,
    required DateTime now,
  }) {
    final days = getDaysOverdue(now);
    final fee = days * feePerDay;
    return fee > maxPerItem ? maxPerItem.toDouble() : fee.toDouble();
  }

  void extendDueDate(int additionalDays) {
    if (additionalDays <= 0) throw ArgumentError('additionalDays must be > 0');
    dueDate = dueDate.add(Duration(days: additionalDays));
  }

  void processReturn() {
    if (isReturned) return;
    isReturned = true;
    returnDate = DateTime.now();
  }
}
