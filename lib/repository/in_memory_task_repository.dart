import '../exceptions/task_exceptions.dart';
import '../models/task.dart';
import 'repository.dart';

/// Implémentation en mémoire de `Repository<Task>`, utilisée pour les
/// tests unitaires : même contrat que [JsonTaskRepository], mais sans
/// aucun accès disque, donc rapide et isolée.
class InMemoryTaskRepository implements Repository<Task> {
  final List<Task> _items = [];

  @override
  Future<List<Task>> getAll() async => List.unmodifiable(_items);

  @override
  Future<Task?> getById(String id) async {
    for (final t in _items) {
      if (t.id == id) return t;
    }
    return null;
  }

  @override
  Future<void> add(Task item) async {
    _items.add(item);
  }

  @override
  Future<void> update(Task item) async {
    final index = _items.indexWhere((t) => t.id == item.id);
    if (index == -1) {
      throw TaskNotFoundException(item.id);
    }
    _items[index] = item;
  }

  @override
  Future<void> delete(String id) async {
    final existed = _items.any((t) => t.id == id);
    if (!existed) {
      throw TaskNotFoundException(id);
    }
    _items.removeWhere((t) => t.id == id);
  }
}
