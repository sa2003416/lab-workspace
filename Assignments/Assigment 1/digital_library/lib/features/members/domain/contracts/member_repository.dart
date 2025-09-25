import 'package:digital_library/features/members/domain/entities/member.dart';

abstract class MemberRepository {
  Future<List<Member>> getAllMembers();
  Future<Member> getMember(String memberId);
  Future<void> addMember(Member member);
  Future<void> updateMember(Member member);
}
