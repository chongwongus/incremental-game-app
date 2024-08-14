import 'dart:convert';
import 'package:flutter/material.dart';
import 'persistence_service.dart';

class DailyQuest {
  final String title;
  final String description;
  final String relatedSkill;
  final int expReward;
  int completionCount;

  DailyQuest({
    required this.title,
    required this.description,
    required this.relatedSkill,
    required this.expReward,
    this.completionCount = 0,
  });

  Map<String, dynamic> toJson() => {
        'title': title,
        'description': description,
        'relatedSkill': relatedSkill,
        'expReward': expReward,
        'completionCount': completionCount,
      };

  factory DailyQuest.fromJson(Map<String, dynamic> json) => DailyQuest(
        title: json['title'],
        description: json['description'],
        relatedSkill: json['relatedSkill'],
        expReward: json['expReward'],
        completionCount: json['completionCount'] ?? 0,
      );
}

class DailyQuestManager {
  List<DailyQuest> dailyQuests = [
    DailyQuest(
      title: "Read for 30 minutes",
      description: "Improve your knowledge by reading for half an hour",
      relatedSkill: "Intelligence",
      expReward: 50,
    ),
    DailyQuest(
      title: "Exercise for 20 minutes",
      description: "Boost your fitness with a quick workout",
      relatedSkill: "Strength",
      expReward: 40,
    ),
    DailyQuest(
      title: "Meditate for 10 minutes",
      description: "Enhance your mental clarity through meditation",
      relatedSkill: "Wisdom",
      expReward: 30,
    ),
    // Add more quests as needed
  ];

  final Function(String, int) updateSkill;
  final PersistenceService _persistenceService = PersistenceService();

  DailyQuestManager({required this.updateSkill});

  Future<void> checkAndResetQuests() async {
    DateTime now = DateTime.now();
    String? lastResetDate = await _persistenceService.getLastResetDate();

    if (lastResetDate == null || DateTime.parse(lastResetDate).day != now.day) {
      for (var quest in dailyQuests) {
        quest.completionCount = 0;
      }
      await saveQuests();
      await _persistenceService.saveLastResetDate(now.toIso8601String());
    }
  }

  Future<void> loadQuests() async {
    dailyQuests = await _persistenceService.getDailyQuests();
    if (dailyQuests.isEmpty) {
      // If no saved quests are found, use the default ones.
      dailyQuests = [
        DailyQuest(
          title: "Read for 30 minutes",
          description: "Improve your knowledge by reading for half an hour",
          relatedSkill: "Intelligence",
          expReward: 50,
        ),
        DailyQuest(
          title: "Exercise for 20 minutes",
          description: "Boost your fitness with a quick workout",
          relatedSkill: "Strength",
          expReward: 40,
        ),
        DailyQuest(
          title: "Meditate for 10 minutes",
          description: "Enhance your mental clarity through meditation",
          relatedSkill: "Wisdom",
          expReward: 30,
        ),
        // Add more quests as needed
      ];
      await saveQuests();
    }
  }

  Future<void> saveQuests() async {
    await _persistenceService.saveDailyQuests(dailyQuests);
  }

  Future<void> completeQuest(int index) async {
    dailyQuests[index].completionCount++;
    updateSkill(dailyQuests[index].relatedSkill, dailyQuests[index].expReward);
    await saveQuests();
  }
}

class DailyQuestScreen extends StatefulWidget {
  final DailyQuestManager questManager;

  DailyQuestScreen({required this.questManager});

  @override
  _DailyQuestScreenState createState() => _DailyQuestScreenState();
}

class _DailyQuestScreenState extends State<DailyQuestScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Daily Quests')),
      body: ListView.builder(
        itemCount: widget.questManager.dailyQuests.length,
        itemBuilder: (context, index) {
          var quest = widget.questManager.dailyQuests[index];
          return ListTile(
            title: Text(quest.title),
            subtitle: Text(quest.description),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("${quest.completionCount}x"),
                SizedBox(width: 10),
                ElevatedButton(
                  child: Text("Complete"),
                  onPressed: () async {
                    await widget.questManager.completeQuest(index);
                    setState(() {});
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
