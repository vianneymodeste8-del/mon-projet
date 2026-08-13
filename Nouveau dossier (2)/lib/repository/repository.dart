/// Interface générique définissant les opérations CRUD de base pour
/// n'importe quel type [T] identifié par une chaîne (id).
///
/// C'est l'interface + le générique demandés par le cahier des charges :
/// n'importe quelle classe implémentant `Repository<T>` doit fournir ces
/// cinq méthodes, quel que soit le type stocké.
abstract class Repository<T> {
  Future<List<T>> getAll();
  Future<T?> getById(String id);
  Future<void> add(T item);
  Future<void> update(T item);
  Future<void> delete(String id);
}
