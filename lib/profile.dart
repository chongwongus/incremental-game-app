import 'package:flutter/material.dart';
import 'skill.dart';
import 'persistence_service.dart';
import 'character.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final PersistenceService _persistenceService = PersistenceService();
  List<Skill> skills = [];
  Character? character;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    skills = await _persistenceService.getSkills();
    character = await _persistenceService.getCharacter();
    setState(() {});
  }

  int _calculateTotalLevel() {
    return skills.fold(0, (sum, skill) => sum + skill.level);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 20),
            CircleAvatar(
              radius: 50,
              child: Text(
                character?.name.substring(0, 1).toUpperCase() ?? 'P',
                style: TextStyle(fontSize: 40),
              ),
            ),
            SizedBox(height: 10),
            Text(
              character?.name ?? 'Player',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            if (character != null) ...[
              SizedBox(height: 10),
              Text(
                'Class: ${character!.baseClass.toString().split('.').last}',
                style: TextStyle(fontSize: 18),
              ),
              Text(
                'Job: ${character!.job}',
                style: TextStyle(fontSize: 18),
              ),
            ],
            SizedBox(height: 20),
            Text(
              'Total Level: ${_calculateTotalLevel()}',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 2.5,
                ),
                itemCount: skills.length,
                itemBuilder: (context, index) {
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(skills[index].icon, size: 24),
                          Text(skills[index].name),
                          Text('Level ${skills[index].level}'),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}