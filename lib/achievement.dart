class Achievement {
  final String id;
  final String title;
  final String description;
  final String skillName;
  final int requiredLevel;
  bool unlocked;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.skillName,
    required this.requiredLevel,
    this.unlocked = false,
  });
}

// Create a list of achievements
List<Achievement> createAchievements() {
  return [
    Achievement(
      id: 'strength_1',
      title: 'Novice Strongman',
      description: 'Reach level 5 in Strength',
      skillName: 'Strength',
      requiredLevel: 5,
    ),
    Achievement(
      id: 'woodcutting_1',
      title: 'Apprentice Lumberjack',
      description: 'Reach level 10 in Woodcutting',
      skillName: 'Woodcutting',
      requiredLevel: 10,
    ),
    Achievement(
      id: 'woodcutting_2',
      title: 'Seasoned Chopper',
      description: 'Reach level 50 in Woodcutting',
      skillName: 'Woodcutting',
      requiredLevel: 50,
    ),
    Achievement(
      id: 'fishing_1',
      title: 'Novice Angler',
      description: 'Reach level 15 in Fishing',
      skillName: 'Fishing',
      requiredLevel: 15,
    ),
    Achievement(
      id: 'fishing_2',
      title: 'Master Fisherman',
      description: 'Reach level 70 in Fishing',
      skillName: 'Fishing',
      requiredLevel: 70,
    ),
    // Add more achievements for other skills
  ];
}
