import 'dart:io';
import 'package:digital_library/features/borrowing/domain/entities/review.dart';
import 'package:digital_library/features/borrowing/domain/services/library_system.dart';
import 'package:digital_library/features/library_items/core/utils/library_item_extentions.dart';
import 'package:digital_library/features/library_items/data/repositories/json_library_repository.dart';
import 'package:digital_library/features/library_items/domain/entities/library_item.dart';
import 'package:digital_library/features/members/data/repositories/json_member_repository.dart';

Future<void> main(List<String> args) async {
  // Accept custom paths or default to provided filenames from the assignment upload
  final base = args.isNotEmpty ? args[0] : Directory.current.path;

  // Support both naming styles: "authors.json" and "authors_json.json"
  String resolve(String a, String b) {
    final pa = File(a);
    final pb = File(b);
    if (pa.existsSync()) return pa.path;
    if (pb.existsSync()) return pb.path;
    return a; // fallback
  }

  final authorsPath = resolve(
    '$base/assets/data/authors.json',
    '$base/assets/data/authors_json.json',
  );
  final catalogPath = resolve(
    '$base/assets/data/library-catalog.json',
    '$base/assets/data/library_catalog_json.json',
  );
  final membersPath = resolve(
    '$base/assets/data/members.json',
    '$base/assets/data/members_json.json',
  );

  final libraryRepo = JsonLibraryRepository(
    catalogPath: catalogPath,
    authorsPath: authorsPath,
  );

  final memberRepo = JsonMemberRepository(membersPath: membersPath);
  final system = LibrarySystem(
    libraryRepo: libraryRepo,
    memberRepo: memberRepo,
  );

  // Load data
  final items = await libraryRepo.getAllItems();
  final members = await memberRepo.getAllMembers();

  // Basic search
  final aiItems = await libraryRepo.searchItems('AI'); // searching method
  // Reviews
  if (items.isNotEmpty) {
    final i0 = items.first;
    i0.addReview(
      Review(
        rating: 5,
        comment: 'Excellent',
        reviewerName: 'Alice',
        reviewDate: DateTime.now(),
        itemId: i0.id,
      ),
    );
    i0.addReview(
      Review(
        rating: 4,
        comment: 'Solid',
        reviewerName: 'Bob',
        reviewDate: DateTime.now(),
        itemId: i0.id,
      ),
    );
  }
  final popularity = items.getPopularityScore();
  final groups = items.groupByCategory();
  final health = items.analyzeCollectionHealth(); //

  if (members.isNotEmpty && items.isNotEmpty) {
    final m0 = members.first;
    final available = items.firstWhere(
      (i) => i.isAvailable,
      orElse: () => items.first,
    );
    try {
      final rec = await system.borrowItem(m0.memberId, available.id);
      stdout.writeln(
        'Borrowed: ${rec.item.title} by ${m0.name}, due ${rec.dueDate}',
      );
    } catch (e) {
      stdout.writeln('Borrow failed: $e');
    }
  }

  // Overdue report (simulate by moving due dates backwards)
  final now = DateTime.now();
  members.forEach(
    (m) => m.borrowedItems.forEach(
      (b) => b.dueDate = now.subtract(Duration(days: 3)),
    ),
  );
  final overdue = await system.generateOverdueReport(now);

  // Monthly report
  final monthly = await system.processMonthlyReport(now);

  // Output demo
  stdout
    ..writeln('Search "AI" -> ${aiItems.map((e) => e.title).toList()}')
    ..writeln('Popularity score = $popularity')
    ..writeln('Groups = ${groups.map((k, v) => MapEntry(k, v.length))}')
    ..writeln('Health = $health')
    ..writeln('Overdue rows = ${overdue.length}')
    ..writeln('Monthly = $monthly');
}
