import 'dart:io';

import 'package:task_manager_cli/exceptions/task_exceptions.dart';
import 'package:task_manager_cli/models/priority.dart';
import 'package:task_manager_cli/repository/json_task_repository.dart';
import 'package:task_manager_cli/services/task_manager.dart';

Future<void> main(List<String> arguments) async {
  final repository = JsonTaskRepository(filePath: 'tasks.json');
  final manager = TaskManager(repository);

  if (arguments.isEmpty) {
    printHelp();
    return;
  }

  final command = arguments.first;
  final rest = arguments.skip(1).toList();

  try {
    switch (command) {
      case 'add':
        await runAdd(manager, rest);
        break;
      case 'list':
        await runList(manager, rest);
        break;
      case 'complete':
        await runComplete(manager, rest);
        break;
      case 'delete':
        await runDelete(manager, rest);
        break;
      case '-h':
      case '--help':
      case 'help':
        printHelp();
        break;
      default:
        stderr.writeln('Unknown command: "$command"\n');
        printHelp();
        exit(64);
    }
  } on TaskException catch (e) {
    stderr.writeln('Error: $e');
    exit(1);
  } on ArgumentError catch (e) {
    stderr.writeln('Error: ${e.message}');
    exit(1);
  }
}

/// Extrait la valeur d'une option `--nom valeur` dans une liste d'arguments.
String? _optionValue(List<String> args, String name) {
  final index = args.indexOf(name);
  if (index == -1 || index + 1 >= args.length) return null;
  return args[index + 1];
}

Future<void> runAdd(TaskManager manager, List<String> args) async {
  if (args.isEmpty) {
    stderr.writeln(
        'Usage: add "<title>" [--priority low|medium|high] '
        '[--due YYYY-MM-DD] [--urgent]');
    exit(64);
  }

  final title = args.first;
  final priority =
      PriorityExtension.fromString(_optionValue(args, '--priority') ?? 'medium');
  final dueText = _optionValue(args, '--due');
  final dueDate = dueText != null ? DateTime.parse(dueText) : null;
  final urgent = args.contains('--urgent');

  final task = await manager.addTask(
    title: title,
    priority: priority,
    dueDate: dueDate,
    urgent: urgent,
  );

  print('Task added: $task');
}

Future<void> runList(TaskManager manager, List<String> args) async {
  bool? done;
  if (args.contains('--done')) done = true;
  if (args.contains('--pending')) done = false;

  final sortBy = _optionValue(args, '--sort') ?? 'priority';

  final tasks = await manager.listTasks(done: done, sortBy: sortBy);

  if (tasks.isEmpty) {
    print('No tasks to display.');
    return;
  }

  for (final task in tasks) {
    print(task);
  }
}

Future<void> runComplete(TaskManager manager, List<String> args) async {
  if (args.isEmpty) {
    stderr.writeln('Usage: complete <id>');
    exit(64);
  }
  final task = await manager.completeTask(args.first);
  print('Task completed: $task');
}

Future<void> runDelete(TaskManager manager, List<String> args) async {
  if (args.isEmpty) {
    stderr.writeln('Usage: delete <id>');
    exit(64);
  }
  await manager.deleteTask(args.first);
  print('Task ${args.first} deleted.');
}

void printHelp() {
  print('''
Task Manager CLI — gestion de tâches en ligne de commande (Dart pur)

Usage:
  dart run bin/main.dart <command> [options]

Commands:
  add "<title>" [--priority low|medium|high] [--due YYYY-MM-DD] [--urgent]
      Crée une nouvelle tâche.
      --urgent force la priorité à "high" (crée une UrgentTask).

  list [--done|--pending] [--sort priority|date]
      Affiche les tâches. Tri par priorité (défaut) ou par date.

  complete <id>
      Marque la tâche <id> comme terminée.

  delete <id>
      Supprime la tâche <id>.

Exemples:
  dart run bin/main.dart add "Pay rent" --priority high --due 2026-09-01
  dart run bin/main.dart add "Fix prod bug" --urgent
  dart run bin/main.dart list --pending --sort date
  dart run bin/main.dart complete 1699999999999
  dart run bin/main.dart delete 1699999999999
''');
}
