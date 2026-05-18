import 'package:shared_preferences/shared_preferences.dart';
import '../../../data/model/create_live_room_request_dto.dart';

class LastLiveConfigService {
  static const _kTitle = 'last_live.title';
  static const _kCategory = 'last_live.category';
  static const _kVisibility = 'last_live.visibility';
  static const _kNotifyFollowers = 'last_live.notify_followers';

  Future<LastLiveConfig?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final title = prefs.getString(_kTitle);
    if (title == null || title.isEmpty) return null;
    return LastLiveConfig(
      title: title,
      category: prefs.getString(_kCategory) ?? '',
      visibility: LiveVisibility.values.firstWhere(
        (v) => v.name == (prefs.getString(_kVisibility) ?? 'public'),
        orElse: () => LiveVisibility.public,
      ),
      notifyFollowers: prefs.getBool(_kNotifyFollowers) ?? true,
    );
  }

  Future<void> save({
    required String title,
    required String category,
    required LiveVisibility visibility,
    required bool notifyFollowers,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kTitle, title);
    await prefs.setString(_kCategory, category);
    await prefs.setString(_kVisibility, visibility.name);
    await prefs.setBool(_kNotifyFollowers, notifyFollowers);
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kTitle);
    await prefs.remove(_kCategory);
    await prefs.remove(_kVisibility);
    await prefs.remove(_kNotifyFollowers);
  }
}

class LastLiveConfig {
  const LastLiveConfig({
    required this.title,
    required this.category,
    required this.visibility,
    required this.notifyFollowers,
  });

  final String title;
  final String category;
  final LiveVisibility visibility;
  final bool notifyFollowers;

  String suggestedTitle() {
    final t = title.trim();
    final match = RegExp(r'^(.*?)\s*[-—]\s*Parte\s+(\d+)$', caseSensitive: false).firstMatch(t);
    if (match != null) {
      final base = match.group(1)!;
      final n = int.tryParse(match.group(2)!) ?? 1;
      return '$base — Parte ${n + 1}';
    }
    return '$t — Parte 2';
  }
}
