import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'character.dart';
import 'skill.dart';
import 'persistence_service.dart';
import 'main.dart'; // Import this to access HomePage

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
              onPressed: () => _createAndSaveCharacter(context),
            ),
          ],
        ),
      ),
    );
  }

  void _createAndSaveCharacter(BuildContext context) {
    if (name.isNotEmpty) {
      Character newCharacter = _createCharacter();
      
      // Save the character
      context.read<PersistenceService>().saveCharacter(newCharacter);
      
      // Update the Character provider
      context.read<Character>().updateFrom(newCharacter);

      // Navigate to HomePage
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    }
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
    'Woodcutting': Skill(name: 'Woodcutting', icon: Icons.nature),
    'Fishing': Skill(name: 'Fishing', icon: Icons.catching_pokemon),
    'Mining': Skill(name: 'Mining', icon: Icons.handyman),
    'Cooking': Skill(name: 'Cooking', icon: Icons.restaurant),
    'Crafting': Skill(name: 'Crafting', icon: Icons.build),
    'Farming': Skill(name: 'Farming', icon: Icons.agriculture),
    'Prayer': Skill(name: 'Prayer', icon: Icons.self_improvement),
  };

    switch (selectedClass) {
      case BaseClass.melee:
        initialSkills['Strength']!.setLevel(1);
        initialSkills['Constitution']!.setLevel(1);
        break;
      case BaseClass.ranged:
        initialSkills['Agility']!.setLevel(1);
        initialSkills['Attack']!.setLevel(1);
        break;
      case BaseClass.magic:
        initialSkills['Intelligence']!.setLevel(1);
        initialSkills['Wisdom']!.setLevel(1);
        break;
    }

    return Character(
      name: name,
      baseClass: selectedClass,
      skills: initialSkills,
    );
  }
}