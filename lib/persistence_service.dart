import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'skill.dart';
import 'achievement.dart';
import 'daily.dart';

class PersistenceService {
  static const String SKILLS_KEY = 'skills';

  Future<List<Skill>> getSkills() async {
    final prefs = await SharedPreferences.getInstance();
    final skillsJson = prefs.getString(SKILLS_KEY);
    if (skillsJson != null) {
      final skillsList = jsonDecode(skillsJson) as List;
      return skillsList.map((skillJson) => Skill.fromJson(skillJson)).toList();
    }
    return []; // Return an empty list if no skills are found
  }

  Future<void> saveSkills(List<Skill> skills) async {
    final prefs = await SharedPreferences.getInstance();
    String skillsJson =
        jsonEncode(skills.map((skill) => skill.toJson()).toList());
    await prefs.setString('skills', skillsJson);
  }

  Future<List<Skill>> loadSkills() async {
    final prefs = await SharedPreferences.getInstance();
    String? skillsJson = prefs.getString('skills');
    if (skillsJson != null) {
      List<dynamic> skillsList = jsonDecode(skillsJson);
      return skillsList.map((skillJson) => Skill.fromJson(skillJson)).toList();
    }
    return [];
  }

  Future<void> saveLastResetDate(String date) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('lastResetDate', date);
  }

  Future<String?> getLastResetDate() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('lastResetDate');
  }

  Future<void> saveDailyQuests(List<DailyQuest> dailyQuests) async {
    final prefs = await SharedPreferences.getInstance();
    String questsJson =
        jsonEncode(dailyQuests.map((quest) => quest.toJson()).toList());
    await prefs.setString('dailyQuests', questsJson);
  }

  Future<List<DailyQuest>> getDailyQuests() async {
    final prefs = await SharedPreferences.getInstance();
    String? questsJson = prefs.getString('dailyQuests');
    if (questsJson != null) {
      List<dynamic> questsList = jsonDecode(questsJson);
      return questsList
          .map((questJson) => DailyQuest.fromJson(questJson))
          .toList();
    }
    return [];
  }

  Future<void> saveSkill(Skill skill) async {
    final skills = await getSkills();
    final index = skills.indexWhere((s) => s.name == skill.name);
    if (index != -1) {
      skills[index] = skill;
    } else {
      skills.add(skill);
    }
    await saveSkills(skills);
  }

  Future<Skill?> getSkill(String skillName) async {
    final skills = await getSkills();
    try {
      return skills.firstWhere((s) => s.name == skillName);
    } catch (e) {
      return null; // Return null if no matching skill is found
    }
  }
}
