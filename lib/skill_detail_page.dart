import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'skill.dart';
import 'talent_system.dart';
import 'persistence_service.dart';
import 'achievement.dart';
import 'achievements_page.dart';

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
  @override
  Widget build(BuildContext context) {
    final playerTalents = Provider.of<PlayerTalents>(context);

    return Scaffold(
      appBar: AppBar(title: Text(widget.skill.name)),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SkillOverview(skill: widget.skill),
              SizedBox(height: 24),
              Text(
                'Related Talents',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              SizedBox(height: 16),
              RelatedTalents(
                skill: widget.skill,
                playerTalents: playerTalents,
              ),
              SizedBox(height: 24),
              Text(
                'Achievements',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              SizedBox(height: 16),
              AchievementsList(achievements: widget.achievements),
            ],
          ),
        ),
      ),
    );
  }
}

class SkillOverview extends StatelessWidget {
  final Skill skill;

  SkillOverview({required this.skill});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(skill.icon, size: 48, color: Theme.of(context).primaryColor),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Level ${skill.level}',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Text(
                        'XP: ${skill.xp} / ${skill.xpForNextLevel}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            LinearProgressIndicator(
              value: skill.xp / skill.xpForNextLevel,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
            ),
          ],
        ),
      ),
    );
  }
}

class SkillTalents extends StatelessWidget {
  final Skill skill;
  final PlayerTalents playerTalents;

  SkillTalents({
    required this.skill,
    required this.playerTalents,
  });

  @override
  Widget build(BuildContext context) {
    final skillTalents = TalentTree().talents.where((t) => t.relatedSkill == skill.name).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Skill Talents',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        SizedBox(height: 16),
        ...skillTalents.map((talent) {
          final currentLevel = playerTalents.getTalentLevel(talent.id);
          return Card(
            child: ListTile(
              title: Text(talent.name),
              subtitle: Text(talent.description),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('$currentLevel/${talent.maxLevel}'),
                  SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: playerTalents.canUnlockTalent(talent.id)
                        ? () => playerTalents.unlockTalent(talent.id)
                        : null,
                    child: Text('Upgrade'),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ],
    );
  }
}


class RelatedTalents extends StatelessWidget {
  final Skill skill;
  final PlayerTalents playerTalents;

  RelatedTalents({required this.skill, required this.playerTalents});

  @override
  Widget build(BuildContext context) {
    final relatedTalents = TalentTree().talents.where((t) => t.relatedSkill == skill.name).toList();

    return Column(
      children: relatedTalents.map((talent) {
        final isUnlocked = playerTalents.isTalentUnlocked(talent.id);
        return ListTile(
          title: Text(talent.name),
          subtitle: Text(talent.description),
          trailing: Icon(
            isUnlocked ? Icons.check_circle : Icons.lock,
            color: isUnlocked ? Colors.green : Colors.grey,
          ),
        );
      }).toList(),
    );
  }
}

class AchievementsList extends StatelessWidget {
  final List<Achievement> achievements;

  AchievementsList({required this.achievements});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: achievements.map((achievement) {
        return ListTile(
          title: Text(achievement.title),
          subtitle: Text(achievement.description),
          trailing: Icon(
            achievement.unlocked ? Icons.star : Icons.star_border,
            color: achievement.unlocked ? Colors.yellow : Colors.grey,
          ),
        );
      }).toList(),
    );
  }
}