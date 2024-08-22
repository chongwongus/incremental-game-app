import 'package:flutter/material.dart';
import 'dart:math';
import 'character.dart';
import 'combat.dart';

class CombatScreen extends StatefulWidget {
  final Character character;

  CombatScreen({required this.character});

  @override
  _CombatScreenState createState() => _CombatScreenState();
}

class _CombatScreenState extends State<CombatScreen> {
  late Enemy currentEnemy;
  List<String> combatLog = [];

  @override
  void initState() {
    super.initState();
    currentEnemy = Enemy.goblin(); // Start with a goblin enemy
  }

  void performCombatRound() {
    setState(() {
      // Player attacks enemy
      int playerDamage = CombatSystem.calculateDamage(widget.character, currentEnemy);
      currentEnemy.skills['Constitution']!.setXp(currentEnemy.skills['Constitution']!.xp - playerDamage * 10);
      combatLog.add('${widget.character.name} deals $playerDamage damage to ${currentEnemy.name}');

      // Check if enemy is defeated
      if (currentEnemy.health <= 0) {
        combatLog.add('${currentEnemy.name} is defeated!');
        // Give experience to the player
        widget.character.skills['Attack']!.addXp(20);
        widget.character.skills['Strength']!.addXp(15);
        widget.character.skills['Defense']!.addXp(10);
        // Spawn a new enemy
        currentEnemy = Enemy.goblin();
        combatLog.add('A new ${currentEnemy.name} appears!');
        return;
      }

      // Enemy attacks player
      int enemyDamage = CombatSystem.calculateDamage(currentEnemy, widget.character);
      widget.character.skills['Constitution']!.setXp(widget.character.skills['Constitution']!.xp - enemyDamage * 10);
      combatLog.add('${currentEnemy.name} deals $enemyDamage damage to ${widget.character.name}');

      // Check if player is defeated
      if (widget.character.health <= 0) {
        combatLog.add('${widget.character.name} is defeated!');
        // Handle player defeat (e.g., return to main screen, heal player, etc.)
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Combat')),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: combatLog.map((log) => Text(log)).toList(),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${widget.character.name}: ${widget.character.health} HP'),
                Text('${currentEnemy.name}: ${currentEnemy.health} HP'),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: performCombatRound,
            child: Text('Attack'),
          ),
        ],
      ),
    );
  }
}