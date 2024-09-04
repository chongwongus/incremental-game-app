import 'dart:convert';
import 'dart:core';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'skill.dart';
import 'persistence_service.dart';
import 'skill_detail_page.dart';
import 'achievement.dart';
import 'daily.dart';
import 'quests.dart';
import 'profile.dart';
import 'combat_screen.dart';
import 'character_creation.dart';
import 'character.dart';
import 'quest_widgets.dart';
import 'idle_manager.dart';
import 'idle_screen.dart';
import 'resource.dart';
import 'talent_system.dart';
import 'talent_tree.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final persistenceService = PersistenceService();
  final character = await persistenceService.getCharacter();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<Character>.value(
          value: character ??
              Character(name: '', baseClass: BaseClass.melee, skills: {}),
        ),
        ChangeNotifierProvider(create: (_) => ResourceManager()),
        ChangeNotifierProxyProvider2<Character, ResourceManager, IdleManager>(
          create: (context) => IdleManager(
            context.read<Character>(),
            context.read<ResourceManager>(),
          ),
          update: (context, character, resourceManager, previous) =>
              previous ?? IdleManager(character, resourceManager),
        ),
        ChangeNotifierProvider(create: (_) => PlayerTalents()), // Add this line
        Provider.value(value: persistenceService),
      ],
      child: MyApp(initialCharacter: character),
    ),
  );
}


class MyApp extends StatelessWidget {
  final Character? initialCharacter;

  const MyApp({Key? key, this.initialCharacter}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Life Stats Tracker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.light,
        fontFamily: 'Roboto',
        cardTheme: CardTheme(
          elevation: 4,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      darkTheme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.dark,
        fontFamily: 'Roboto',
        cardTheme: CardTheme(
          elevation: 4,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      home: initialCharacter == null ? CharacterCreationScreen() : HomePage(),
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

class _HomePageState extends State<HomePage> {
  List<Achievement> achievements = [];
  late DailyQuestManager dailyQuestManager;
  late QuestManager questManager;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    final character = context.read<Character>();
    dailyQuestManager = DailyQuestManager(updateSkill: character.improveSkill);
    dailyQuestManager.initialize();
    questManager = QuestManager(updateSkill: character.improveSkill);
    questManager.initialize();
    achievements = createAchievements();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _getPage(int index) {
    switch (index) {
      case 0:
        return SkillsScreen(
          onSkillTap: _onSkillTap,
          dailyQuestManager: dailyQuestManager,
          questManager: questManager,
        );
      case 1:
        return QuestsScreen(
          dailyQuestManager: dailyQuestManager,
          questManager: questManager,
        );
      case 2:
        return ProfileScreen();
      case 3:
        return IdleScreen();
      default:
        return SkillsScreen(
          onSkillTap: _onSkillTap,
          dailyQuestManager: dailyQuestManager,
          questManager: questManager,
        );
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Life Stats Tracker',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: Icon(Icons.search),
                    onPressed: () {/* Implement search functionality */},
                  ),
                ],
              ),
            ),
            Expanded(
              child: _getPage(_selectedIndex),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Theme.of(context).cardColor,
        items: [
          BottomNavigationBarItem(
              icon: Icon(Icons.fitness_center), label: 'Skills'),
          BottomNavigationBarItem(
              icon: Icon(Icons.assignment), label: 'Quests'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          BottomNavigationBarItem(icon: Icon(Icons.update), label: 'Idle'),
        ],
      ),
    );
  }
}

class SkillsScreen extends StatelessWidget {
  final Function(Skill) onSkillTap;
  final DailyQuestManager dailyQuestManager;
  final QuestManager questManager;

  SkillsScreen({
    required this.onSkillTap,
    required this.dailyQuestManager,
    required this.questManager,
  });

  @override
  Widget build(BuildContext context) {
    final character = context.watch<Character>();
    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        DailyQuestsWidget(
          dailyQuestManager: dailyQuestManager,
          questManager: questManager,
        ),
        SizedBox(height: 24),
        ActiveQuestsWidget(questManager: questManager),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Your Skills',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TalentTreeScreen()),
                );
              },
              child: Text('Talent Tree'),
            ),
          ],
        ),
        SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 0.85,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: character.skills.length,
          itemBuilder: (context, index) {
            final skill = character.skills.values.elementAt(index);
            return SkillTile(
              skill: skill,
              onTap: () => onSkillTap(skill),
            );
          },
        ),
      ],
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
        child: Padding(
          padding: EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Hero(
                tag: 'skill_${skill.name}',
                child: Icon(skill.icon,
                    size: 32, color: Theme.of(context).primaryColor),
              ),
              SizedBox(height: 4),
              Text(
                skill.name,
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 2),
              ValueListenableBuilder<int>(
                valueListenable: skill.levelNotifier,
                builder: (context, level, child) {
                  return Text(
                    'Level $level',
                    style: TextStyle(fontSize: 11),
                  );
                },
              ),
              SizedBox(height: 2),
              ValueListenableBuilder<int>(
                valueListenable: skill.xpNotifier,
                builder: (context, xp, child) {
                  double progress = xp / skill.xpForNextLevel;
                  return LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).primaryColor),
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
