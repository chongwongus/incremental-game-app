// character.dart
import 'skill.dart';

enum BaseClass { melee, ranged, magic }

class Character {
  String name;
  BaseClass baseClass;
  Map<String, Skill> skills;
  String job;

  Character({
    required this.name,
    required this.baseClass,
    required this.skills,
    this.job = 'Novice',
  });

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

  // Add toJson method
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'baseClass': baseClass.toString().split('.').last,
      'skills': skills.map((key, value) => MapEntry(key, value.toJson())),
      'job': job,
    };
  }

  // Add fromJson method
  static Character fromJson(Map<String, dynamic> json) {
    return Character(
      name: json['name'],
      baseClass: BaseClass.values.firstWhere(
          (e) => e.toString().split('.').last == json['baseClass']),
      skills: (json['skills'] as Map<String, dynamic>).map(
        (key, value) => MapEntry(key, Skill.fromJson(value)),
      ),
      job: json['job'],
    );
  }
}