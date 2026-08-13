import 'priority.dart';

/// Classe abstraite représentant une tâche.
///
/// Toute sous-classe doit fournir sa propre sérialisation JSON (via
/// [toJson]) et son [typeLabel] (utilisé pour la désérialisation
/// polymorphe côté [TaskFactory]).
abstract class Task {
  final String id;
  final String title;
  final Priority priority;
  final DateTime? dueDate;
  bool isDone;

  Task({
    required this.id,
    required this.title,
    required this.priority,
    this.dueDate,
    this.isDone = false,
  });

  /// Sérialise la tâche en `Map`, prête pour `jsonEncode`.
  Map<String, dynamic> toJson();

  /// Identifiant du type concret, stocké dans le JSON pour permettre
  /// une désérialisation polymorphe (voir [TaskFactory]).
  String get typeLabel;

  /// Étiquette courte affichée devant le titre (ex: "[!] " pour une
  /// tâche urgente). Chaque sous-classe peut la personnaliser.
  String get displayTag => '';

  /// Une tâche est en retard si sa date limite est dépassée et qu'elle
  /// n'est pas encore terminée.
  bool get isOverdue {
    if (dueDate == null || isDone) return false;
    return DateTime.now().isAfter(dueDate!);
  }

  @override
  String toString() {
    final status = isDone ? '[x]' : '[ ]';
    final due = dueDate != null
        ? ' (due: ${dueDate!.toIso8601String().split('T').first})'
        : '';
    final overdue = isOverdue ? ' ⚠ OVERDUE' : '';
    return '$status $displayTag$title — ${priority.label}$due '
        '[$typeLabel]$overdue (id: $id)';
  }
}
