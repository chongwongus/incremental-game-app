import 'package:flutter/foundation.dart';

enum TalentCategory {
  physical,
  mental,
  social,
  crafting,
  achievement,
}

enum UnlockType {
  SkillLevel,
  QuestCompletion,
  TalentPoints,
}

class Talent {
  final String id;
  final String name;
  final String description;
  final TalentCategory category;
  final String relatedSkill;
  final UnlockType unlockType;
  final int unlockRequirement;
  final double bonus;
  final int maxLevel;
  final int requiredPoints;

  bool unlocked;
  int currentLevel;
  final List<String> prerequisites; // Keep this for future use

  Talent({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.relatedSkill,
    required this.unlockType,
    required this.unlockRequirement,
    required this.bonus,
    required this.requiredPoints,
    this.maxLevel = 1,
    this.unlocked = false,
    this.currentLevel = 0,
    this.prerequisites = const [], // Empty by default
  });
}

class TalentTree {
  final List<Talent> talents = [
    // Achievements
    Talent(
      id: 'strength_1',
      name: 'Novice Strongman',
      description: 'Reach level 5 in Strength',
      category: TalentCategory.achievement,
      relatedSkill: 'Strength',
      unlockType: UnlockType.SkillLevel,
      unlockRequirement: 5,
      bonus: 0.05,
      requiredPoints: 0,  // Achievements don't require points
    ),
    Talent(
      id: 'woodcutting_1',
      name: 'Apprentice Lumberjack',
      description: 'Reach level 10 in Woodcutting',
      category: TalentCategory.achievement,
      relatedSkill: 'Woodcutting',
      unlockType: UnlockType.SkillLevel,
      unlockRequirement: 10,
      bonus: 0.1,
      requiredPoints: 0,  // Achievements don't require points
    ),
    Talent(
      id: 'quest_master',
      name: 'Quest Master',
      description: 'Complete 100 quests',
      category: TalentCategory.achievement,
      relatedSkill: 'All',
      unlockType: UnlockType.QuestCompletion,
      unlockRequirement: 100,
      bonus: 0.05,
      requiredPoints: 0,  // Achievements don't require points
    ),
    // Skill Tree Talents
    Talent(
      id: 'quick_learner',
      name: 'Quick Learner',
      description: 'Increases XP gain by 5% per level',
      category: TalentCategory.mental,
      relatedSkill: 'Intelligence',
      unlockType: UnlockType.TalentPoints,
      unlockRequirement: 1,
      bonus: 0.05,
      requiredPoints: 1,
      maxLevel: 5,
    ),
    Talent(
      id: 'efficient_crafter',
      name: 'Efficient Crafter',
      description: 'Reduces resource cost for crafting by 2% per level',
      category: TalentCategory.crafting,
      relatedSkill: 'Crafting',
      unlockType: UnlockType.TalentPoints,
      unlockRequirement: 1,
      bonus: 0.02,
      requiredPoints: 2,
      maxLevel: 10,
    ),
    Talent(
      id: 'iron_body',
      name: 'Iron Body',
      description: 'Increases Constitution XP gain by 10% per level',
      category: TalentCategory.physical,
      relatedSkill: 'Constitution',
      unlockType: UnlockType.TalentPoints,
      unlockRequirement: 1,
      bonus: 0.1,
      requiredPoints: 3,
      maxLevel: 3,
    ),
  ];

  Talent getTalentById(String id) {
    return talents.firstWhere((talent) => talent.id == id);
  }
}

class PlayerTalents extends ChangeNotifier {
  Map<String, int> unlockedTalents = {};
  int availablePoints = 0;  // Changed from talentPoints to availablePoints

  void unlockTalent(String talentId) {
    Talent talent = TalentTree().getTalentById(talentId);
    if (talent.unlockType == UnlockType.TalentPoints) {
      if (availablePoints >= talent.requiredPoints && canUnlockTalent(talentId)) {
        if (!unlockedTalents.containsKey(talentId)) {
          unlockedTalents[talentId] = 1;
        } else {
          unlockedTalents[talentId] = unlockedTalents[talentId]! + 1;
        }
        availablePoints -= talent.requiredPoints;
        notifyListeners();
      }
    } else {
      if (!unlockedTalents.containsKey(talentId)) {
        unlockedTalents[talentId] = 1;
        notifyListeners();
      }
    }
  }

  int getTalentLevel(String talentId) {
    return unlockedTalents[talentId] ?? 0;
  }

  bool canUnlockTalent(String talentId) {
    Talent talent = TalentTree().getTalentById(talentId);
    int currentLevel = getTalentLevel(talentId);
    return currentLevel < talent.maxLevel && availablePoints >= talent.requiredPoints;
  }

  bool isTalentUnlocked(String talentId) {
    return unlockedTalents.containsKey(talentId);
  }

  double getBonusForSkill(String skillName) {
    double bonus = 0;
    for (var entry in unlockedTalents.entries) {
      var talent = TalentTree().getTalentById(entry.key);
      if (talent.relatedSkill == skillName || talent.relatedSkill == 'All') {
        bonus += talent.bonus * entry.value;
      }
    }
    return bonus;
  }

  void checkAndUnlockSkillTalents(String skillName, int skillLevel) {
    for (var talent in TalentTree().talents) {
      if (talent.relatedSkill == skillName &&
          talent.unlockType == UnlockType.SkillLevel &&
          skillLevel >= talent.unlockRequirement) {
        unlockTalent(talent.id);
      }
    }
  }

  void checkAndUnlockQuestTalents(int completedQuests) {
    for (var talent in TalentTree().talents) {
      if (talent.unlockType == UnlockType.QuestCompletion &&
          completedQuests >= talent.unlockRequirement) {
        unlockTalent(talent.id);
      }
    }
  }

  void addPoints(int points) {
    availablePoints += points;
    notifyListeners();
  }
}