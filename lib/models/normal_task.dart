import 'priority.dart';
import 'task.dart';

/// Tâche standard : la priorité (`low`, `medium` ou `high`) est choisie
/// librement par l'utilisateur lors de la création.
class NormalTask extends Task {
  NormalTask({
    required super.id,
    required super.title,
    required super.priority,
    super.dueDate,
    super.isDone,
  });

  @override
  String get typeLabel => 'Normal';

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'priority': priority.name,
        'dueDate': dueDate?.toIso8601String(),
        'isDone': isDone,
        'type': typeLabel,
      };

  factory NormalTask.fromJson(Map<String, dynamic> json) {
    return NormalTask(
      id: json['id'] as String,
      title: json['title'] as String,
      priority: PriorityExtension.fromString(json['priority'] as String),
      dueDate: json['dueDate'] != null
          ? DateTime.parse(json['dueDate'] as String)
          : null,
      isDone: json['isDone'] as bool? ?? false,
    );
  }
}
