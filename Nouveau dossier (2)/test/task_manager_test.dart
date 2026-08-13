import 'package:test/test.dart';
import 'package:task_manager_cli/exceptions/task_exceptions.dart';
import 'package:task_manager_cli/models/normal_task.dart';
import 'package:task_manager_cli/models/priority.dart';
import 'package:task_manager_cli/models/urgent_task.dart';
import 'package:task_manager_cli/repository/in_memory_task_repository.dart';
import 'package:task_manager_cli/services/task_manager.dart';

void main() {
  late TaskManager manager;
  late InMemoryTaskRepository repository;

  setUp(() {
    repository = InMemoryTaskRepository();
    manager = TaskManager(repository);
  });

  group('addTask', () {
    test('crée une NormalTask avec les valeurs fournies', () async {
      final task = await manager.addTask(
        title: 'Buy groceries',
        priority: Priority.medium,
      );

      expect(task, isA<NormalTask>());
      expect(task.title, 'Buy groceries');
      expect(task.priority, Priority.medium);
      expect(task.isDone, isFalse);

      final all = await repository.getAll();
      expect(all, hasLength(1));
    });

    test('crée une UrgentTask avec priorité forcée à high', () async {
      final task = await manager.addTask(
        title: 'Fix prod outage',
        priority: Priority.low, // ignorée car urgent: true
        urgent: true,
      );

      expect(task, isA<UrgentTask>());
      expect(task.priority, Priority.high);
    });

    test('lève InvalidTaskException si le titre est vide', () async {
      expect(
        () => manager.addTask(title: '   ', priority: Priority.low),
        throwsA(isA<InvalidTaskException>()),
      );
    });
  });

  group('listTasks', () {
    test('trie par priorité décroissante par défaut', () async {
      await manager.addTask(title: 'Low', priority: Priority.low);
      await manager.addTask(title: 'High', priority: Priority.high);
      await manager.addTask(title: 'Medium', priority: Priority.medium);

      final tasks = await manager.listTasks();

      expect(tasks.map((t) => t.title).toList(), ['High', 'Medium', 'Low']);
    });

    test('trie par date limite quand sortBy = "date"', () async {
      final loin = DateTime.now().add(const Duration(days: 10));
      final proche = DateTime.now().add(const Duration(days: 1));

      await manager.addTask(
          title: 'Loin', priority: Priority.low, dueDate: loin);
      await manager.addTask(
          title: 'Proche', priority: Priority.low, dueDate: proche);
      await manager.addTask(title: 'Sans date', priority: Priority.low);

      final tasks = await manager.listTasks(sortBy: 'date');

      expect(tasks.map((t) => t.title).toList(),
          ['Proche', 'Loin', 'Sans date']);
    });

    test('filtre par état de complétion', () async {
      final t1 =
          await manager.addTask(title: 'A finir', priority: Priority.medium);
      await manager.addTask(title: 'En cours', priority: Priority.medium);
      await manager.completeTask(t1.id);

      final done = await manager.listTasks(done: true);
      final pending = await manager.listTasks(done: false);

      expect(done, hasLength(1));
      expect(done.first.title, 'A finir');
      expect(pending, hasLength(1));
      expect(pending.first.title, 'En cours');
    });
  });

  group('completeTask', () {
    test('marque la tâche comme terminée', () async {
      final task =
          await manager.addTask(title: 'Clean desk', priority: Priority.low);
      expect(task.isDone, isFalse);

      final completed = await manager.completeTask(task.id);

      expect(completed.isDone, isTrue);
    });

    test('lève TaskNotFoundException pour un id inconnu', () async {
      expect(
        () => manager.completeTask('unknown-id'),
        throwsA(isA<TaskNotFoundException>()),
      );
    });
  });

  group('deleteTask', () {
    test('supprime une tâche existante', () async {
      final task = await manager.addTask(
          title: 'To delete', priority: Priority.medium);

      await manager.deleteTask(task.id);

      final all = await manager.listTasks();
      expect(all, isEmpty);
    });

    test('lève TaskNotFoundException pour un id inconnu', () async {
      expect(
        () => manager.deleteTask('unknown-id'),
        throwsA(isA<TaskNotFoundException>()),
      );
    });
  });

  group('Task.isOverdue', () {
    test('une tâche sans échéance n\'est jamais en retard', () async {
      final task =
          await manager.addTask(title: 'No due date', priority: Priority.low);
      expect(task.isOverdue, isFalse);
    });

    test('une tâche avec échéance passée et non terminée est en retard',
        () async {
      final task = await manager.addTask(
        title: 'Late task',
        priority: Priority.high,
        dueDate: DateTime.now().subtract(const Duration(days: 1)),
      );
      expect(task.isOverdue, isTrue);
    });

    test('une tâche en retard mais terminée n\'est plus en retard', () async {
      final task = await manager.addTask(
        title: 'Late but done',
        priority: Priority.high,
        dueDate: DateTime.now().subtract(const Duration(days: 1)),
      );
      final completed = await manager.completeTask(task.id);
      expect(completed.isOverdue, isFalse);
    });
  });

  group('UrgentTask', () {
    test('affiche un tag visuel distinct de NormalTask', () async {
      final urgent = await manager.addTask(
          title: 'Urgent one', priority: Priority.low, urgent: true);
      final normal =
          await manager.addTask(title: 'Normal one', priority: Priority.low);

      expect(urgent.displayTag, isNotEmpty);
      expect(normal.displayTag, isEmpty);
      expect(urgent.typeLabel, 'Urgent');
      expect(normal.typeLabel, 'Normal');
    });
  });
}
