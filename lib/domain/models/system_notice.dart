/// Id fixo do remetente oficial "Brawe" (mesmo valor do backend).
const String kBraweSystemUserId = '00000000-0000-4000-8000-00000000b2a3';

enum SystemNoticeTone { info, success, warning, danger }

class SystemNoticeCta {
  const SystemNoticeCta({required this.label, required this.route});
  final String label;
  final String route;
}

/// Aviso oficial da Brawe no chat (`message_type == "system_notice"`).
/// Vem em `meta`: {type, event, title, body, icon, tone, cta:{label,route}|null,
/// ref:{kind,id}|null}. `content` é só o texto simples dos apps antigos.
class SystemNotice {
  const SystemNotice({
    required this.event,
    required this.title,
    required this.body,
    required this.icon,
    required this.tone,
    this.cta,
    this.refKind,
    this.refId,
  });

  final String event;
  final String title;
  final String body;
  final String icon;
  final SystemNoticeTone tone;
  final SystemNoticeCta? cta;
  final String? refKind;
  final String? refId;

  static SystemNoticeTone parseTone(Object? v) {
    switch (v?.toString()) {
      case 'success':
        return SystemNoticeTone.success;
      case 'warning':
        return SystemNoticeTone.warning;
      case 'danger':
        return SystemNoticeTone.danger;
      default:
        return SystemNoticeTone.info;
    }
  }

  /// Tolerante: campos ausentes viram vazio/null; devolve null se não houver nada para mostrar.
  static SystemNotice? fromJson(Map<String, dynamic>? j) {
    if (j == null) return null;
    final title = j['title']?.toString().trim() ?? '';
    final body = j['body']?.toString().trim() ?? '';
    if (title.isEmpty && body.isEmpty) return null;
    SystemNoticeCta? cta;
    final c = j['cta'];
    if (c is Map) {
      final label = c['label']?.toString().trim() ?? '';
      final route = c['route']?.toString().trim() ?? '';
      if (label.isNotEmpty && route.startsWith('/')) {
        cta = SystemNoticeCta(label: label, route: route);
      }
    }
    final r = j['ref'];
    return SystemNotice(
      event: j['event']?.toString() ?? '',
      title: title,
      body: body,
      icon: j['icon']?.toString() ?? '',
      tone: parseTone(j['tone']),
      cta: cta,
      refKind: r is Map ? r['kind']?.toString() : null,
      refId: r is Map ? r['id']?.toString() : null,
    );
  }
}
