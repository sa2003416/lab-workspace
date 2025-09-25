import 'package:digital_library/features/borrowing/domain/entities/borrowed_item.dart';
import 'package:digital_library/features/library_items/core/utils/library_item_extentions.dart';
import 'package:digital_library/features/library_items/domain/contracs/library_repository.dart';
import 'package:digital_library/features/library_items/domain/entities/library_item.dart';
import 'package:digital_library/features/members/domain/contracts/member_repository.dart';
import 'package:digital_library/features/members/domain/contracts/payable.dart';
import 'package:digital_library/features/members/domain/entities/student_member.dart';

class LibrarySystem {
  final LibraryRepository libraryRepo;
  final MemberRepository memberRepo;

  // reservation queues: itemId -> queue of memberIds
  final Map<String, List<String>> _reservations = {};

  LibrarySystem({required this.libraryRepo, required this.memberRepo});

  Future<BorrowedItem> borrowItem(String memberId, String itemId) async {
    final member = await memberRepo.getMember(memberId);
    final item = await libraryRepo.getItem(itemId);

    if (!member.canBorrowItem(item)) {
      throw StateError('Member not eligible or item unavailable');
    }

    final borrowDate = DateTime.now();
    final dueDate = borrowDate.add(Duration(days: member.borrowPeriod));
    final record = BorrowedItem(
      item: item,
      borrowDate: borrowDate,
      dueDate: dueDate,
    );

    item.isAvailable = false;
    member.borrowedItems.add(record);
    await memberRepo.updateMember(member);

    return record;
  }

  Future<double> returnItem(String memberId, String itemId) async {
    final member = await memberRepo.getMember(memberId);
    final now = DateTime.now();

    final record = member.borrowedItems.firstWhere(
      (b) => b.item.id == itemId && !b.isReturned,
      orElse: () => throw StateError('Borrow record not found'),
    );

    record.processReturn();

    // Calculate fees if any
    double fee = 0.0;
    if (member is StudentMember) {
      fee = record.calculateLateFee(now: now);
      if (fee > 0) {
        (member as StudentMember).calculateFees(now); // update outstanding
      }
    }

    // Make item available or assign to next reservation
    record.item.isAvailable = true;
    final queue = _reservations[record.item.id];
    if (queue != null && queue.isNotEmpty) {
      // next in queue will borrow next time they call borrow
      // keep available=true so they can borrow; or auto-assign if desired.
    }

    await memberRepo.updateMember(member);
    return fee;
  }

  Future<List<Map<String, dynamic>>> generateOverdueReport(DateTime now) async {
    final members = await memberRepo.getAllMembers();
    final rows = members
        .expand(
          (m) => m
              .getOverdueItems(now)
              .map(
                (b) => {
                  'memberId': m.memberId,
                  'memberName': m.name,
                  'itemId': b.item.id,
                  'title': b.item.title,
                  'daysOverdue': b.getDaysOverdue(now),
                  'calculatedFee': (m is StudentMember)
                      ? b.calculateLateFee(now: now)
                      : 0.0,
                },
              ),
        )
        .toList(growable: false);
    return rows;
  }

  Future<List<LibraryItem>> recommendItems(
    String memberId,
    int maxRecommendations,
  ) async {
    final member = await memberRepo.getMember(memberId);
    final items = await libraryRepo.getAllItems();

    final history = member.borrowedItems.map((b) => b.item).toList();
    if (history.isEmpty) {
      return items
          .where((i) => i.isAvailable)
          .take(maxRecommendations)
          .toList(growable: false);
    }

    final topCategories =
        history
            .map((i) => i.category)
            .fold<Map<String, int>>(
              <String, int>{},
              (map, c) => {...map, c: (map[c] ?? 0) + 1},
            )
            .entries
            .toList()
          ..sort((a, b) => b.value.compareTo(a.value));

    final favCategory = topCategories.first.key;

    final candidates = items
        .where(
          (i) =>
              i.isAvailable &&
              i.category == favCategory &&
              !history.any((h) => h.id == i.id),
        )
        .toList(growable: false)
        .sortByRating();

    return candidates.take(maxRecommendations).toList(growable: false);
  }

  Future<Map<String, dynamic>> processMonthlyReport(DateTime now) async {
    final items = await libraryRepo.getAllItems();
    final members = await memberRepo.getAllMembers();

    final popularItems = items
        .sortByRating()
        .take(5)
        .map((i) => i.title)
        .toList();
    final activeMembers = members
        .where(
          (m) => m.borrowedItems.any(
            (b) =>
                b.borrowDate.month == now.month &&
                b.borrowDate.year == now.year,
          ),
        )
        .map((m) => m.name)
        .toList();

    final revenue = members
        .map((m) => m is Payable ? (m as Payable).calculateFees(now) : 0.0)
        .fold<double>(0.0, (acc, f) => acc + f);

    return {
      'popularItems': popularItems,
      'activeMembers': activeMembers,
      'estimatedRevenueFromFees': double.parse(revenue.toStringAsFixed(2)),
    };
  }

  void handleReservation(String memberId, String itemId) {
    final q = _reservations[itemId] ?? <String>[];
    if (!q.contains(memberId)) {
      _reservations[itemId] = [...q, memberId];
    }
  }
}
