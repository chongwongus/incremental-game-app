import 'package:flutter/material.dart';
import 'skill.dart';
import 'persistence_service.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final PersistenceService _persistenceService = PersistenceService();
  List<Skill> skills = [];
  String username = "Player"; // You can implement a way to set/change this

  @override
  void initState() {
    super.initState();
    _loadSkills();
  }

  Future<void> _loadSkills() async {
    skills = await _persistenceService.getSkills();
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
                username[0].toUpperCase(),
                style: TextStyle(fontSize: 40),
              ),
            ),
            SizedBox(height: 10),
            Text(
              username,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
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