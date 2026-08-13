# Task Manager CLI

Application en ligne de commande développée en Dart pour gérer des tâches (ajout, priorisation, suivi).

## Fonctionnalités
- Création de tâches (normales, prioritaires, urgentes)
- Gestion via repository en mémoire ou en JSON
- Gestion des exceptions liées aux tâches

## Prérequis
- Dart SDK installé (https://dart.dev/get-dart)

## Installation

```bash
dart pub get
```

## Lancer l'application

```bash
dart run main.dart
```

## Lancer les tests

```bash
dart test
```

## Structure du projet
- `main.dart` — point d'entrée de l'application
- `task.dart`, `normal_task.dart`, `priority.dart`, `urgent_task.dart` — modèles de tâches
- `task_manager.dart` — logique de gestion des tâches
- `repository.dart`, `in_memory_task_repository.dart`, `json_task_repository.dart` — persistance des données
- `task_exceptions.dart` — gestion des erreurs
- `task_manager_test.dart` — tests unitaires

## Auteur
Vianney Modeste# mon-projet
Projet de formation
