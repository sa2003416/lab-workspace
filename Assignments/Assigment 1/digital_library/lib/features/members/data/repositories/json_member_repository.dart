import 'dart:convert';
import 'dart:io';

import 'package:digital_library/features/members/domain/contracts/member_repository.dart';
import 'package:digital_library/features/members/domain/entities/faculty_member.dart';
import 'package:digital_library/features/members/domain/entities/member.dart';
import 'package:digital_library/features/members/domain/entities/student_member.dart';

class JsonMemberRepository implements MemberRepository {
  final String membersPath;
  List<Member>? _cache;

  JsonMemberRepository({required this.membersPath});

  Future<List<Member>> _load() async {
    if (_cache != null) return _cache!;
    try {
      final raw = await File(membersPath).readAsString();
      final list = (jsonDecode(raw) as List<dynamic>)
          .cast<Map<String, dynamic>>();
      _cache = list.map(_fromJson).toList(growable: true);
      return _cache!;
    } catch (e) {
      throw FileSystemException('Failed to load members: $e');
    }
  }

  Member _fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String? ?? 'StudentMember';
    switch (type) {
      case 'FacultyMember':
        return FacultyMember(
          memberId: json['memberId'] as String,
          department: json['department'] as String? ?? 'Unknown',
          name: json['name'] as String,
          email: json['email'] as String,
          joinDate: DateTime.parse(json['joinDate'] as String),
          profileImageUrl: json['profileImageUrl'] as String?,
        );
      case 'StudentMember':
      default:
        return StudentMember(
          memberId: json['memberId'] as String,
          studentId: json['studentId'] as String? ?? 'N/A',
          name: json['name'] as String,
          email: json['email'] as String,
          joinDate: DateTime.parse(json['joinDate'] as String),
          profileImageUrl: json['profileImageUrl'] as String?,
        );
    }
  }

  @override
  Future<void> addMember(Member member) async {
    final list = await _load();
    final exists = list.any(
      (m) => m.memberId == member.memberId || m.email == member.email,
    );
    if (exists) throw StateError('Duplicate memberId or email');
    list.add(member);
    await _persist();
  }

  @override
  Future<List<Member>> getAllMembers() async => await _load();

  @override
  Future<Member> getMember(String memberId) async => (await _load()).firstWhere(
    (m) => m.memberId == memberId,
    orElse: () => throw StateError('Member not found'),
  );

  @override
  Future<void> updateMember(Member member) async {
    final list = await _load();
    final idx = list.indexWhere((m) => m.memberId == member.memberId);
    if (idx < 0) throw StateError('Member not found');
    list[idx] = member;
    await _persist();
  }

  Future<void> _persist() async {
    // Simple persistence: members are readonly in the assignment, but implement basic write-out for completeness.
    final list = _cache!;
    // Serialize minimally (type + basics); borrowed items are runtime only here.
    final enc = jsonEncode(
      list.map((m) {
        if (m is FacultyMember) {
          return {
            'memberId': m.memberId,
            'type': 'FacultyMember',
            'name': m.name,
            'email': m.email,
            'joinDate': m.joinDate.toIso8601String(),
            'profileImageUrl': m.profileImageUrl,
            'department': m.department,
          };
        } else if (m is StudentMember) {
          return {
            'memberId': m.memberId,
            'type': 'StudentMember',
            'name': m.name,
            'email': m.email,
            'joinDate': m.joinDate.toIso8601String(),
            'profileImageUrl': m.profileImageUrl,
            'studentId': (m as StudentMember).studentId,
          };
        }
        return {};
      }).toList(),
    );
    await File(membersPath).writeAsString(enc);
  }
}
