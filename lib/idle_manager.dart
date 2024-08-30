import 'dart:async';
import 'package:flutter/foundation.dart';
import 'character.dart';

class IdleManager extends ChangeNotifier {
  final Character character;
  String? activeSkill;
  Timer? activeTimer;
  double progress = 0.0;

  IdleManager(this.character);

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
    // This is a simple calculation, you can make it more complex based on skill level, equipment, etc.
    return 10 + (character.skills[skillName]?.level ?? 0);
  }

  @override
  void dispose() {
    activeTimer?.cancel();
    super.dispose();
  }
}