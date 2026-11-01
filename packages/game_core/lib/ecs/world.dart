import 'component.dart';
import 'entity.dart';

class World {
  int _nextEntityId = 0;
  final Map<Type, Map<Entity, Component>> _componentStores = {};

  Entity createEntity() {
    return _nextEntityId++;
  }

  void destroyEntity(Entity entity) {
    for (final store in _componentStores.values) {
      store.remove(entity);
    }
  }

  void addComponent<T extends Component>(Entity entity, T component) {
    _componentStores.putIfAbsent(T, () => {})[entity] = component;
  }

  void removeComponent<T extends Component>(Entity entity) {
    _componentStores[T]?.remove(entity);
  }

  T? getComponent<T extends Component>(Entity entity) {
    return _componentStores[T]?[entity] as T?;
  }

  bool hasComponent<T extends Component>(Entity entity) {
    return _componentStores[T]?.containsKey(entity) ?? false;
  }

  List<Entity> query(List<Type> requiredTypes) {
    if (requiredTypes.isEmpty) return [];

    final firstEntities = _componentStores[requiredTypes.first]?.keys.toSet() ?? {};
    if (firstEntities.isEmpty) return [];

    final result = <Entity>[];
    for (final entity in firstEntities) {
      var matches = true;
      for (var i = 1; i < requiredTypes.length; i++) {
        if (!(_componentStores[requiredTypes[i]]?.containsKey(entity) ?? false)) {
          matches = false;
          break;
        }
      }
      if (matches) {
        result.add(entity);
      }
    }
    return result;
  }
}
