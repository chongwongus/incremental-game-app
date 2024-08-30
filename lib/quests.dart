import 'dart:async';
import 'package:flutter/material.dart';
import 'persistence_service.dart';

enum QuestDifficulty { easy, medium, hard, epic }

class Quest {
  final String id;
  final String title;
  final String description;
  final String relatedSkill;
  final int expReward;
  final QuestDifficulty difficulty;
  final Duration duration;
  bool isCompleted;
  DateTime? startTime;

  Quest({
    required this.id,
    required this.title,
    required this.description,
    required this.relatedSkill,
    required this.expReward,
    required this.difficulty,
    required this.duration,
    this.isCompleted = false,
    this.startTime,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'relatedSkill': relatedSkill,
        'expReward': expReward,
        'difficulty': difficulty.index,
        'duration': duration.inSeconds,
        'isCompleted': isCompleted,
        'startTime': startTime?.toIso8601String(),
      };

  factory Quest.fromJson(Map<String, dynamic> json) => Quest(
        id: json['id'],
        title: json['title'],
        description: json['description'],
        relatedSkill: json['relatedSkill'],
        expReward: json['expReward'],
        difficulty: QuestDifficulty.values[json['difficulty']],
        duration: Duration(seconds: json['duration']),
        isCompleted: json['isCompleted'],
        startTime: json['startTime'] != null
            ? DateTime.parse(json['startTime'])
            : null,
      );

  double get progress {
    if (startTime == null) return 0;
    final elapsed = DateTime.now().difference(startTime!);
    return (elapsed.inSeconds / duration.inSeconds).clamp(0.0, 1.0);
  }
}

class QuestManager {
  List<Quest> availableQuests = [];
  List<Quest> activeQuests = [];
  static const int MAX_ACTIVE_QUESTS = 1;
  final Function(String, int) updateSkill;
  final PersistenceService _persistenceService = PersistenceService();

  QuestManager({required this.updateSkill});

  Future<void> initialize() async {
    await loadQuests();
    Timer.periodic(Duration(minutes: 5), (timer) => checkQuestProgress());
  }

  void checkQuestProgress() {
    for (var quest in activeQuests) {
      if (quest.startTime != null &&
          DateTime.now().difference(quest.startTime!) >= quest.duration) {
        completeQuest(quest.id);
      }
    }
  }

  Future<void> loadQuests() async {
    // Load available quests (this could be moved to a separate JSON file or API in the future)
    availableQuests = [
      Quest(
        id: 'epic_strength_1',
        title: 'Iron Man Challenge',
        description: 'Complete a full Iron Man triathlon',
        relatedSkill: 'Strength',
        expReward: 1000,
        difficulty: QuestDifficulty.epic,
        duration: Duration(days: 30),
      ),
      Quest(
        id: 'hard_intelligence_1',
        title: 'Code Marathon',
        description: 'Build a fully functional mobile app',
        relatedSkill: 'Intelligence',
        expReward: 500,
        difficulty: QuestDifficulty.hard,
        duration: Duration(days: 14),
      ),
      Quest(
        id: 'medium_wisdom_1',
        title: 'Mindfulness Journey',
        description: 'Meditate for 30 minutes daily for 10 consecutive days',
        relatedSkill: 'Wisdom',
        expReward: 250,
        difficulty: QuestDifficulty.medium,
        duration: Duration(days: 10),
      ),
      Quest(
        id: 'easy_charisma_1',
        title: 'Social Butterfly',
        description: 'Strike up conversations with 5 strangers',
        relatedSkill: 'Charisma',
        expReward: 100,
        difficulty: QuestDifficulty.easy,
        duration: Duration(days: 3),
      ),
      Quest(
        id: 'hard_agility_1',
        title: 'Parkour Master',
        description: 'Complete a beginner parkour course',
        relatedSkill: 'Agility',
        expReward: 400,
        difficulty: QuestDifficulty.hard,
        duration: Duration(days: 7),
      ),
      Quest(
        id: 'easy_cooking_1',
        title: 'Master Chef',
        description: 'Cook a three-course meal from scratch',
        relatedSkill: 'Cooking',
        expReward: 100,
        difficulty: QuestDifficulty.easy,
        duration: Duration(days: 2),
      ),
      Quest(
        id: 'medium_cooking_1',
        title: 'Culinary Adventure',
        description:
            'Cook and perfect a signature dish from a different cuisine',
        relatedSkill: 'Cooking',
        expReward: 300,
        difficulty: QuestDifficulty.medium,
        duration: Duration(days: 5),
      ),
      Quest(
        id: 'epic_intelligence_2',
        title: 'Language Mastery',
        description: 'Achieve conversational fluency in a new language',
        relatedSkill: 'Intelligence',
        expReward: 1000,
        difficulty: QuestDifficulty.epic,
        duration: Duration(days: 90),
      ),
      Quest(
        id: 'easy_constitution_1',
        title: 'Hydration Hero',
        description: 'Drink 8 glasses of water daily for a week',
        relatedSkill: 'Constitution',
        expReward: 150,
        difficulty: QuestDifficulty.easy,
        duration: Duration(days: 7),
      ),
      Quest(
        id: 'hard_strength_2',
        title: 'Mountain Conqueror',
        description: 'Hike a challenging mountain trail (at least 10 miles)',
        relatedSkill: 'Strength',
        expReward: 450,
        difficulty: QuestDifficulty.hard,
        duration: Duration(days: 2),
      ),
      Quest(
        id: 'medium_charisma_2',
        title: 'Public Speaking Challenge',
        description:
            'Give a 10-minute presentation on a topic you are passionate about',
        relatedSkill: 'Charisma',
        expReward: 350,
        difficulty: QuestDifficulty.medium,
        duration: Duration(days: 7),
      ),
    ];

    // Load active quests from persistence
    String? activeQuestsJson =
        await _persistenceService.getString('active_quests');
    if (activeQuestsJson != null) {
      List<dynamic> activeQuestsList =
          await _persistenceService.getObjectList('active_quests');
      activeQuests = activeQuestsList
          .map((questJson) => Quest.fromJson(questJson))
          .toList();
    }
  }

  Future<void> saveActiveQuests() async {
    List<Map<String, dynamic>> activeQuestsJson =
        activeQuests.map((quest) => quest.toJson()).toList();
    await _persistenceService.saveObjectList('active_quests', activeQuestsJson);
  }

  Future<bool> startQuest(String questId) async {
    if (activeQuests.length >= MAX_ACTIVE_QUESTS) {
      return false; // Can't start a new quest
    }

    final quest = availableQuests.firstWhere((q) => q.id == questId);
    quest.startTime = DateTime.now();
    activeQuests.add(quest);
    await saveActiveQuests();
    return true;
  }

  Future<void> completeQuest(String questId) async {
    final quest = activeQuests.firstWhere((q) => q.id == questId);
    quest.isCompleted = true;
    updateSkill(quest.relatedSkill, quest.expReward);
    activeQuests.removeWhere((q) => q.id == questId);
    await saveActiveQuests();
  }
}
