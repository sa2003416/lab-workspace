import 'dart:convert';
import 'dart:io';

import 'package:digital_library/features/library_items/domain/contracs/library_repository.dart';
import 'package:digital_library/features/library_items/domain/entities/author.dart';
import 'package:digital_library/features/library_items/domain/entities/library_item.dart';

class JsonLibraryRepository implements LibraryRepository {
  final String catalogPath;
  final String authorsPath;

  List<LibraryItem>? _cacheItems;
  Map<String, Author>? _authorsById;

  JsonLibraryRepository({required this.catalogPath, required this.authorsPath});

  Future<Map<String, Author>> _loadAuthors() async {
    if (_authorsById != null) return _authorsById!;
    try {
      final raw = await File(authorsPath).readAsString();
      final list = jsonDecode(raw) as List<dynamic>;
      _authorsById = {
        for (final a in list.map(
          (e) => Author.fromJson(e as Map<String, dynamic>),
        ))
          a.id: a,
      };
      return _authorsById!;
    } catch (e) {
      throw FileSystemException('Failed to load authors: $e');
    }
  }

  Future<List<LibraryItem>> _loadItems() async {
    if (_cacheItems != null) return _cacheItems!;
    final authorsById = await _loadAuthors();
    try {
      final raw = await File(catalogPath).readAsString();
      final list = jsonDecode(raw) as List<dynamic>;
      _cacheItems = list
          .map(
            (e) => LibraryItem.fromJson(e as Map<String, dynamic>, authorsById),
          )
          .toList(growable: false);
      return _cacheItems!;
    } catch (e) {
      throw FileSystemException('Failed to load catalog: $e');
    }
  }

  @override
  Future<List<LibraryItem>> getAllItems() async => await _loadItems();

  @override
  Future<LibraryItem> getItem(String id) async =>
      (await _loadItems()).firstWhere(
        (i) => i.id == id,
        orElse: () => throw StateError('Item $id not found'),
      );

  @override
  Future<List<LibraryItem>> searchItems(String query) async {
    final q = query.toLowerCase();
    final items = await _loadItems();
    return items
        .where((i) {
          final inTitle = i.title.toLowerCase().contains(q);
          final inDesc = (i.description ?? '').toLowerCase().contains(q);
          final inAuthors = i.authors.any(
            (a) => a.name.toLowerCase().contains(q),
          );
          return inTitle || inDesc || inAuthors;
        })
        .toList(growable: false);
  }

  @override
  Future<List<LibraryItem>> getItemsByCategory(String category) async {
    final c = category.toLowerCase();
    return (await _loadItems())
        .where((i) => i.category.toLowerCase() == c)
        .toList(growable: false);
  }

  @override
  Future<List<LibraryItem>> getAvailableItems() async =>
      (await _loadItems()).where((i) => i.isAvailable).toList(growable: false);

  @override
  Future<List<LibraryItem>> getItemsByAuthor(String authorId) async =>
      (await _loadItems())
          .where((i) => i.authors.any((a) => a.id == authorId))
          .toList(growable: false);
}
