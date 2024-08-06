import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'skill_detail_page.dart';
import 'achievements_page.dart';
import 'achievement.dart';


void main() {
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
  Map<String, Map<String, int>> skills = {
    'Strength': {'level': 1, 'xp': 0},
    'Agility': {'level': 1, 'xp': 0},
    'Cooking': {'level': 1, 'xp': 0},
    'Woodcutting': {'level': 1, 'xp': 0},
  };

  int xpForNextLevel(int level) {
    return 100 * level;  // Simple XP curve, adjust as needed
  }

  @override
  void initState() {
    super.initState();
    _loadSkills();
  }

  _loadSkills() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      skills.forEach((skill, data) {
        data['level'] = prefs.getInt('${skill}_level') ?? 1;
        data['xp'] = prefs.getInt('${skill}_xp') ?? 0;
      });
    });
  }

  _saveSkill(String skill) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('${skill}_level', skills[skill]!['level']!);
    await prefs.setInt('${skill}_xp', skills[skill]!['xp']!);
  }

    List<Achievement> achievements = [
    Achievement(
      id: 'strength_5',
      title: 'Novice Strongman',
      description: 'Reach level 5 in Strength',
      requirements: {'Strength': 5},
    ),
    Achievement(
      id: 'multi_skill_10',
      title: 'Jack of All Trades',
      description: 'Reach level 10 in three different skills',
      requirements: {'any': 10},
    ),
    // Add more achievements as needed
  ];

  void checkAchievements() {
    for (var achievement in achievements) {
      if (!achievement.unlocked) {
        bool requirementsMet = true;
        achievement.requirements.forEach((skill, level) {
          if (skill == 'any') {
            int skillsAtLevel = skills.values.where((s) => s['level']! >= level).length;
            if (skillsAtLevel < 3) requirementsMet = false;
          } else {
            int skillLevel = skills[skill]?['level'] ?? 0;
            if (skillLevel < level) {
              requirementsMet = false;
            }
          }
        });
        if (requirementsMet) {
          setState(() {
            achievement.unlocked = true;
          });
          // You could show a notification here
        }
      }
    }
  }

  void incrementSkill(String skill) {
    setState(() {
      skills[skill]!['xp'] = (skills[skill]!['xp'] ?? 0) + 10;
      if (skills[skill]!['xp']! >= xpForNextLevel(skills[skill]!['level']!)) {
        skills[skill]!['level'] = (skills[skill]!['level'] ?? 1) + 1;
        skills[skill]!['xp'] = 0;
      }
      _saveSkill(skill);
      checkAchievements();  // Check achievements after incrementing a skill
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Life Stats Tracker'),
        actions: [
          IconButton(
            icon: Icon(Icons.emoji_events),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AchievementsPage(
                    achievements: achievements,
                    skills: skills,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: skills.length,
        itemBuilder: (context, index) {
          String skill = skills.keys.elementAt(index);
          int level = skills[skill]!['level'] ?? 1;
          int xp = skills[skill]!['xp'] ?? 0;
          return ListTile(
            title: Text(skill),
            subtitle: Text('Level: $level - XP: $xp/${xpForNextLevel(level)}'),
            trailing: ElevatedButton(
              child: Text('Train'),
              onPressed: () => incrementSkill(skill),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SkillDetailPage(
                    skillName: skill,
                    level: level,
                    xp: xp,
                    xpForNextLevel: xpForNextLevel(level),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
