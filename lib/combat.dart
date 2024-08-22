import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'character.dart';
import 'skill.dart';

class Enemy extends Character {
  Enemy({
    required String name,
    required BaseClass baseClass,
    required Map<String, Skill> skills,
  }) : super(
          name: name,
          baseClass: baseClass,
          skills: skills,
          job: 'Enemy',
        );

  factory Enemy.goblin() {
    return Enemy(
      name: 'Goblin',
      baseClass: BaseClass.melee,
      skills: {
        'Strength': Skill(name: 'Strength', icon: Icons.fitness_center, level: 5),
        'Constitution': Skill(name: 'Constitution', icon: Icons.favorite, level: 3),
        'Attack': Skill(name: 'Attack', icon: Icons.sports_kabaddi, level: 4),
        'Defense': Skill(name: 'Defense', icon: Icons.shield, level: 2),
      },
    );
  }

  // Add more factory methods for different enemy types
}

class CombatSystem {
  static int calculateDamage(Character attacker, Character defender) {
    int baseDamage = attacker.attackPower - (defender.defensePower ~/ 2);
    return math.max(1, baseDamage); // Ensure at least 1 damage is dealt
  }

  static void performAttack(Character attacker, Character defender) {
    int damage = calculateDamage(attacker, defender);
    int newConstitutionXp = math.max(0, defender.skills['Constitution']!.xp - damage * 10);
    defender.skills['Constitution']!.setXp(newConstitutionXp);
    
    attacker.skills['Attack']!.addXp(damage);
    switch (attacker.baseClass) {
      case BaseClass.melee:
        attacker.skills['Strength']!.addXp(damage);
        break;
      case BaseClass.ranged:
        attacker.skills['Agility']!.addXp(damage);
        break;
      case BaseClass.magic:
        attacker.skills['Intelligence']!.addXp(damage);
        attacker.skills['Wisdom']!.addXp(damage);
        break;
    }
  }
}