// prestige_system.dart
class PrestigeLevel {
  final int level;
  final String title;
  final double xpMultiplier;

  PrestigeLevel({
    required this.level,
    required this.title,
    required this.xpMultiplier,
  });
}

class PrestigeSystem {
  final List<PrestigeLevel> levels = [
    PrestigeLevel(level: 0, title: 'Novice', xpMultiplier: 1.0),
    PrestigeLevel(level: 1, title: 'Adept', xpMultiplier: 1.1),
    PrestigeLevel(level: 2, title: 'Expert', xpMultiplier: 1.2),
    PrestigeLevel(level: 3, title: 'Master', xpMultiplier: 1.3),
    PrestigeLevel(level: 4, title: 'Grandmaster', xpMultiplier: 1.5),
  ];

  PrestigeLevel getPrestigeLevel(int level) {
    return levels.firstWhere(
      (prestige) => prestige.level == level,
      orElse: () => levels.last,
    );
  }
}

