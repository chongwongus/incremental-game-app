import 'dart:convert';
import 'dart:core';
import 'package:flutter/material.dart';
import 'skill.dart';
import 'persistence_service.dart';
import 'skill_detail_page.dart';
import 'skill_achievements.dart';
import 'achievements_page.dart';
import 'achievement.dart';
import 'daily.dart';
import 'profile.dart';
import 'dart:async';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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

class SkillSearchDelegate extends SearchDelegate<Skill> {
  final List<Skill> skills;
  final Function(Skill) onSkillTap;

  SkillSearchDelegate({required this.skills, required this.onSkillTap});

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, skills[0]);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = skills
        .where(
            (skill) => skill.name.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(results[index].name),
          leading: Icon(results[index].icon),
          onTap: () {
            onSkillTap(results[index]);
            close(context, results[index]);
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = skills
        .where(
            (skill) => skill.name.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(suggestions[index].name),
          leading: Icon(suggestions[index].icon),
          onTap: () {
            query = suggestions[index].name;
            showResults(context);
          },
        );
      },
    );
  }
}

class SkillFilterWidget extends StatefulWidget {
  final List<Skill> skills;
  final Function(List<Skill>) onFilterApplied;

  SkillFilterWidget({required this.skills, required this.onFilterApplied});

  @override
  _SkillFilterWidgetState createState() => _SkillFilterWidgetState();
}

class _SkillFilterWidgetState extends State<SkillFilterWidget> {
  List<String> selectedSkills = [];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Filter Skills',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.skills.map((skill) {
              return FilterChip(
                label: Text(skill.name),
                selected: selectedSkills.contains(skill.name),
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      selectedSkills.add(skill.name);
                    } else {
                      selectedSkills.remove(skill.name);
                    }
                  });
                },
              );
            }).toList(),
          ),
          SizedBox(height: 16),
          ElevatedButton(
            child: Text('Apply Filter'),
            onPressed: () {
              List<Skill> filteredSkills = selectedSkills.isEmpty
                  ? widget.skills
                  : widget.skills
                      .where((skill) => selectedSkills.contains(skill.name))
                      .toList();
              widget.onFilterApplied(filteredSkills);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}

class AddQuestDialog extends StatefulWidget {
  final Function(DailyQuest) onQuestAdded;

  AddQuestDialog({required this.onQuestAdded});

  @override
  _AddQuestDialogState createState() => _AddQuestDialogState();
}

class _AddQuestDialogState extends State<AddQuestDialog> {
  final _formKey = GlobalKey<FormState>();
  String title = '';
  String description = '';
  String relatedSkill = '';
  int expReward = 0;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add New Quest'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              decoration: InputDecoration(labelText: 'Title'),
              validator: (value) =>
                  value!.isEmpty ? 'Please enter a title' : null,
              onSaved: (value) => title = value!,
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Description'),
              validator: (value) =>
                  value!.isEmpty ? 'Please enter a description' : null,
              onSaved: (value) => description = value!,
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Related Skill'),
              validator: (value) =>
                  value!.isEmpty ? 'Please enter a related skill' : null,
              onSaved: (value) => relatedSkill = value!,
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'XP Reward'),
              keyboardType: TextInputType.number,
              validator: (value) =>
                  value!.isEmpty ? 'Please enter an XP reward' : null,
              onSaved: (value) => expReward = int.parse(value!),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          child: Text('Cancel'),
          onPressed: () => Navigator.of(context).pop(),
        ),
        ElevatedButton(
          child: Text('Add'),
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              _formKey.currentState!.save();
              widget.onQuestAdded(DailyQuest(
                title: title,
                description: description,
                relatedSkill: relatedSkill,
                expReward: expReward,
              ));
              Navigator.of(context).pop();
            }
          },
        ),
      ],
    );
  }
}

class _HomePageState extends State<HomePage> {
  List<Skill> skills = [];
  List<Achievement> achievements = [];
  late DailyQuestManager questManager;
  final PersistenceService _persistenceService = PersistenceService();
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadSkills().then((_) {
      setState(() {
        questManager = DailyQuestManager(updateSkill: updateSkill);
      });
      _loadDailyQuests();
    });
    achievements = createAchievements();
    Timer.periodic(
        Duration(hours: 1), (Timer t) => questManager.checkAndResetQuests());
  }

  Future<void> _loadDailyQuests() async {
    await questManager.loadQuests();
    setState(() {});
  }

  Future<void> _initializeSkills() async {
    print('Initializing skills for new user...');
    skills = [
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
    await _persistenceService.saveSkills(skills);
    print('Skills initialized and saved.');
  }

  Future<void> _loadSkills() async {
    print('Loading skills...');
    skills = await _persistenceService.getSkills();
    if (skills.isEmpty) {
      print('No skills data found. Initializing new skills...');
      await _initializeSkills();
    } else {
      print(
          'Skills loaded: ${skills.map((s) => '${s.name}: Lvl ${s.level}, XP ${s.xp}').join(', ')}');
    }
    setState(() {});
  }

  void updateSkill(String skillName, int expAmount) {
    setState(() {
      var skill = skills.firstWhere((s) => s.name == skillName);
      skill.addXp(expAmount);
      checkAchievements(skill);
      _persistenceService.saveSkills(skills); // Save updated skills
    });
  }

  Future<void> _checkStoredData() async {
    skills = await _persistenceService.getSkills();
    print(
        'Stored skills data: ${jsonEncode(skills.map((skill) => skill.toJson()).toList())}');
  }

  Skill incrementSkill(Skill skill) {
    skill.addXp(calculateXpGain(skill));
    _persistenceService.saveSkills(skills);
    return skill;
  }

  int calculateXpGain(Skill skill) {
    int baseXp = 10;
    int levelBonus = (skill.level / 10).floor();
    return baseXp + levelBonus;
  }

  void addExpToSkill(String skillName, int expAmount) {
    var skill = skills.firstWhere((s) => s.name == skillName);
    setState(() {
      incrementSkill(skill);
    });
  }

  void _onSkillTap(Skill skill) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SkillDetailScreen(
          skill: skill,
          achievements:
              achievements.where((a) => a.skillName == skill.name).toList(),
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

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _searchSkills() {
    showSearch(
      context: context,
      delegate: SkillSearchDelegate(skills: skills, onSkillTap: _onSkillTap),
    );
  }

  void _filterSkills() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SkillFilterWidget(
          skills: skills,
          onFilterApplied: (List<Skill> filteredSkills) {
            setState(() {
              skills = filteredSkills;
            });
          },
        );
      },
    );
  }

  void _addNewQuest() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AddQuestDialog(
          onQuestAdded: (DailyQuest newQuest) {
            questManager.dailyQuests.add(newQuest);
            questManager.saveQuests();
            setState(() {});
          },
        );
      },
    );
  }

  Widget _getPage(int index) {
    switch (index) {
      case 0:
        return SkillsScreen(skills: skills, onSkillTap: _onSkillTap);
      case 1:
        return DailyQuestScreen(questManager: questManager);
      case 2:
        return ProfileScreen();
      default:
        return SkillsScreen(skills: skills, onSkillTap: _onSkillTap);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Life Stats Tracker'),
        actions: [
          IconButton(icon: Icon(Icons.search), onPressed: _searchSkills),
          IconButton(icon: Icon(Icons.filter_list), onPressed: _filterSkills),
        ],
      ),
      body: _getPage(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
              icon: Icon(Icons.fitness_center), label: 'Skills'),
          BottomNavigationBarItem(
              icon: Icon(Icons.assignment), label: 'Quests'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewQuest,
        child: Icon(Icons.add),
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
    return RefreshIndicator(
      onRefresh: () async {
        // Implement refresh logic here
        // For example, you could reload skills from persistence
        await Future.delayed(Duration(seconds: 1)); // Simulating a refresh
      },
      child: GridView.builder(
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
      ),
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
              Hero(
                tag: 'skill_${skill.name}',
                child: Icon(skill.icon, size: 24, color: Colors.blue[800]),
              ),
              SizedBox(height: 4),
              ValueListenableBuilder<int>(
                valueListenable: skill.levelNotifier,
                builder: (context, level, child) {
                  return Text(
                    '$level/99',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

