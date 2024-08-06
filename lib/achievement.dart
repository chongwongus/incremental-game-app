class Achievement {
  final String id;
  final String title;
  final String description;
  final Map<String, int> requirements;
  bool unlocked;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.requirements,
    this.unlocked = false,
  });
}

