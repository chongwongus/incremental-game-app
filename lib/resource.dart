import 'package:flutter/foundation.dart';

class Resource {
  final String name;
  final String icon;
  int quantity;

  Resource({required this.name, required this.icon, this.quantity = 0});
}

class ResourceManager extends ChangeNotifier {
  Map<String, Resource> resources = {
    'Wood': Resource(name: 'Wood', icon: '🪵', quantity: 0),
    'Ore': Resource(name: 'Ore', icon: '🪨', quantity: 0),
    'Fish': Resource(name: 'Fish', icon: '🐟', quantity: 0),
    'Herbs': Resource(name: 'Herbs', icon: '🌿', quantity: 0),
    'Gems': Resource(name: 'Gems', icon: '💎', quantity: 0),
  };

  void addResource(String name, int amount) {
    if (resources.containsKey(name)) {
      resources[name]!.quantity += amount;
      notifyListeners();
    }
  }

  int getResourceQuantity(String name) {
    return resources[name]?.quantity ?? 0;
  }
}