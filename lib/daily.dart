import 'dart:async';
import 'dart:math';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'persistence_service.dart';
import 'talent_system.dart';

class DailyQuest {
  final String title;
  final String description;
  final String relatedSkill;
  final int expReward;
  bool isCompleted;

  DailyQuest({
    required this.title,
    required this.description,
    required this.relatedSkill,
    required this.expReward,
    this.isCompleted = false,
  });

  Map<String, dynamic> toJson() => {
        'title': title,
        'description': description,
        'relatedSkill': relatedSkill,
        'expReward': expReward,
        'isCompleted': isCompleted,
      };

  factory DailyQuest.fromJson(Map<String, dynamic> json) => DailyQuest(
        title: json['title'],
        description: json['description'],
        relatedSkill: json['relatedSkill'],
        expReward: json['expReward'],
        isCompleted: json['isCompleted'] ?? false,
      );
}

class DailyQuestManager {
  List<DailyQuest> dailyQuests = [];
  final Function(String, int) updateSkill;
  final PersistenceService _persistenceService = PersistenceService();
  DateTime? lastResetTime;
  final Random _random = Random();
  bool areAllQuestsCompleted = false;

  DailyQuestManager({required this.updateSkill});

  final List<DailyQuest> _questPool = [
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
    DailyQuest(
      title: "Learn a new word",
      description: "Expand your vocabulary",
      relatedSkill: "Intelligence",
      expReward: 20,
    ),
    DailyQuest(
      title: "Practice a foreign language",
      description: "Spend 15 minutes learning or practicing a new language",
      relatedSkill: "Intelligence",
      expReward: 35,
    ),
    DailyQuest(
      title: "Do 50 push-ups",
      description: "Challenge yourself with a set of push-ups",
      relatedSkill: "Strength",
      expReward: 45,
    ),
    DailyQuest(
      title: "Write in a journal",
      description: "Reflect on your day and write your thoughts",
      relatedSkill: "Wisdom",
      expReward: 25,
    ),
    DailyQuest(
      title: "Cook a healthy meal",
      description: "Prepare a nutritious meal from scratch",
      relatedSkill: "Cooking",
      expReward: 40,
    ),
    DailyQuest(
      title: "Practice an instrument",
      description: "Spend 20 minutes practicing a musical instrument",
      relatedSkill: "Agility",
      expReward: 35,
    ),
    DailyQuest(
      title: "Solve a puzzle",
      description: "Complete a crossword, sudoku, or jigsaw puzzle",
      relatedSkill: "Intelligence",
      expReward: 30,
    ),
    DailyQuest(
      title: "Do a random act of kindness",
      description: "Perform an unexpected kind gesture for someone",
      relatedSkill: "Charisma",
      expReward: 35,
    ),
    DailyQuest(
      title: "Take a nature walk",
      description: "Spend 30 minutes walking in nature",
      relatedSkill: "Constitution",
      expReward: 40,
    ),
    DailyQuest(
      title: "Practice public speaking",
      description: "Spend 10 minutes rehearsing a speech or presentation",
      relatedSkill: "Charisma",
      expReward: 30,
    ),
    DailyQuest(
      title: "Organize your space",
      description: "Declutter and organize a room or personal space",
      relatedSkill: "Wisdom",
      expReward: 35,
    ),
    DailyQuest(
      title: "Learn a new recipe",
      description: "Research and attempt to cook a new dish",
      relatedSkill: "Cooking",
      expReward: 45,
    ),
  ];

  Future<void> initialize() async {
    await loadQuests();
    await checkAndResetQuests();
    Timer.periodic(Duration(minutes: 1), (timer) => checkAndResetQuests());
  }

  Future<void> checkAndResetQuests() async {
    DateTime now = DateTime.now();
    String? lastResetDateString = await _persistenceService.getLastResetDate();
    
    if (lastResetDateString != null) {
      lastResetTime = DateTime.parse(lastResetDateString);
    }

    if (lastResetTime == null || now.difference(lastResetTime!).inHours >= 24) {
      await resetQuests();
      lastResetTime = now;
      await _persistenceService.saveLastResetDate(now.toIso8601String());
      areAllQuestsCompleted = false;
    }
  }

  Future<void> resetQuests() async {
    List<DailyQuest> shuffledQuests = List.from(_questPool)..shuffle(_random);
    dailyQuests = shuffledQuests.take(3).map((quest) => DailyQuest(
      title: quest.title,
      description: quest.description,
      relatedSkill: quest.relatedSkill,
      expReward: quest.expReward,
      isCompleted: false,
    )).toList();
    await saveQuests();
  }

  Future<void> loadQuests() async {
    dailyQuests = await _persistenceService.getDailyQuests();
    if (dailyQuests.isEmpty) {
      await resetQuests();
    } else {
      areAllQuestsCompleted = dailyQuests.every((quest) => quest.isCompleted);
    }
  }

  Future<void> saveQuests() async {
    await _persistenceService.saveDailyQuests(dailyQuests);
  }


  Future<void> completeQuest(BuildContext context, int index) async {
    if (!areAllQuestsCompleted && !dailyQuests[index].isCompleted) {
      dailyQuests[index].isCompleted = true;
      updateSkill(dailyQuests[index].relatedSkill, dailyQuests[index].expReward);
      await saveQuests();
      
      // Check if all quests are completed
      if (dailyQuests.every((quest) => quest.isCompleted)) {
        areAllQuestsCompleted = true;
        lastResetTime = DateTime.now();
        await _persistenceService.saveLastResetDate(lastResetTime!.toIso8601String());
        
        // Award a talent point for completing all daily quests
        Provider.of<PlayerTalents>(context, listen: false).addPoints(1);
      }
    }
  }

  Duration timeUntilReset() {
    if (lastResetTime == null) return Duration.zero;
    DateTime nextReset = lastResetTime!.add(Duration(hours: 24));
    return nextReset.difference(DateTime.now());
  }

  bool get canCompleteQuests => !areAllQuestsCompleted;
}
