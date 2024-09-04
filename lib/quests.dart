import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'persistence_service.dart';
import 'talent_system.dart';

enum QuestDifficulty { easy, medium, hard, epic }

class Quest {
  final String id;
  final String title;
  final String description;
  final String relatedSkill;
  final int expReward;
  final QuestDifficulty difficulty;
  final Duration duration;
  final bool isEpic;
  final int talentPointsReward;
  final List<String> skillUnlocks;
  bool isCompleted;
  DateTime? startTime;
  DateTime? lastCheckIn;
  int checkInsRequired;
  int checkInsCompleted;

  Quest({
    required this.id,
    required this.title,
    required this.description,
    required this.relatedSkill,
    required this.expReward,
    required this.difficulty,
    required this.duration,
    this.isEpic = false,
    this.talentPointsReward = 0,
    this.skillUnlocks = const [],
    this.isCompleted = false,
    this.startTime,
    this.lastCheckIn,
    this.checkInsRequired = 1,
    this.checkInsCompleted = 0,
  });
  bool get isEpicQuest => isEpic;

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
        'lastCheckIn': lastCheckIn?.toIso8601String(),
        'checkInsRequired': checkInsRequired,
        'checkInsCompleted': checkInsCompleted,
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
        lastCheckIn: json['lastCheckIn'] != null
            ? DateTime.parse(json['lastCheckIn'])
            : null,
        checkInsRequired: json['checkInsRequired'],
        checkInsCompleted: json['checkInsCompleted'],
      );
  double get progress {
    if (startTime == null) return 0;
    final elapsed = DateTime.now().difference(startTime!);
    return (elapsed.inSeconds / duration.inSeconds).clamp(0.0, 1.0);
  }

  bool canCheckIn() {
    if (lastCheckIn == null) return true;
    return DateTime.now().difference(lastCheckIn!) >= Duration(days: 1);
  }

  void checkIn() {
    if (canCheckIn()) {
      lastCheckIn = DateTime.now();
      checkInsCompleted++;
    }
  }

  bool isReadyForCompletion() {
    return progress >= 1.0 && checkInsCompleted >= checkInsRequired;
  }
}

class QuestProgressChecker extends StatefulWidget {
  final QuestManager questManager;

  QuestProgressChecker({required this.questManager});

  @override
  _QuestProgressCheckerState createState() => _QuestProgressCheckerState();
}

class _QuestProgressCheckerState extends State<QuestProgressChecker> {
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(Duration(minutes: 5), (timer) {
      widget.questManager.checkQuestProgress();
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.shrink(); // This widget doesn't render anything visible
  }
}

class QuestManager {
  List<Quest> availableQuests = [];
  List<Quest> activeQuests = [];
  List<Quest> completedQuests = [];
  static const int MAX_ACTIVE_QUESTS = 3;
  final Function(String, int) updateSkill;
  final Function(int) addTalentPoints;
  final Function(List<String>) unlockSkills;
  final PersistenceService _persistenceService = PersistenceService();

  QuestManager({
    required this.updateSkill,
    required this.addTalentPoints,
    required this.unlockSkills,
  });

  Future<void> initialize() async {
    await loadQuests();
    Timer.periodic(Duration(hours: 1), (timer) => checkQuestProgress());
  }

  void checkQuestProgress() {
    for (var quest in activeQuests) {
      if (quest.isReadyForCompletion()) {
        completeQuest(quest.id);
      }
    }
    checkForEpicQuestUnlocks();
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
      Quest(
        id: 'code_mobile_app',
        title: 'Code a Mobile App',
        description: 'Work on coding a mobile app for a week',
        relatedSkill: 'Intelligence',
        expReward: 500,
        difficulty: QuestDifficulty.medium,
        duration: Duration(days: 7),
        checkInsRequired: 3,
      ),
      Quest(
        id: 'release_app_update',
        title: 'Release App Update',
        description: 'Release a new update for your mobile app',
        relatedSkill: 'Intelligence',
        expReward: 1000,
        difficulty: QuestDifficulty.epic,
        duration: Duration(days: 30),
        checkInsRequired: 5,
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

    if (quest.isEpicQuest) {
      addTalentPoints(quest.talentPointsReward);
      unlockSkills(quest.skillUnlocks);
    }

    activeQuests.removeWhere((q) => q.id == questId);
    completedQuests.add(quest);
    await saveQuests();
  }

  Future<void> saveQuests() async {
    await _persistenceService.saveObjectList(
        'available_quests', availableQuests.map((q) => q.toJson()).toList());
    await _persistenceService.saveObjectList(
        'active_quests', activeQuests.map((q) => q.toJson()).toList());
    await _persistenceService.saveObjectList(
        'completed_quests', completedQuests.map((q) => q.toJson()).toList());
  }

  Future<void> checkInQuest(String questId) async {
    final quest = activeQuests.firstWhere((q) => q.id == questId);
    if (quest.canCheckIn()) {
      quest.checkIn();
      await saveActiveQuests();
    }
  }

  void checkForEpicQuestUnlocks() {
    // Example: Unlock "Release App Update" epic quest after completing "Code a Mobile App"
    if (completedQuests.any((q) => q.id == 'code_mobile_app') &&
        !availableQuests.any((q) => q.id == 'release_app_update') &&
        !activeQuests.any((q) => q.id == 'release_app_update') &&
        !completedQuests.any((q) => q.id == 'release_app_update')) {
      availableQuests.add(Quest(
        id: 'release_app_update',
        title: 'Release App Update',
        description: 'Release a new update for your mobile app',
        relatedSkill: 'Intelligence',
        expReward: 1000,
        difficulty: QuestDifficulty.epic,
        duration: Duration(days: 30),
        checkInsRequired: 5,
        isEpic: true,
        talentPointsReward: 2,
        skillUnlocks: ['App Development'],
      ));
    }
  }

  void initializeEpicQuests() {
  availableQuests.addAll([
    Quest(
      id: 'learn_new_language',
      title: 'Polyglot Challenge',
      description: 'Learn the basics of a new language',
      relatedSkill: 'Intelligence',
      expReward: 2000,
      difficulty: QuestDifficulty.epic,
      duration: Duration(days: 90),
      checkInsRequired: 30,
      isEpic: true,
      talentPointsReward: 3,
      skillUnlocks: ['Linguistics'],
    ),
    Quest(
      id: 'run_marathon',
      title: 'Marathon Master',
      description: 'Train for and complete a full marathon',
      relatedSkill: 'Constitution',
      expReward: 2500,
      difficulty: QuestDifficulty.epic,
      duration: Duration(days: 120),
      checkInsRequired: 40,
      isEpic: true,
      talentPointsReward: 4,
      skillUnlocks: ['Endurance Running'],
    ),
    Quest(
      id: 'start_business',
      title: 'Entrepreneurial Spirit',
      description: 'Develop a business plan and launch a small business',
      relatedSkill: 'Charisma',
      expReward: 3000,
      difficulty: QuestDifficulty.epic,
      duration: Duration(days: 180),
      checkInsRequired: 60,
      isEpic: true,
      talentPointsReward: 5,
      skillUnlocks: ['Business Management', 'Leadership'],
    ),
  ]);
}

}
