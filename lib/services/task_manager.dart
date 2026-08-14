import '../exceptions/task_exceptions.dart';
import '../models/normal_task.dart';
import '../models/priority.dart';
import '../models/task.dart';
import '../models/urgent_task.dart';
import '../repository/repository.dart';

/// Service applicatif orchestrant les opérations métier sur les tâches.
///
/// Il dépend uniquement de l'abstraction `Repository<Task>`, jamais
/// d'une implémentation concrète : c'est ce qui permet de le tester avec
/// [InMemoryTaskRepository] et de l'utiliser en production avec
/// [JsonTaskRepository], sans changer une ligne de ce fichier.
class TaskManager {
  final Repository<Task> _repository;

  TaskManager(this._repository);

  /// Crée une tâche. Si [urgent] est `true`, une [UrgentTask] est créée
  /// (priorité forcée à `high`) ; sinon une [NormalTask] avec la
  /// priorité fournie.
  Future<Task> addTask({
    required String title,
    required Priority priority,
    DateTime? dueDate,
    bool urgent = false,
  }) async {
    if (title.trim().isEmpty) {
      throw InvalidTaskException('title cannot be empty');
    }

    final id = '${DateTime.now().microsecondsSinceEpoch}';
    final Task task = urgent
        ? UrgentTask(id: id, title: title.trim(), dueDate: dueDate)
        : NormalTask(
            id: id,
            title: title.trim(),
            priority: priority,
            dueDate: dueDate,
          );

    await _repository.add(task);
    return task;
  }

  /// Liste les tâches, avec filtrage optionnel par état de complétion,
  /// triées par [sortBy] ('priority' par défaut, ou 'date').
  Future<List<Task>> listTasks({
    bool? done,
    String sortBy = 'priority',
  }) async {
    final tasks = await _repository.getAll();
    final filtered =
        done == null ? tasks.toList() : tasks.where((t) => t.isDone == done).toList();

    if (sortBy == 'date') {
      filtered.sort((a, b) {
        if (a.dueDate == null && b.dueDate == null) return 0;
        if (a.dueDate == null) return 1;
        if (b.dueDate == null) return -1;
        return a.dueDate!.compareTo(b.dueDate!);
      });
    } else {
      filtered.sort((a, b) => b.priority.weight.compareTo(a.priority.weight));
    }

    return filtered;
  }

  Future<Task> completeTask(String id) async {
    final task = await _repository.getById(id);
    if (task == null) {
      throw TaskNotFoundException(id);
    }
    task.isDone = true;
    await _repository.update(task);
    return task;
  }

  Future<void> deleteTask(String id) async {
    await _repository.delete(id);
  }
}
