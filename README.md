# Task Manager CLI

Application en ligne de commande (Dart pur, sans Flutter) pour créer,
lister, compléter et supprimer des tâches, avec persistance locale au
format JSON.

## Fonctionnalités

- Ajouter une tâche : titre, priorité (`low` / `medium` / `high`), date
  limite optionnelle
- Lister les tâches, triées par priorité ou par date limite
- Marquer une tâche comme terminée
- Supprimer une tâche
- Persistance automatique dans `tasks.json`

## Exigences techniques couvertes

| Exigence | Où |
|---|---|
| Classes abstraites + héritage | `Task` (abstraite) → `UrgentTask`, `NormalTask` |
| Interface | `Repository<T>` implémentée par `JsonTaskRepository` et `InMemoryTaskRepository` |
| Générique | `Repository<T>` |
| Exceptions personnalisées | `TaskNotFoundException`, `InvalidTaskException`, `StorageException` |
| Tests unitaires (≥5) | `test/task_manager_test.dart` — 13 tests |

## Structure du projet

```
task_manager_cli/
├── bin/
│   └── main.dart                        # Point d'entrée CLI
├── lib/
│   ├── models/
│   │   ├── priority.dart                # enum Priority + extension
│   │   ├── task.dart                    # classe abstraite Task
│   │   ├── urgent_task.dart             # Task → UrgentTask
│   │   ├── normal_task.dart             # Task → NormalTask
│   │   └── task_factory.dart            # désérialisation polymorphe
│   ├── exceptions/
│   │   └── task_exceptions.dart         # exceptions personnalisées
│   ├── repository/
│   │   ├── repository.dart              # interface générique Repository<T>
│   │   ├── json_task_repository.dart    # implémentation JSON (production)
│   │   └── in_memory_task_repository.dart # implémentation mémoire (tests)
│   └── services/
│       └── task_manager.dart            # logique métier
├── test/
│   └── task_manager_test.dart
└── pubspec.yaml
```

## Installation

Nécessite le [Dart SDK](https://dart.dev/get-dart) (>=3.0.0).

```bash
dart pub get
```

## Utilisation

```bash
# Ajouter une tâche normale
dart run bin/main.dart add "Pay rent" --priority high --due 2026-09-01

# Ajouter une tâche urgente (priorité forcée à "high")
dart run bin/main.dart add "Fix prod outage" --urgent

# Lister toutes les tâches (triées par priorité)
dart run bin/main.dart list

# Lister par date, ou filtrer par statut
dart run bin/main.dart list --sort date
dart run bin/main.dart list --pending
dart run bin/main.dart list --done

# Compléter une tâche (l'id est affiché lors de l'ajout / du listing)
dart run bin/main.dart complete <id>

# Supprimer une tâche
dart run bin/main.dart delete <id>
```

Les tâches sont stockées dans `tasks.json`, créé automatiquement dans le
dossier courant au premier ajout.

## Lancer les tests

```bash
dart test
```

Les tests utilisent `InMemoryTaskRepository` (aucun accès disque) pour
valider `TaskManager` de façon rapide et isolée : création, tri par
priorité/date, filtrage, complétion, suppression, exceptions, et
détection de retard (`isOverdue`).
