import 'package:flutter/foundation.dart';
import 'resource.dart';

enum ItemType { Metal, Equipment, Rune, Potion }

class CraftedItem {
  final String name;
  final ItemType type;
  final Map<String, int> resourceCost;
  final String description;

  CraftedItem({
    required this.name,
    required this.type,
    required this.resourceCost,
    required this.description,
  });
}

class CraftingManager extends ChangeNotifier {
  final ResourceManager resourceManager;
  final List<CraftedItem> recipes = [
    CraftedItem(
      name: 'Iron Bar',
      type: ItemType.Metal,
      resourceCost: {'Ore': 2},
      description: 'A sturdy iron bar, useful for crafting equipment.',
    ),
    CraftedItem(
      name: 'Iron Sword',
      type: ItemType.Equipment,
      resourceCost: {'Iron Bar': 3},
      description: 'A basic iron sword, increases attack power.',
    ),
    CraftedItem(
      name: 'Fire Rune',
      type: ItemType.Rune,
      resourceCost: {'Wood': 1, 'Ore': 1},
      description: 'A magical fire rune, used for enchanting or spellcasting.',
    ),
    CraftedItem(
      name: 'Wooden Shield',
      type: ItemType.Equipment,
      resourceCost: {'Wood': 5},
      description: 'A basic wooden shield, increases defense.',
    ),
    CraftedItem(
      name: 'Healing Potion',
      type: ItemType.Potion,
      resourceCost: {'Herbs': 3, 'Fish': 1},
      description: 'A potion that restores health when consumed.',
    ),
    CraftedItem(
      name: 'Gem-studded Amulet',
      type: ItemType.Equipment,
      resourceCost: {'Iron Bar': 1, 'Gems': 2},
      description: 'An amulet that boosts magical abilities.',
    ),
  ];

  CraftingManager(this.resourceManager);

  bool canCraft(CraftedItem item) {
    return item.resourceCost.entries.every((entry) =>
        resourceManager.getResourceQuantity(entry.key) >= entry.value);
  }

  void craft(CraftedItem item) {
    if (canCraft(item)) {
      item.resourceCost.forEach((resource, amount) {
        resourceManager.addResource(resource, -amount);
      });
      // Add the crafted item to inventory or apply its effects
      notifyListeners();
    }
  }
}