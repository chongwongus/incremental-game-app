// character.dart

import 'package:flutter/foundation.dart';
import 'skill.dart';

enum BaseClass { melee, ranged, magic }

class Character extends ChangeNotifier {
  String name;
  BaseClass baseClass;
  Map<String, Skill> skills;
  String job;
  int level;
  int experience;
  Map<String, int> resources;

  Character({
    required this.name,
    required this.baseClass,
    required this.skills,
    this.job = 'Novice',
    this.level = 1,
    this.experience = 0,
    Map<String, int>? resources,
  }) : resources = resources ?? {'Wood': 0, 'Fish': 0, 'Ore': 0};

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
    experience += amount;
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
    // Update any other properties as needed
    notifyListeners();
  }


  // Update toJson and fromJson methods to include new properties
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'baseClass': baseClass.toString().split('.').last,
      'skills': skills.map((key, value) => MapEntry(key, value.toJson())),
      'job': job,
      'level': level,
      'experience': experience,
      'resources': resources,
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
      job: json['job'],
      level: json['level'] ?? 1,
      experience: json['experience'] ?? 0,
      resources: Map<String, int>.from(json['resources'] ?? {}),
    );
  }
}
