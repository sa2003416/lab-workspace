import 'package:digital_library/features/library_items/domain/entities/audiobook.dart';
import 'package:digital_library/features/library_items/domain/entities/library_item.dart';
import 'package:digital_library/features/members/domain/contracts/payable.dart';
import 'member.dart';

class StudentMember extends Member implements Payable {
  final String studentId;
  double _outstanding = 0.0;

  StudentMember({
    required super.memberId,
    required this.studentId,
    required super.name,
    required super.email,
    required super.joinDate,
    super.profileImageUrl,
  }) : super(maxBorrowLimit: 5, borrowPeriod: 14);

  @override
  String getMemberType() => 'Student';

  @override
  bool canBorrowItem(LibraryItem item) {
    if (!super.canBorrowItem(item)) return false;
    // Additional student-specific restriction example: no more than 2 audiobooks at a time
    final currentAudio = borrowedItems
        .where((b) => !b.isReturned && b.item is AudioBook)
        .length;
    return currentAudio < 2;
  }

  @override
  double calculateFees(DateTime now) {
    final late = borrowedItems
        .map((b) => b.calculateLateFee(now: now))
        .fold<double>(0.0, (acc, f) => acc + f);
    _outstanding = late;
    return _outstanding;
  }

  @override
  bool payFees(double amount) {
    if (amount <= 0) return false;
    _outstanding = (_outstanding - amount).clamp(0.0, double.infinity);
    return true;
  }
}
