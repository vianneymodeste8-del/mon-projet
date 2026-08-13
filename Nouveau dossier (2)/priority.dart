/// Niveaux de priorité d'une tâche.
enum Priority { low, medium, high }

/// Ajoute un poids de tri et un libellé lisible à [Priority].
extension PriorityExtension on Priority {
  /// Poids numérique utilisé pour trier les tâches (plus haut = plus urgent).
  int get weight {
    switch (this) {
      case Priority.low:
        return 0;
      case Priority.medium:
        return 1;
      case Priority.high:
        return 2;
    }
  }

  String get label {
    switch (this) {
      case Priority.low:
        return 'Low';
      case Priority.medium:
        return 'Medium';
      case Priority.high:
        return 'High';
    }
  }

  static Priority fromString(String value) {
    return Priority.values.firstWhere(
      (p) => p.name.toLowerCase() == value.toLowerCase(),
      orElse: () => throw ArgumentError(
          'Priorité inconnue: "$value" (attendu: low, medium, high)'),
    );
  }
}
