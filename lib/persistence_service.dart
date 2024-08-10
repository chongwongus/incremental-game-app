import 'package:shared_preferences/shared_preferences.dart';

class PersistenceService {
  static const String _prefixSkillLevel = 'skill_level_';
  static const String _prefixSkillExp = 'skill_exp_';

  Future<void> saveSkillData(String skillName, int level, int exp) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('$_prefixSkillLevel$skillName', level);
    await prefs.setInt('$_prefixSkillExp$skillName', exp);
  }

  Future<Map<String, int>> getSkillData(String skillName) async {
    final prefs = await SharedPreferences.getInstance();
    final level = prefs.getInt('$_prefixSkillLevel$skillName') ?? 1;
    final exp = prefs.getInt('$_prefixSkillExp$skillName') ?? 0;
    return {'level': level, 'exp': exp};
  }
}

