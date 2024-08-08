import 'dart:convert';
import 'dart:core';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'skill.dart';
import 'skill_detail_page.dart';
import 'skill_achievements.dart';
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


@override
void initState() {
  super.initState();
  _loadSkills();
  achievements = createAchievements();

}

  Future<void> _loadSkills() async {
    final prefs = await SharedPreferences.getInstance();
    String? skillsJson = prefs.getString('skills');
    if (skillsJson != null) {
      List<dynamic> skillsList = jsonDecode(skillsJson);
      setState(() {
        skills = skillsList.map((skillJson) => Skill.fromJson(skillJson)).toList();
      });
    }
  }

  Future<void> _saveSkills() async {
    final prefs = await SharedPreferences.getInstance();
    String skillsJson = jsonEncode(skills.map((skill) => skill.toJson()).toList());
    await prefs.setString('skills', skillsJson);
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
          },
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
