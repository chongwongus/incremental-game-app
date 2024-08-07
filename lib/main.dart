import 'dart:convert';
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

class Skill {
  final String name;
  final IconData icon;
  int level;
  int xp;

  Skill({required this.name, required this.icon, this.level = 1, this.xp = 0});

  

  Map<String, dynamic> toJson() => {
    'name': name,
    'level': level,
    'xp': xp,
  };

  factory Skill.fromJson(Map<String, dynamic> json) => Skill(
    name: json['name'],
    icon: _getIconForSkill(json['name']),
    level: json['level'],
    xp: json['xp'],
  );
int getXpForLevel(int level) {
  if (level < 1 || level > 99) {
    throw ArgumentError('Level must be between 1 and 99');
  }
  return (0.25 * level * (level - 1)).floor();
}

    int calculateLevel() {
    for (int i = 1; i <= 99; i++) {
      if (xp < getXpForLevel(i)) {
        return i - 1;
      }
    }
    return 99;
  }

  int get xpForNextLevel {
    return level < 99 ? getXpForLevel(level + 1) : getXpForLevel(99);
  }

  void addXp(int amount) {
    xp += amount;
    level = calculateLevel();
  }
}


 IconData _getIconForSkill(String skillName) {
    switch (skillName) {
      case 'Strength': return Icons.fitness_center;
      case 'Constitution': return Icons.favorite;
      case 'Intelligence': return Icons.psychology;
      case 'Wisdom': return Icons.lightbulb;
      case 'Charisma': return Icons.people;
      case 'Defense': return Icons.shield;
      case 'Attack': return Icons.sports_kabaddi;
      case 'Agility': return Icons.directions_run;
      case 'Cooking': return Icons.restaurant;
      case 'Crafting': return Icons.build;
      case 'Woodcutting': return Icons.nature;
      case 'Farming': return Icons.agriculture;
      case 'Dungoneering': return Icons.explore;
      case 'Prayer': return Icons.self_improvement;
      case 'Fishing': return Icons.catching_pokemon;
      default: return Icons.star;
    }
  }



class SkillTile extends StatelessWidget {
  final Skill skill;
  final VoidCallback onTrain;

  SkillTile({required this.skill, required this.onTrain});

  @override
  Widget build(BuildContext context) {
    double progressToNextLevel = (skill.xp - skill.getXpForLevel(skill.level)) / 
                                 (skill.xpForNextLevel - skill.getXpForLevel(skill.level));

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(skill.icon, size: 40, color: Colors.blue[800]),
            SizedBox(height: 8),
            Text(
              skill.name,
              style: TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            Text(
              'Level ${skill.level}',
              style: TextStyle(fontSize: 12),
            ),
            SizedBox(height: 8),
            ElevatedButton(
              child: Text('Train'),
              onPressed: onTrain,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromARGB(255, 238, 160, 234),

                 // NEED TO BE FIXED
                 // NEED TO BE FIXED
                 // NEED TO BE FIXED

                minimumSize: Size(double.maxFinite, 30),
                
                 // NEED TO BE FIXED
                 // NEED TO BE FIXED
                 // NEED TO BE FIXED
                 
              ),
            ),
            SizedBox(height: 8),
            LinearProgressIndicator(
              value: progressToNextLevel,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
            ),
            SizedBox(height: 4),
            Text(
              'XP: ${skill.xp} / ${skill.xpForNextLevel}',
              style: TextStyle(fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }
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

@override
void initState() {
  super.initState();
  _loadSkills();
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



  void incrementSkill(Skill skill) {
    setState(() {
      skill.addXp(100 * skill.level);
      _saveSkills();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Life Skills Tracker'),
        backgroundColor: Colors.blue[800],
      ),
      body: GridView.builder(
        padding: EdgeInsets.all(16),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 0.75,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: skills.length,
        itemBuilder: (context, index) {
          return SkillTile(
            skill: skills[index],
            onTrain: () => incrementSkill(skills[index]),
          );
        },
      ),
    );
  }
}
