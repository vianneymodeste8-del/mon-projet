import 'normal_task.dart';
import 'task.dart';
import 'urgent_task.dart';

/// Reconstruit le bon sous-type de [Task] à partir de son champ `type`
/// stocké dans le JSON. C'est ce qui permet au [Repository] de rester
/// générique tout en manipulant des objets polymorphes.
class TaskFactory {
  static Task fromJson(Map<String, dynamic> json) {
    switch (json['type']) {
      case 'Urgent':
        return UrgentTask.fromJson(json);
      case 'Normal':
        return NormalTask.fromJson(json);
      default:
        throw FormatException('Type de tâche inconnu: ${json['type']}');
    }
  }
}
