/// User settings model. Mirrors backend schema at
/// brawe-connect/backend/app/schemas/settings.py
class UserSettings {
  // Stream
  final String streamQuality;
  final String? defaultCategory;
  final int chatFontSize;
  // Notifications
  final bool notificationsLiveStart;
  final bool notificationsGifts;
  final bool notificationsFollowers;
  final bool notificationsMessages;
  // Privacy
  final bool privacyShowEarnings;
  final bool privacyShowViewers;
  final String privacyAllowDm;
  // Appearance
  final String language;
  final String theme; // 'system' | 'dark' | 'light'
  final bool soundsEnabled;

  const UserSettings({
    this.streamQuality = 'auto',
    this.defaultCategory,
    this.chatFontSize = 14,
    this.notificationsLiveStart = true,
    this.notificationsGifts = true,
    this.notificationsFollowers = true,
    this.notificationsMessages = true,
    this.privacyShowEarnings = false,
    this.privacyShowViewers = true,
    this.privacyAllowDm = 'everyone',
    this.language = 'pt',
    this.theme = 'system',
    this.soundsEnabled = true,
  });

  factory UserSettings.fromJson(Map<String, dynamic> json) {
    return UserSettings(
      streamQuality: (json['stream_quality'] as String?) ?? 'auto',
      defaultCategory: json['default_category'] as String?,
      chatFontSize: (json['chat_font_size'] as num?)?.toInt() ?? 14,
      notificationsLiveStart: json['notifications_live_start'] as bool? ?? true,
      notificationsGifts: json['notifications_gifts'] as bool? ?? true,
      notificationsFollowers: json['notifications_followers'] as bool? ?? true,
      notificationsMessages: json['notifications_messages'] as bool? ?? true,
      privacyShowEarnings: json['privacy_show_earnings'] as bool? ?? false,
      privacyShowViewers: json['privacy_show_viewers'] as bool? ?? true,
      privacyAllowDm: (json['privacy_allow_dm'] as String?) ?? 'everyone',
      language: (json['language'] as String?) ?? 'pt',
      theme: (json['theme'] as String?) ?? 'system',
      soundsEnabled: json['sounds_enabled'] as bool? ?? true,
    );
  }

  UserSettings copyWith({
    String? streamQuality,
    String? defaultCategory,
    int? chatFontSize,
    bool? notificationsLiveStart,
    bool? notificationsGifts,
    bool? notificationsFollowers,
    bool? notificationsMessages,
    bool? privacyShowEarnings,
    bool? privacyShowViewers,
    String? privacyAllowDm,
    String? language,
    String? theme,
    bool? soundsEnabled,
  }) {
    return UserSettings(
      streamQuality: streamQuality ?? this.streamQuality,
      defaultCategory: defaultCategory ?? this.defaultCategory,
      chatFontSize: chatFontSize ?? this.chatFontSize,
      notificationsLiveStart:
          notificationsLiveStart ?? this.notificationsLiveStart,
      notificationsGifts: notificationsGifts ?? this.notificationsGifts,
      notificationsFollowers:
          notificationsFollowers ?? this.notificationsFollowers,
      notificationsMessages:
          notificationsMessages ?? this.notificationsMessages,
      privacyShowEarnings: privacyShowEarnings ?? this.privacyShowEarnings,
      privacyShowViewers: privacyShowViewers ?? this.privacyShowViewers,
      privacyAllowDm: privacyAllowDm ?? this.privacyAllowDm,
      language: language ?? this.language,
      theme: theme ?? this.theme,
      soundsEnabled: soundsEnabled ?? this.soundsEnabled,
    );
  }
}
