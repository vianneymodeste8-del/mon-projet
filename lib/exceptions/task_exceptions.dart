/// Exception de base pour toutes les erreurs liées aux tâches.
abstract class TaskException implements Exception {
  final String message;
  TaskException(this.message);

  @override
  String toString() => message;
}

/// Levée lorsqu'aucune tâche ne correspond à l'id demandé.
class TaskNotFoundException extends TaskException {
  TaskNotFoundException(String id) : super('Task not found with id: $id');
}

/// Levée lorsque les données fournies pour créer/modifier une tâche
/// sont invalides (titre vide, priorité inconnue, etc.).
class InvalidTaskException extends TaskException {
  InvalidTaskException(String reason) : super('Invalid task: $reason');
}

/// Levée en cas de problème de lecture/écriture du fichier de stockage.
class StorageException extends TaskException {
  StorageException(String reason) : super('Storage error: $reason');
}
