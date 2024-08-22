import 'package:flutter/material.dart';
import 'character.dart';
import 'skill.dart';

class CharacterCreationScreen extends StatefulWidget {
  @override
  _CharacterCreationScreenState createState() => _CharacterCreationScreenState();
}

class _CharacterCreationScreenState extends State<CharacterCreationScreen> {
  String name = '';
  BaseClass selectedClass = BaseClass.melee;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Create Your Character')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              decoration: InputDecoration(labelText: 'Character Name'),
              onChanged: (value) => setState(() => name = value),
            ),
            SizedBox(height: 20),
            Text('Choose Your Class:', style: TextStyle(fontSize: 18)),
            RadioListTile<BaseClass>(
              title: Text('Melee'),
              value: BaseClass.melee,
              groupValue: selectedClass,
              onChanged: (BaseClass? value) {
                setState(() => selectedClass = value!);
              },
            ),
            RadioListTile<BaseClass>(
              title: Text('Ranged'),
              value: BaseClass.ranged,
              groupValue: selectedClass,
              onChanged: (BaseClass? value) {
                setState(() => selectedClass = value!);
              },
            ),
            RadioListTile<BaseClass>(
              title: Text('Magic'),
              value: BaseClass.magic,
              groupValue: selectedClass,
              onChanged: (BaseClass? value) {
                setState(() => selectedClass = value!);
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              child: Text('Create Character'),
              onPressed: () {
                if (name.isNotEmpty) {
                  Character newCharacter = _createCharacter();
                  Navigator.pop(context, newCharacter);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Character _createCharacter() {
    Map<String, Skill> initialSkills = {
      'Strength': Skill(name: 'Strength', icon: Icons.fitness_center),
      'Constitution': Skill(name: 'Constitution', icon: Icons.favorite),
      'Intelligence': Skill(name: 'Intelligence', icon: Icons.psychology),
      'Wisdom': Skill(name: 'Wisdom', icon: Icons.lightbulb),
      'Charisma': Skill(name: 'Charisma', icon: Icons.people),
      'Defense': Skill(name: 'Defense', icon: Icons.shield),
      'Attack': Skill(name: 'Attack', icon: Icons.sports_kabaddi),
      'Agility': Skill(name: 'Agility', icon: Icons.directions_run),
    };

    switch (selectedClass) {
      case BaseClass.melee:
        initialSkills['Strength']!.setLevel(5);
        initialSkills['Constitution']!.setLevel(5);
        break;
      case BaseClass.ranged:
        initialSkills['Agility']!.setLevel(5);
        initialSkills['Attack']!.setLevel(5);
        break;
      case BaseClass.magic:
        initialSkills['Intelligence']!.setLevel(5);
        initialSkills['Wisdom']!.setLevel(5);
        break;
    }

    return Character(
      name: name,
      baseClass: selectedClass,
      skills: initialSkills,
    );
  }
}