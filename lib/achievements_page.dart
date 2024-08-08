import 'package:flutter/material.dart';
import 'achievement.dart';

class AchievementsWidget extends StatelessWidget {
  final List<Achievement> achievements;
  final String? skillName;

  AchievementsWidget({required this.achievements, this.skillName});

  @override
  Widget build(BuildContext context) {
    final filteredAchievements = skillName != null
        ? achievements.where((a) => a.skillName == skillName).toList()
        : achievements;

    return ListView.builder(
      itemCount: filteredAchievements.length,
      itemBuilder: (context, index) {
        final achievement = filteredAchievements[index];
        return ListTile(
          title: Text(achievement.title),
          subtitle: Text(achievement.description),
          trailing: Icon(
            achievement.unlocked ? Icons.star : Icons.star_border,
            color: achievement.unlocked ? Colors.yellow : Colors.grey,
          ),
        );
      },
    );
  }
}

class AchievementsPage extends StatelessWidget {
  final List<Achievement> achievements;

  AchievementsPage({required this.achievements});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Achievements'),
      ),
      body: AchievementsWidget(achievements: achievements),
    );
  }
}