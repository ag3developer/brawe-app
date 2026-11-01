import 'live_event.dart';

/// Prêmio ativo de um usuário (badge, moldura, expiração). Aparece em
/// `award` (chat/entrada/presente) e em `active_awards` (perfil).
class UserAward {
  const UserAward({
    required this.label,
    this.id,
    this.badgeImageUrl,
    this.badgeColor,
    this.frameUrl,
    this.sourceKind,
    this.expiresAt,
  });

  final String? id;
  final LocalizedText label;
  final String? badgeImageUrl;
  final String? badgeColor;
  final String? frameUrl;

  /// `event` | `creator_week` | `live` | `battle` (só quando o servidor manda).
  final String? sourceKind;
  final DateTime? expiresAt;

  String localizedLabel(String lang) => label.resolve(lang);

  bool isExpired(DateTime now) => expiresAt != null && !expiresAt!.isAfter(now);

  /// Prioridade de prestígio: evento > semana do criador > live > batalha.
  static int priorityOf(String? kind) => switch (kind) {
    'event' => 4,
    'creator_week' => 3,
    'live' => 2,
    'battle' => 1,
    _ => 0,
  };

  static UserAward? tryParse(dynamic raw) {
    if (raw is! Map) return null;
    final label = LocalizedText.tryParse(raw['label']);
    if (label == null) return null;
    String? s(dynamic v) {
      final t = v?.toString().trim();
      return (t == null || t.isEmpty || t == 'null') ? null : t;
    }

    return UserAward(
      id: s(raw['id']),
      label: label,
      badgeImageUrl: s(raw['badge_image_url']),
      badgeColor: s(raw['badge_color']),
      frameUrl: s(raw['frame_url']),
      sourceKind: s(raw['source_kind']),
      expiresAt: DateTime.tryParse(raw['expires_at']?.toString() ?? '')?.toLocal(),
    );
  }

  static List<UserAward> listFrom(dynamic raw) {
    if (raw is! List) return const [];
    return raw.map(UserAward.tryParse).whereType<UserAward>().toList();
  }

  /// O prêmio mais prestigioso da lista (prioridade, depois validade mais
  /// distante como proxy de "mais novo"). Ignora expirados.
  static UserAward? mostPrestigious(List<UserAward> awards, {DateTime? now}) {
    final t = now ?? DateTime.now();
    UserAward? best;
    for (final a in awards) {
      if (a.isExpired(t)) continue;
      if (best == null) {
        best = a;
        continue;
      }
      final pa = priorityOf(a.sourceKind);
      final pb = priorityOf(best.sourceKind);
      if (pa > pb ||
          (pa == pb &&
              (a.expiresAt ?? DateTime(0)).isAfter(best.expiresAt ?? DateTime(0)))) {
        best = a;
      }
    }
    return best;
  }
}

/// Conversor do JSON de `active_awards` (tolerante a `null`/lixo).
List<UserAward> userAwardsFromJson(Object? raw) => UserAward.listFrom(raw);
