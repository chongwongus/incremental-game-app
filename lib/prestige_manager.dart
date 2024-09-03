// prestige_manager.dart

import 'package:flutter/foundation.dart';
import 'character.dart';
import 'prestige_system.dart';

class PrestigeManager extends ChangeNotifier {
  final Character character;
  final PrestigeSystem prestigeSystem = PrestigeSystem();

  PrestigeManager(this.character);

  bool canPrestige() {
    return character.canPrestige();
  }

  void prestige() {
    if (canPrestige()) {
      character.prestige();
      notifyListeners();
    }
  }

  PrestigeLevel getCurrentPrestigeLevel() {
    return prestigeSystem.getPrestigeLevel(character.prestigeLevel);
  }

  PrestigeLevel getNextPrestigeLevel() {
    return prestigeSystem.getPrestigeLevel(character.prestigeLevel + 1);
  }

  double getPrestigeProgress() {
    int totalLevel = character.skills.values.fold(0, (sum, skill) => sum + skill.level);
    return totalLevel / 1000; // Assuming 1000 is the requirement for prestige
  }
}