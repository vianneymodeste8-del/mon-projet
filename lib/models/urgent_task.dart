import 'priority.dart';
import 'task.dart';

/// Tâche urgente : sa priorité est toujours [Priority.high], quelle que
/// soit la valeur passée par l'utilisateur — c'est le rôle de cette
/// sous-classe de le garantir.
///
/// Exemple typique d'héritage demandé par le cahier des charges :
/// `Task` → `UrgentTask`.
class UrgentTask extends Task {
  UrgentTask({
    required super.id,
    required super.title,
    super.dueDate,
    super.isDone,
  }) : super(priority: Priority.high);

  @override
  String get typeLabel => 'Urgent';

  @override
  String get displayTag => '🔥 ';

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'priority': priority.name,
        'dueDate': dueDate?.toIso8601String(),
        'isDone': isDone,
        'type': typeLabel,
      };

  factory UrgentTask.fromJson(Map<String, dynamic> json) {
    return UrgentTask(
      id: json['id'] as String,
      title: json['title'] as String,
      dueDate: json['dueDate'] != null
          ? DateTime.parse(json['dueDate'] as String)
          : null,
      isDone: json['isDone'] as bool? ?? false,
    );
  }
}
