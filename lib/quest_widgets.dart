import 'package:flutter/material.dart';
import 'dart:async';
import 'quests.dart';
import 'daily.dart';

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

class IntegratedQuestScreen extends StatelessWidget {
  final QuestManager questManager;
  final DailyQuestManager dailyQuestManager;

  IntegratedQuestScreen({
    required this.questManager,
    required this.dailyQuestManager,
  });

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Quests'),
          bottom: TabBar(
            tabs: [
              Tab(text: 'Daily Quests'),
              Tab(text: 'Available Quests'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            DailyQuestsTab(dailyQuestManager: dailyQuestManager),
            AvailableQuestsTab(questManager: questManager),
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
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          TabBar(
            tabs: [
              Tab(text: 'Daily'),
              Tab(text: 'Active'),
              Tab(text: 'Available'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                DailyQuestsTab(dailyQuestManager: dailyQuestManager),
                ActiveQuestsTab(questManager: questManager),
                AvailableQuestsTab(questManager: questManager),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DailyQuestsTab extends StatelessWidget {
  final DailyQuestManager dailyQuestManager;

  DailyQuestsTab({required this.dailyQuestManager});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: dailyQuestManager.dailyQuests.length,
      itemBuilder: (context, index) {
        final quest = dailyQuestManager.dailyQuests[index];
        return DailyQuestCard(
          quest: quest,
          onComplete: () async {
            await dailyQuestManager.completeQuest(index);
          },
        );
      },
    );
  }
}

class ActiveQuestsTab extends StatelessWidget {
  final QuestManager questManager;

  ActiveQuestsTab({required this.questManager});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: questManager.activeQuests.length,
      itemBuilder: (context, index) {
        final quest = questManager.activeQuests[index];
        return ActiveQuestCard(quest: quest);
      },
    );
  }
}

class AvailableQuestsTab extends StatelessWidget {
  final QuestManager questManager;

  AvailableQuestsTab({required this.questManager});

  @override
  Widget build(BuildContext context) {
    // Group quests by skill
    Map<String, Map<QuestDifficulty, List<Quest>>> groupedQuests = {};

    for (var quest in questManager.availableQuests) {
      if (!groupedQuests.containsKey(quest.relatedSkill)) {
        groupedQuests[quest.relatedSkill] = {};
      }
      if (!groupedQuests[quest.relatedSkill]!.containsKey(quest.difficulty)) {
        groupedQuests[quest.relatedSkill]![quest.difficulty] = [];
      }
      groupedQuests[quest.relatedSkill]![quest.difficulty]!.add(quest);
    }

    return ListView.builder(
      itemCount: groupedQuests.length,
      itemBuilder: (context, index) {
        String skill = groupedQuests.keys.elementAt(index);
        return SkillExpansionTile(
          skill: skill,
          questGroups: groupedQuests[skill]!,
          questManager: questManager,
        );
      },
    );
  }
}

class SkillExpansionTile extends StatelessWidget {
  final String skill;
  final Map<QuestDifficulty, List<Quest>> questGroups;
  final QuestManager questManager;

  SkillExpansionTile({
    required this.skill,
    required this.questGroups,
    required this.questManager,
  });

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text(skill),
      children: questGroups.entries.map((entry) {
        return DifficultyExpansionTile(
          difficulty: entry.key,
          quests: entry.value,
          questManager: questManager,
        );
      }).toList(),
    );
  }
}

class DifficultyExpansionTile extends StatelessWidget {
  final QuestDifficulty difficulty;
  final List<Quest> quests;
  final QuestManager questManager;

  DifficultyExpansionTile({
    required this.difficulty,
    required this.quests,
    required this.questManager,
  });

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text(difficulty.toString().split('.').last),
      children: quests
          .map((quest) => AvailableQuestCard(
                quest: quest,
                onStart: () => questManager.startQuest(quest.id),
              ))
          .toList(),
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
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () => _showQuestDetails(context),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(quest.title,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text(quest.description,
                  maxLines: 2, overflow: TextOverflow.ellipsis),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Reward: ${quest.expReward} XP'),
                  ElevatedButton(
                    onPressed: onStart,
                    child: Text('Start Quest'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showQuestDetails(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(quest.title),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(quest.description),
                SizedBox(height: 16),
                Text('Skill: ${quest.relatedSkill}'),
                Text(
                    'Difficulty: ${quest.difficulty.toString().split('.').last}'),
                Text('Duration: ${quest.duration.inDays} days'),
                Text('Reward: ${quest.expReward} XP'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: Text('Start Quest'),
              onPressed: () {
                onStart();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
