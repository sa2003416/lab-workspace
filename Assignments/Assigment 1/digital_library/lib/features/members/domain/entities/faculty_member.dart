import 'package:digital_library/features/library_items/domain/entities/library_item.dart';

import 'member.dart';

class FacultyMember extends Member {
  final String department;

  FacultyMember({
    required super.memberId,
    required this.department,
    required super.name,
    required super.email,
    required super.joinDate,
    super.profileImageUrl,
  }) : super(maxBorrowLimit: 20, borrowPeriod: 60);

  @override
  String getMemberType() => 'Faculty';

  @override
  bool canBorrowItem(LibraryItem item) {
    // Faculty can borrow regardless of current availability if item is reservable (example policy),
    // but keep default check to respect availability for simplicity.
    return super.canBorrowItem(item);
  }
}
