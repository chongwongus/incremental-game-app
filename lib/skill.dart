import 'package:flutter/material.dart';
import 'dart:math' as math;

class Skill {
  final String name;
  final IconData icon;
  int level;
  int xp;

  Skill({required this.name, required this.icon, this.level = 1, this.xp = 0});

  

  Map<String, dynamic> toJson() => {
    'name': name,
    'level': level,
    'xp': xp,
  };

  factory Skill.fromJson(Map<String, dynamic> json) => Skill(
    name: json['name'],
    icon: _getIconForSkill(json['name']),
    level: json['level'],
    xp: json['xp'],
  );

  int getXpForLevel(int level) {
    if (level < 1 || level > 99) {
      throw ArgumentError('Level must be between 1 and 99');
    }
    
    double points = 0;
    double output = 0;
    
    for (int lvl = 1; lvl <= level; lvl++) {
      points += (lvl + 300 * math.pow(2, lvl / 7)).floor();
      if (lvl >= level) {
        return (output / 4).floor();
      }
      output = points / 4;
    }
    
    return 0; // This line should never be reached
  }

  int calculateLevel() {
    for (int i = 1; i <= 99; i++) {
      if (xp < getXpForLevel(i)) {
        return i - 1;
      }
    }
    return 99;
  }

  void updateLevel() {
  level = calculateLevel();
}

  int get xpForNextLevel {
    return level < 99 ? getXpForLevel(level + 1) : getXpForLevel(99);
  }

  void addXp(int amount) {
    xp += amount;
    level = calculateLevel();
  }
}


 IconData _getIconForSkill(String skillName) {
    switch (skillName) {
      case 'Strength': return Icons.fitness_center;
      case 'Constitution': return Icons.favorite;
      case 'Intelligence': return Icons.psychology;
      case 'Wisdom': return Icons.lightbulb;
      case 'Charisma': return Icons.people;
      case 'Defense': return Icons.shield;
      case 'Attack': return Icons.sports_kabaddi;
      case 'Agility': return Icons.directions_run;
      case 'Cooking': return Icons.restaurant;
      case 'Crafting': return Icons.build;
      case 'Woodcutting': return Icons.nature;
      case 'Farming': return Icons.agriculture;
      case 'Dungoneering': return Icons.explore;
      case 'Prayer': return Icons.self_improvement;
      case 'Fishing': return Icons.catching_pokemon;
      default: return Icons.star;
    }
  }

