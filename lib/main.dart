import 'dart:convert';
import 'dart:core';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'skill.dart';
import 'skill_detail_page.dart';
import 'skill_achievements.dart';
import 'achievements_page.dart';
import 'achievement.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SharedPreferences.getInstance();
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
  List<Skill> skills = [
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
  List<Achievement> achievements = [];

  Future<void> _checkPersistedData() async {
    final prefs = await SharedPreferences.getInstance();
    print('Persisted test value: ${prefs.getString('test_key')}');
    print('Persisted skills data: ${prefs.getString('skills')}');
  }

  @override
  void initState() {
    super.initState();
    _checkPersistedData();
    _loadSkills();
    achievements = createAchievements();
  }

  Future<void> _testSharedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('test_key', 'test_value');
    print('Test value set: ${prefs.getString('test_key')}');
  }

  // Create a method to check the test value
  Future<void> _checkTestValue() async {
    final prefs = await SharedPreferences.getInstance();
    print('Test value retrieved: ${prefs.getString('test_key')}');
  }

  Future<void> _loadSkills() async {
    print('Loading skills...');
    final prefs = await SharedPreferences.getInstance();
    String? skillsJson = prefs.getString('skills');
    print('Loaded skills JSON: $skillsJson');
    if (skillsJson != null) {
      List<dynamic> skillsList = jsonDecode(skillsJson);
      setState(() {
        skills = skillsList.map((skillJson) => Skill.fromJson(skillJson)).toList();
      });
      print('Skills loaded: ${skills.map((s) => '${s.name}: Lvl ${s.level}, XP ${s.xp}').join(', ')}');
    } else {
      print('No skills data found in storage');
    }
  }


  Future<void> _saveSkills() async {
    print('Saving skills...');
    final prefs = await SharedPreferences.getInstance();
    String skillsJson = jsonEncode(skills.map((skill) => skill.toJson()).toList());
    await prefs.setString('skills', skillsJson);
    print('Skills saved: $skillsJson');  // Debug print

    // Verify the save immediately
    String? savedData = prefs.getString('skills');
    print('Verification - Skills in storage: $savedData');

  }

  Future<void> _checkStoredData() async {
    final prefs = await SharedPreferences.getInstance();
    String? skillsJson = prefs.getString('skills');
    print('Stored skills data: $skillsJson');
  }


  Skill incrementSkill(Skill skill) {
    skill.addXp(calculateXpGain(skill));
    _saveSkills();
    return skill;
  }

  int calculateXpGain(Skill skill) {
    int baseXp = 10;
    int levelBonus = (skill.level / 10).floor();
    return baseXp + levelBonus;
  }

  void _onSkillTap(Skill skill) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SkillDetailScreen(
          skill: skill,
          onTrain: (updatedSkill) {
            setState(() {
              incrementSkill(updatedSkill);
              checkAchievements(updatedSkill);
            });
            _saveSkills();  // Call this after setState
          },
          achievements: achievements.where((a) => a.skillName == skill.name).toList(),
        ),
      ),
    ).then((_) => _saveSkills());  // Also save when returning from the detail screen
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

// In your build method:
@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(title: Text('Skills')),
    body: SkillsScreen(
      skills: skills,
      onSkillTap: _onSkillTap,
    ),
  );
}
}
