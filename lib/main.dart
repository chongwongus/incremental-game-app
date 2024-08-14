import 'dart:convert';
import 'dart:core';
import 'package:flutter/material.dart';
import 'skill.dart';
import 'persistence_service.dart';
import 'skill_detail_page.dart';
import 'skill_achievements.dart';
import 'achievements_page.dart';
import 'achievement.dart';
import 'daily.dart';
import 'dart:async';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Life Stats Tracker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Skill> skills = [];
  List<Achievement> achievements = [];
  late DailyQuestManager questManager;
  final PersistenceService _persistenceService = PersistenceService();

  @override
  void initState() {
    super.initState();
    _loadSkills().then((_) {
      setState(() {
        questManager = DailyQuestManager(updateSkill: updateSkill);
      });
      _loadDailyQuests();
    });
    achievements = createAchievements();
    Timer.periodic(Duration(hours: 1), (Timer t) => questManager.checkAndResetQuests());
  }

  Future<void> _loadDailyQuests() async {
    await questManager.loadQuests();
    setState(() {});
  }

  Future<void> _initializeSkills() async {
    print('Initializing skills for new user...');
    skills = [
      Skill(name: 'Strength', icon: Icons.fitness_center),
      Skill(name: 'Constitution', icon: Icons.favorite),
      Skill(name: 'Intelligence', icon: Icons.psychology),
      Skill(name: 'Wisdom', icon: Icons.lightbulb),
      Skill(name: 'Charisma', icon: Icons.people),
      Skill(name: 'Defense', icon: Icons.shield),
      Skill(name: 'Attack', icon: Icons.sports_kabaddi),
      Skill(name: 'Agility', icon: Icons.directions_run),
      Skill(name: 'Cooking', icon: Icons.restaurant),
      Skill(name: 'Crafting', icon: Icons.build),
      Skill(name: 'Woodcutting', icon: Icons.nature),
      Skill(name: 'Farming', icon: Icons.agriculture),
      Skill(name: 'Dungoneering', icon: Icons.explore),
      Skill(name: 'Prayer', icon: Icons.self_improvement),
      Skill(name: 'Fishing', icon: Icons.catching_pokemon),
    ];
    await _persistenceService.saveSkills(skills);
    print('Skills initialized and saved.');
  }

  Future<void> _loadSkills() async {
    print('Loading skills...');
    skills = await _persistenceService.getSkills();
    if (skills.isEmpty) {
      print('No skills data found. Initializing new skills...');
      await _initializeSkills();
    } else {
      print(
          'Skills loaded: ${skills.map((s) => '${s.name}: Lvl ${s.level}, XP ${s.xp}').join(', ')}');
    }
    setState(() {});
  }

  void updateSkill(String skillName, int expAmount) {
    setState(() {
      var skill = skills.firstWhere((s) => s.name == skillName);
      skill.addXp(expAmount);
      checkAchievements(skill);
      _persistenceService.saveSkills(skills);  // Save updated skills
    });
  }

  Future<void> _checkStoredData() async {
    skills = await _persistenceService.getSkills();
    print('Stored skills data: ${jsonEncode(skills.map((skill) => skill.toJson()).toList())}');
  }

  Skill incrementSkill(Skill skill) {
    skill.addXp(calculateXpGain(skill));
    _persistenceService.saveSkills(skills);
    return skill;
  }

  int calculateXpGain(Skill skill) {
    int baseXp = 10;
    int levelBonus = (skill.level / 10).floor();
    return baseXp + levelBonus;
  }

  void addExpToSkill(String skillName, int expAmount) {
    var skill = skills.firstWhere((s) => s.name == skillName);
    setState(() {
      incrementSkill(skill);
    });
  }

  void _onSkillTap(Skill skill) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SkillDetailScreen(
          skill: skill,
          achievements: achievements.where((a) => a.skillName == skill.name).toList(),
        ),
      ),
    );
  }

  void checkAchievements(Skill skill) {
    for (var achievement in achievements) {
      if (achievement.skillName == skill.name &&
          skill.level >= achievement.requiredLevel &&
          !achievement.unlocked) {
        achievement.unlocked = true;
        // You might want to show a notification here
        print('Achievement unlocked: ${achievement.title}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Skills')),
      body: Column(
        children: [
          ElevatedButton(
            child: Text('Daily Quests'),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DailyQuestScreen(
                    questManager: questManager,
                  ),
                ),
              ).then((_) => setState(() {}));
            },
          ),
          Expanded(
            child: SkillsScreen(
              skills: skills,
              onSkillTap: _onSkillTap,
            ),
          ),
        ],
      ),
    );
  }
}

class SkillsScreen extends StatelessWidget {
  final List<Skill> skills;
  final Function(Skill) onSkillTap;

  SkillsScreen({required this.skills, required this.onSkillTap});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 2.5,
      ),
      itemCount: skills.length,
      itemBuilder: (context, index) {
        return SkillTile(
          skill: skills[index],
          onTap: () => onSkillTap(skills[index]),
        );
      },
    );
  }
}

class SkillTile extends StatelessWidget {
  final Skill skill;
  final VoidCallback onTap;

  SkillTile({required this.skill, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 2,
        child: Container(
          padding: EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(skill.icon, size: 24, color: Colors.blue[800]),
              SizedBox(height: 4),
              ValueListenableBuilder<int>(
                valueListenable: skill.levelNotifier,
                builder: (context, level, child) {
                  return Text(
                    '$level/99',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
