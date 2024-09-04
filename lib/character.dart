// character.dart

import 'package:flutter/material.dart';
import 'skill.dart';
import 'prestige_system.dart';
import 'talent_system.dart' as ts;

enum BaseClass { melee, ranged, magic }

class Character extends ChangeNotifier {
  String name;
  BaseClass baseClass;
  Map<String, Skill> skills;
  Set<String> unlockedSkills;
  String job;
  int level;
  int experience;
  Map<String, int> resources;
  int prestigeLevel;
  ts.PlayerTalents talents;
  int talentPoints;

  Character({
    required this.name,
    required this.baseClass,
    required this.skills,
    Set<String>? unlockedSkills,
    this.job = 'Novice',
    this.level = 1,
    this.experience = 0,
    Map<String, int>? resources,
    this.prestigeLevel = 0,
    ts.PlayerTalents? talents,
    this.talentPoints = 0,
  })  : resources = resources ?? {'Wood': 0, 'Fish': 0, 'Ore': 0},
        talents = talents ?? ts.PlayerTalents(),
        unlockedSkills = unlockedSkills ?? Set<String>.from(skills.keys);

  void unlockSkill(String skillName) {
    if (!unlockedSkills.contains(skillName)) {
      unlockedSkills.add(skillName);
      if (!skills.containsKey(skillName)) {
        skills[skillName] = Skill(name: skillName, icon: Icons.star);
      }
      notifyListeners();
    }
  }

  bool isSkillUnlocked(String skillName) {
    return unlockedSkills.contains(skillName);
  }

  void addTalentPoints(int points) {
    talentPoints += points;
    notifyListeners();
  }

  void unlockSkills(List<String> skills) {
    // Implementation
  }

  int get attackPower {
    switch (baseClass) {
      case BaseClass.melee:
        return skills['Strength']!.level + skills['Attack']!.level;
      case BaseClass.ranged:
        return skills['Agility']!.level + skills['Attack']!.level;
      case BaseClass.magic:
        return skills['Intelligence']!.level + skills['Wisdom']!.level;
    }
  }

  int get defensePower {
    return skills['Defense']!.level + skills['Constitution']!.level;
  }

  int get health {
    return skills['Constitution']!.level * 10;
  }

  void addExperience(int amount) {
    PrestigeSystem prestigeSystem = PrestigeSystem();
    double xpMultiplier =
        prestigeSystem.getPrestigeLevel(prestigeLevel).xpMultiplier;

    // Apply Quick Learner talent bonus
    int quickLearnerLevel = talents.getTalentLevel('quick_learner');
    double talentBonus = 1 + (quickLearnerLevel * 0.05);

    int adjustedAmount = (amount * xpMultiplier * talentBonus).round();

    experience += adjustedAmount;
    while (experience >= experienceForNextLevel) {
      levelUp();
    }
    notifyListeners();
  }

  void levelUp() {
    level++;
    experience -= experienceForNextLevel;
    notifyListeners();
  }

  int get experienceForNextLevel => level * 100;

  double get levelProgress => experience / experienceForNextLevel;

  void improveSkill(String skillName, int amount) {
    if (skills.containsKey(skillName)) {
      // Apply skill-specific talent bonuses
      if (skillName == 'Charisma' &&
          talents.getTalentLevel('social_butterfly') > 0) {
        amount =
            (amount * (1 + talents.getTalentLevel('social_butterfly') * 0.1))
                .round();
      } else if (skillName == 'Constitution' &&
          talents.getTalentLevel('iron_body') > 0) {
        amount =
            (amount * (1 + talents.getTalentLevel('iron_body') * 0.1)).round();
      }

      skills[skillName]!.addXp(amount);
      notifyListeners();
    }
  }

  void gatherResource(String resourceName, int amount) {
    resources[resourceName] = (resources[resourceName] ?? 0) + amount;
    notifyListeners();
  }

  void updateFrom(Character other) {
    name = other.name;
    baseClass = other.baseClass;
    skills = Map.from(other.skills);
    prestigeLevel = other.prestigeLevel;
    talents = other.talents;
    notifyListeners();
  }

  void prestige() {
    if (canPrestige()) {
      prestigeLevel++;
      resetSkills();
      notifyListeners();
    }
  }

  bool canPrestige() {
    // Define your prestige requirements here
    int totalLevel = skills.values.fold(0, (sum, skill) => sum + skill.level);
    return totalLevel >= 1000 &&
        prestigeLevel < PrestigeSystem().levels.length - 1;
  }

  void resetSkills() {
    skills.forEach((key, skill) {
      skill.setLevel(1);
      skill.setXp(0);
    });
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'baseClass': baseClass.toString().split('.').last,
      'skills': skills.map((key, value) => MapEntry(key, value.toJson())),
      'unlockedSkills': unlockedSkills.toList(),
      'job': job,
      'level': level,
      'experience': experience,
      'resources': resources,
      'prestigeLevel': prestigeLevel,
      'talents': talents.unlockedTalents,
      'talentPoints': talentPoints,
    };
  }

  static Character fromJson(Map<String, dynamic> json) {
    return Character(
      name: json['name'],
      baseClass: BaseClass.values
          .firstWhere((e) => e.toString().split('.').last == json['baseClass']),
      skills: (json['skills'] as Map<String, dynamic>).map(
        (key, value) => MapEntry(key, Skill.fromJson(value)),
      ),
      unlockedSkills: Set<String>.from(json['unlockedSkills']),
      job: json['job'],
      level: json['level'] ?? 1,
      experience: json['experience'] ?? 0,
      resources: Map<String, int>.from(json['resources'] ?? {}),
      prestigeLevel: json['prestigeLevel'] ?? 0,
      talents: ts.PlayerTalents()
        ..unlockedTalents = Map<String, int>.from(json['talents'] ?? {}),
      talentPoints: json['talentPoints'] ?? 0,
    );
  }
}