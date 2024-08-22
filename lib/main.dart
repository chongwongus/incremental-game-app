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
import 'quests.dart';
import 'profile.dart';
import 'combat_screen.dart';
import 'character_creation.dart';
import 'character.dart';
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

class _HomePageState extends State<HomePage> {
  List<Skill> skills = [];
  List<Achievement> achievements = [];
  late DailyQuestManager dailyQuestManager;
  late QuestManager questManager;
  final PersistenceService _persistenceService = PersistenceService();
  int _selectedIndex = 0;
  Character? playerCharacter;

  @override
  void initState() {
    super.initState();
    _loadSkills().then((_) {
      setState(() {
        dailyQuestManager = DailyQuestManager(updateSkill: updateSkill);
        dailyQuestManager.initialize();
        questManager = QuestManager(updateSkill: updateSkill);
        questManager.initialize();
      });
    });
    achievements = createAchievements();
    _loadCharacter();
  }

  @override
  void dispose() {
    _persistenceService.saveCharacter(playerCharacter!);
    super.dispose();
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

  Future<void> _loadCharacter() async {
    playerCharacter = await _persistenceService.getCharacter();
    if (playerCharacter == null) {
      _createNewCharacter();
    } else {
      setState(() {});
    }
  }

  Future<void> _createNewCharacter() async {
    final character = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CharacterCreationScreen()),
    );
    if (character != null) {
      setState(() {
        playerCharacter = character;
      });
      await _persistenceService.saveCharacter(playerCharacter!);
    }
  }

  Widget _getPage(int index) {
    switch (index) {
      case 0:
        return SkillsScreen(
          skills: skills,
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
        return playerCharacter != null
            ? CombatScreen(character: playerCharacter!)
            : Center(child: Text('Create a character to access combat'));
      default:
        return SkillsScreen(
          skills: skills,
          onSkillTap: _onSkillTap,
          dailyQuestManager: dailyQuestManager,
          questManager: questManager,
        );
    }
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
          BottomNavigationBarItem(
              icon: Icon(Icons.sports_kabaddi), label: 'Combat'),
        ],
      ),
    );
  }
}

class SkillsScreen extends StatelessWidget {
  final List<Skill> skills;
  final Function(Skill) onSkillTap;
  final DailyQuestManager dailyQuestManager;
  final QuestManager questManager;

  SkillsScreen({
    required this.skills,
    required this.onSkillTap,
    required this.dailyQuestManager,
    required this.questManager,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        DailyQuestsWidget(
          dailyQuestManager: dailyQuestManager,
          questManager: questManager,
        ),
        SizedBox(height: 24),
        ActiveQuestsWidget(questManager: questManager),
        Text(
          'Your Skills',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
          itemCount: skills.length,
          itemBuilder: (context, index) {
            return SkillTile(
              skill: skills[index],
              onTap: () => onSkillTap(skills[index]),
            );
          },
        ),
      ],
    );
  }
}

class DailyQuestsWidget extends StatefulWidget {
  final DailyQuestManager dailyQuestManager;
  final QuestManager questManager;

  DailyQuestsWidget({
    required this.dailyQuestManager,
    required this.questManager,
  });

  @override
  _DailyQuestsWidgetState createState() => _DailyQuestsWidgetState();
}

class _DailyQuestsWidgetState extends State<DailyQuestsWidget> {
  late Timer _timer;
  String _timeUntilReset = '';

  @override
  void initState() {
    super.initState();
    _updateTimeUntilReset();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      _updateTimeUntilReset();
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _updateTimeUntilReset() {
    Duration timeLeft = widget.dailyQuestManager.timeUntilReset();
    setState(() {
      _timeUntilReset = _formatDuration(timeLeft);
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  Widget build(BuildContext context) {
    List<DailyQuest> incompleteQuests = widget.dailyQuestManager.dailyQuests
        .where((quest) => !quest.isCompleted)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Welcome',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              'Resets in: $_timeUntilReset',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        SizedBox(height: 12),
        if (incompleteQuests.isEmpty)
          Card(
            color: Colors.blue[100],
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'All daily quests completed! Great job!',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          )
        else
          ...incompleteQuests.take(3).map((quest) => DailyQuestCard(
                quest: quest,
                onComplete: () async {
                  await widget.dailyQuestManager.completeQuest(
                      widget.dailyQuestManager.dailyQuests.indexOf(quest));
                  setState(() {});
                },
              )),
      ],
    );
  }
}

class DailyQuestCard extends StatelessWidget {
  final DailyQuest quest;
  final VoidCallback onComplete;

  DailyQuestCard({required this.quest, required this.onComplete});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.green[100],
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              quest.title,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            Text(quest.description),
            SizedBox(height: 8),
            ElevatedButton(
              onPressed: onComplete,
              child: Text('Complete'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class QuestsScreen extends StatelessWidget {
  final DailyQuestManager dailyQuestManager;
  final QuestManager questManager;

  QuestsScreen({
    required this.dailyQuestManager,
    required this.questManager,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        Text(
          'Daily Quests',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 12),
        DailyQuestsWidget(
          dailyQuestManager: dailyQuestManager,
          questManager: questManager,
        ),
        SizedBox(height: 24),
        Text(
          'Active Quests',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 12),
        ActiveQuestsWidget(questManager: questManager),
        SizedBox(height: 24),
        Text(
          'Available Quests',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 12),
        AvailableQuestsWidget(questManager: questManager),
      ],
    );
  }
}

class ActiveQuestsWidget extends StatelessWidget {
  final QuestManager questManager;

  ActiveQuestsWidget({required this.questManager});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var quest in questManager.activeQuests)
          ActiveQuestCard(quest: quest),
      ],
    );
  }
}

class ActiveQuestCard extends StatelessWidget {
  final Quest quest;

  ActiveQuestCard({required this.quest});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(quest.title,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 4),
            Text(quest.description),
            SizedBox(height: 8),
            LinearProgressIndicator(value: quest.progress),
            SizedBox(height: 4),
            Text('${(quest.progress * 100).toStringAsFixed(1)}% complete'),
          ],
        ),
      ),
    );
  }
}

class AvailableQuestsWidget extends StatelessWidget {
  final QuestManager questManager;

  AvailableQuestsWidget({required this.questManager});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var quest in questManager.availableQuests)
          AvailableQuestCard(
            quest: quest,
            onStart: () => questManager.startQuest(quest.id),
          ),
      ],
    );
  }
}

class AvailableQuestCard extends StatelessWidget {
  final Quest quest;
  final VoidCallback onStart;

  AvailableQuestCard({required this.quest, required this.onStart});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(quest.title,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 4),
            Text(quest.description),
            SizedBox(height: 8),
            Text('Difficulty: ${quest.difficulty.toString().split('.').last}'),
            Text('Duration: ${quest.duration.inDays} days'),
            Text('Reward: ${quest.expReward} ${quest.relatedSkill} XP'),
            SizedBox(height: 8),
            ElevatedButton(
              onPressed: onStart,
              child: Text('Start Quest'),
            ),
          ],
        ),
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
