import 'package:digital_library/features/members/domain/contracts/payable.dart';
import 'package:digital_library/features/members/domain/entities/faculty_member.dart';
import 'package:digital_library/features/members/domain/entities/member.dart';
import 'package:digital_library/features/members/domain/entities/student_member.dart';

extension MemberExtensions on List<Member> {
  List<T> filterByType<T extends Member>() =>
      whereType<T>().toList(growable: false);

  List<Member> getMembersWithOverdueItems(DateTime now) =>
      where((m) => m.getOverdueItems(now).isNotEmpty).toList(growable: false);

  double calculateTotalFees(DateTime now) => map(
    (m) => m is Payable ? (m as Payable).calculateFees(now) : 0.0,
  ).fold<double>(0.0, (acc, f) => acc + f);

  Map<String, dynamic> analyzeBorrowingPatterns() {
    final allBorrowedCounts = map((m) => m.borrowedItems.length).toList();
    final avgBooksPerMember = allBorrowedCounts.isEmpty
        ? 0.0
        : allBorrowedCounts.fold<int>(0, (acc, c) => acc + c) /
              allBorrowedCounts.length;

    final mostActive = isEmpty
        ? <Member>[]
        : fold<List<Member>>(<Member>[], (acc, m) {
            if (acc.isEmpty) return [m];
            final top = acc.first.borrowedItems.length;
            final current = m.borrowedItems.length;
            if (current > top) return [m];
            if (current == top) return [...acc, m];
            return acc;
          });

    final popularCategoriesByType = <String, String>{
      'Student': _mostPopularCategory(whereType<StudentMember>().toList()),
      'Faculty': _mostPopularCategory(whereType<FacultyMember>().toList()),
    };

    return {
      'avgPerMember': double.parse(avgBooksPerMember.toStringAsFixed(2)),
      'mostActive': mostActive.map((m) => m.name).toList(),
      'popularCategoriesByType': popularCategoriesByType,
    };
  }

  String _mostPopularCategory(List<Member> ms) {
    final counts = ms
        .expand((m) => m.borrowedItems.map((b) => b.item.category))
        .fold<Map<String, int>>(
          <String, int>{},
          (map, c) => {...map, c: (map[c] ?? 0) + 1},
        );
    if (counts.isEmpty) return 'N/A';
    final sorted = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.first.key;
  }

  List<Member> getMembersByActivity(DateTime since) => where(
    (m) => m.borrowedItems.any((b) => b.borrowDate.isAfter(since)),
  ).toList(growable: false);

  List<Member> getRiskMembers(int overdueDaysThreshold, DateTime now) => where(
    (m) => m
        .getOverdueItems(now)
        .any((b) => b.getDaysOverdue(now) >= overdueDaysThreshold),
  ).toList(growable: false);

  Map<String, dynamic> generateMembershipReport(DateTime now) {
    final studentCount = whereType<StudentMember>().length;
    final facultyCount = whereType<FacultyMember>().length;
    final totalFees = calculateTotalFees(now);
    final activity = analyzeBorrowingPatterns();

    return {
      'counts': {'Student': studentCount, 'Faculty': facultyCount},
      'totalFees': totalFees,
      'activity': activity,
    };
  }
}
