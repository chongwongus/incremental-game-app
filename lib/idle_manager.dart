import 'dart:async';
import 'package:flutter/foundation.dart';
import 'character.dart';
import 'resource.dart';

class IdleManager extends ChangeNotifier {
  final Character character;
  final ResourceManager resourceManager;
  String? activeSkill;
  Timer? activeTimer;
  double progress = 0.0;

  IdleManager(this.character, this.resourceManager);

  void startIdleAction(String skillName) {
    if (activeSkill != null) {
      stopIdleAction();
    }
    
    activeSkill = skillName;
    progress = 0.0;
    
    activeTimer = Timer.periodic(Duration(milliseconds: 100), (timer) {
      progress += 0.01;
      if (progress >= 1.0) {
        int xpGained = calculateXpGain(skillName);
        character.improveSkill(skillName, xpGained);
        gatherResources(skillName);
        progress = 0.0;
      }
      notifyListeners();
    });
    notifyListeners();
  }

  void stopIdleAction() {
    activeTimer?.cancel();
    activeTimer = null;
    activeSkill = null;
    progress = 0.0;
    notifyListeners();
  }

  int calculateXpGain(String skillName) {
    return 10 + (character.skills[skillName]?.level ?? 0);
  }

  void gatherResources(String skillName) {
    switch (skillName) {
      case 'Woodcutting':
        resourceManager.addResource('Wood', 1);
        break;
      case 'Mining':
        resourceManager.addResource('Ore', 1);
        break;
      case 'Fishing':
        resourceManager.addResource('Fish', 1);
        break;
    }
  }

  @override
  void dispose() {
    activeTimer?.cancel();
    super.dispose();
  }
}
