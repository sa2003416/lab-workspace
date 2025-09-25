import 'dart:convert';
import 'dart:io';

abstract class JsonSerializable<T> {
  Map<String, dynamic> toJson();
}

class Author implements JsonSerializable<Author> {
  final String id;
  final String name;
  final String? profileImageUrl;
  final String? biography;
  final int? birthYear;

  const Author({
    required this.id,
    required this.name,
    this.profileImageUrl,
    this.biography,
    this.birthYear,
  });

  String getDisplayName() => name.trim();

  int? calculateAge({int? yearNow}) {
    if (birthYear == null) return null;
    final nowYear = yearNow ?? DateTime.now().year;
    final age = nowYear - birthYear!;
    return age >= 0 ? age : null;
  }

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'profileImageUrl': profileImageUrl,
    'biography': biography,
    'birthYear': birthYear,
  };
  factory Author.fromJson(Map<String, dynamic> json) => Author(
    id: json['id'] as String,
    name: json['name'] as String,
    profileImageUrl: json['profileImageUrl'] as String?,
    biography: json['biography'] as String?,
    birthYear: json['birthYear'] as int?,
  );
}
