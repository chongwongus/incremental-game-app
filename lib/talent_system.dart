import 'package:flutter/foundation.dart';

enum TalentCategory {
  physical,
  mental,
  social,
  crafting,
}

class Talent {
  final String id;
  final String name;
  final String description;
  final TalentCategory category;
  final int maxLevel;

  Talent({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.maxLevel,
  });
}

class TalentTree {
  final List<Talent> talents = [
    Talent(
      id: 'quick_learner',
      name: 'Quick Learner',
      description: 'Increases XP gain by 5% per level',
      category: TalentCategory.mental,
      maxLevel: 5,
    ),
    Talent(
      id: 'efficient_crafter',
      name: 'Efficient Crafter',
      description: 'Reduces resource cost for crafting by 2% per level',
      category: TalentCategory.crafting,
      maxLevel: 10,
    ),
    Talent(
      id: 'social_butterfly',
      name: 'Social Butterfly',
      description: 'Increases Charisma XP gain by 10% per level',
      category: TalentCategory.social,
      maxLevel: 3,
    ),
    Talent(
      id: 'iron_body',
      name: 'Iron Body',
      description: 'Increases Constitution XP gain by 10% per level',
      category: TalentCategory.physical,
      maxLevel: 3,
    ),
    // Add more talents as needed
  ];

  Talent getTalentById(String id) {
    return talents.firstWhere((talent) => talent.id == id);
  }
}

class PlayerTalents extends ChangeNotifier {
  Map<String, int> unlockedTalents = {};

  void unlockTalent(String talentId) {
    if (!unlockedTalents.containsKey(talentId)) {
      unlockedTalents[talentId] = 1;
    } else if (unlockedTalents[talentId]! < TalentTree().getTalentById(talentId).maxLevel) {
      unlockedTalents[talentId] = unlockedTalents[talentId]! + 1;
    }
    notifyListeners();
  }

  int getTalentLevel(String talentId) {
    return unlockedTalents[talentId] ?? 0;
  }

  bool canUnlockTalent(String talentId) {
    Talent talent = TalentTree().getTalentById(talentId);
    int currentLevel = getTalentLevel(talentId);
    return currentLevel < talent.maxLevel;
  }
}