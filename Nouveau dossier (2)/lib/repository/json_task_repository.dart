import 'dart:convert';
import 'dart:io';

import '../exceptions/task_exceptions.dart';
import '../models/task.dart';
import '../models/task_factory.dart';
import 'repository.dart';

/// Implémentation de `Repository<Task>` qui persiste les tâches dans un
/// fichier JSON local. C'est la source de vérité utilisée par l'app CLI.
class JsonTaskRepository implements Repository<Task> {
  final String filePath;
  List<Task> _cache = [];
  bool _isLoaded = false;

  JsonTaskRepository({this.filePath = 'tasks.json'});

  Future<void> _load() async {
    if (_isLoaded) return;
    final file = File(filePath);
    if (await file.exists()) {
      try {
        final content = await file.readAsString();
        if (content.trim().isEmpty) {
          _cache = [];
        } else {
          final List<dynamic> data = jsonDecode(content) as List<dynamic>;
          _cache = data
              .map((e) => TaskFactory.fromJson(e as Map<String, dynamic>))
              .toList();
        }
      } catch (e) {
        throw StorageException('Cannot read "$filePath": $e');
      }
    } else {
      _cache = [];
    }
    _isLoaded = true;
  }

  Future<void> _persist() async {
    try {
      final file = File(filePath);
      final data = _cache.map((t) => t.toJson()).toList();
      const encoder = JsonEncoder.withIndent('  ');
      await file.writeAsString(encoder.convert(data));
    } catch (e) {
      throw StorageException('Cannot write "$filePath": $e');
    }
  }

  @override
  Future<List<Task>> getAll() async {
    await _load();
    return List.unmodifiable(_cache);
  }

  @override
  Future<Task?> getById(String id) async {
    await _load();
    for (final t in _cache) {
      if (t.id == id) return t;
    }
    return null;
  }

  @override
  Future<void> add(Task item) async {
    await _load();
    _cache.add(item);
    await _persist();
  }

  @override
  Future<void> update(Task item) async {
    await _load();
    final index = _cache.indexWhere((t) => t.id == item.id);
    if (index == -1) {
      throw TaskNotFoundException(item.id);
    }
    _cache[index] = item;
    await _persist();
  }

  @override
  Future<void> delete(String id) async {
    await _load();
    final existed = _cache.any((t) => t.id == id);
    if (!existed) {
      throw TaskNotFoundException(id);
    }
    _cache.removeWhere((t) => t.id == id);
    await _persist();
  }
}
