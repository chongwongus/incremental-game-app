import 'package:flutter/material.dart';
import 'skill.dart';
import 'achievement.dart';
import 'achievements_page.dart';
import 'persistence_service.dart';

class SkillDetailScreen extends StatefulWidget {
  final Skill skill;
  final List<Achievement> achievements;

  SkillDetailScreen({
    required this.skill,
    required this.achievements,
  });

  @override
  _SkillDetailScreenState createState() => _SkillDetailScreenState();
}

class _SkillDetailScreenState extends State<SkillDetailScreen> {
  final PersistenceService _persistenceService = PersistenceService();

  @override
  void initState() {
    super.initState();
    _loadSkillData();
  }

Future<void> _loadSkillData() async {
  final skill = await _persistenceService.getSkill(widget.skill.name);
  if (skill != null) {
    setState(() {
      widget.skill.setXp(skill.xp);  // Update XP
      widget.skill.setLevel(skill.level);  // Update level using the setLevel method
    });
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.skill.name),
      ),
      body: ValueListenableBuilder<int>(
        valueListenable: widget.skill.xpNotifier,
        builder: (context, xp, child) {
          double progressToNextLevel = xp == widget.skill.xpForNextLevel
              ? 1.0
              : (xp - widget.skill.getXpForLevel(widget.skill.level)) /
                  (widget.skill.xpForNextLevel - widget.skill.getXpForLevel(widget.skill.level));

          progressToNextLevel = progressToNextLevel.clamp(0.0, 1.0);

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(widget.skill.icon, size: 48, color: Colors.blue[800]),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ValueListenableBuilder<int>(
                              valueListenable: widget.skill.levelNotifier,
                              builder: (context, level, child) {
                                return Text(
                                  'Level $level',
                                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                                );
                              },
                            ),
                            Text(
                              'XP: $xp / ${widget.skill.xpForNextLevel}',
                              style: TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  LinearProgressIndicator(
                    value: progressToNextLevel,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                  ),
                  SizedBox(height: 24),
                  Text(
                    'Achievements',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Container(
                    height: 200,
                    child: AchievementsWidget(
                      achievements: widget.achievements,
                      skillName: widget.skill.name,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
