import 'package:flutter/material.dart';
import 'skill.dart';
import 'achievement.dart';
import 'achievements_page.dart';
import 'persistence_service.dart';



class SkillDetailScreen extends StatefulWidget {
  final Skill skill;
  final Function(Skill) onTrain;
  final List<Achievement> achievements;

  SkillDetailScreen({
    required this.skill,
    required this.onTrain,
    required this.achievements,
  });

  @override
  _SkillDetailScreenState createState() => _SkillDetailScreenState();
}

class _SkillDetailScreenState extends State<SkillDetailScreen> {
  late Skill skill;
  final PersistenceService _persistenceService = PersistenceService();

@override
void initState() {
  super.initState();
  skill = widget.skill;
  _loadSkillData();
  
  // Add a listener to update skill data when the screen gains focus
  WidgetsBinding.instance.addPostFrameCallback((_) {
    final focusNode = FocusNode();
    FocusScope.of(context).requestFocus(focusNode);
    focusNode.addListener(() {
      if (focusNode.hasFocus) {
        _loadSkillData();
      }
    });
  });
}

Future<void> _loadSkillData() async {
  final skillData = await _persistenceService.getSkillData(skill.name);
  setState(() {
    skill.xp = skillData['exp']!;
    skill.updateLevel();
  });
}



  void _train() {
    setState(() {
      widget.onTrain(skill);
      skill.updateLevel();
    });
    _persistenceService.saveSkillData(skill.name, skill.level, skill.xp);
    print('Skill trained: ${skill.name}, Level: ${skill.level}, XP: ${skill.xp}');  // Debug print
  }



  @override
  Widget build(BuildContext context) {
    double progressToNextLevel = skill.xp == skill.xpForNextLevel 
        ? 1.0 
        : (skill.xp - skill.getXpForLevel(skill.level)) / 
          (skill.xpForNextLevel - skill.getXpForLevel(skill.level));

    progressToNextLevel = progressToNextLevel.clamp(0.0, 1.0);

    return Scaffold(
      appBar: AppBar(
        title: Text(skill.name),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(skill.icon, size: 48, color: Colors.blue[800]),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Level ${skill.level}',
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'XP: ${skill.xp} / ${skill.xpForNextLevel}',
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
              ElevatedButton(
                child: Text('Train'),
                onPressed: _train,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF784CEF), // Corrected line
                  minimumSize: Size(double.infinity, 50),
                ),
              ),
              SizedBox(height: 24),
              Text(
                'Achievements',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Container(
                height: 200, // Adjust this value as needed
                child: AchievementsWidget(
                  achievements: widget.achievements,
                  skillName: skill.name,
                ),
              ),
            ],
          ),
        ),
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
              Text(
                '${skill.level}/99',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
