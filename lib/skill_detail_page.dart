import 'package:flutter/material.dart';

class SkillDetailPage extends StatelessWidget {
  final String skillName;
  final int level;
  final int xp;
  final int xpForNextLevel;

  SkillDetailPage({
    required this.skillName,
    required this.level,
    required this.xp,
    required this.xpForNextLevel,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(skillName),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Level: $level', style: Theme.of(context).textTheme.titleLarge),
            SizedBox(height: 20),
            Text('XP: $xp / $xpForNextLevel'),
            SizedBox(height: 10),
            LinearProgressIndicator(
              value: xp / xpForNextLevel,
              minHeight: 10,
            ),
            SizedBox(height: 20),
            Text('Activities to increase this skill:'),
            SizedBox(height: 10),
            _buildActivityList(),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityList() {
    // This is where you'd add activities specific to each skill
    List<String> activities = [
      'Activity 1',
      'Activity 2',
      'Activity 3',
    ];

    return Column(
      children: activities.map((activity) => 
        ListTile(
          leading: Icon(Icons.star),
          title: Text(activity),
        )
      ).toList(),
    );
  }
}