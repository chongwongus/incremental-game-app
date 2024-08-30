import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'character.dart';

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: Consumer<Character>(
        builder: (context, character, child) {
          return SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 20),
                CircleAvatar(
                  radius: 50,
                  child: Text(
                    character.name.substring(0, 1).toUpperCase(),
                    style: TextStyle(fontSize: 40),
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  character.name,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Text(
                  'Class: ${character.baseClass.toString().split('.').last}',
                  style: TextStyle(fontSize: 18),
                ),
                Text(
                  'Job: ${character.job}',
                  style: TextStyle(fontSize: 18),
                ),
                SizedBox(height: 20),
                Text(
                  'Total Level: ${_calculateTotalLevel(character)}',
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
                    itemCount: character.skills.length,
                    itemBuilder: (context, index) {
                      final skill = character.skills.values.elementAt(index);
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(skill.icon, size: 24),
                              Text(skill.name),
                              Text('Level ${skill.level}'),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  int _calculateTotalLevel(Character character) {
    return character.skills.values.fold(0, (sum, skill) => sum + skill.level);
  }
}