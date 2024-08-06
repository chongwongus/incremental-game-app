import 'package:flutter/material.dart';
import 'achievement.dart';

class AchievementsPage extends StatelessWidget {
  final List<Achievement> achievements;
  final Map<String, Map<String, int>> skills;

  AchievementsPage({required this.achievements, required this.skills});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Achievements'),
      ),
      body: ListView.builder(
        itemCount: achievements.length,
        itemBuilder: (context, index) {
          final achievement = achievements[index];
          return ListTile(
            title: Text(achievement.title),
            subtitle: Text(achievement.description),
            trailing: Icon(
              achievement.unlocked ? Icons.star : Icons.star_border,
              color: achievement.unlocked ? Colors.yellow : Colors.grey,
            ),
          );
        },
      ),
    );
  }
}

