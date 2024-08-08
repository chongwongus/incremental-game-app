import 'package:flutter/material.dart';
import 'achievement.dart';
import 'achievements_page.dart';

class SkillAchievements extends StatelessWidget {
  final String skillName;
  final List<Achievement> achievements;

  SkillAchievements({required this.skillName, required this.achievements});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            'Achievements',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        Container(
          height: 200, // Adjust as needed
          child: AchievementsWidget(achievements: achievements, skillName: skillName),
        ),
      ],
    );
  }
}