/// Id fixo do remetente oficial "Brawe" (mesmo valor do backend).
const String kBraweSystemUserId = '00000000-0000-4000-8000-00000000b2a3';

enum SystemNoticeTone { info, success, warning, danger }

class SystemNoticeCta {
  const SystemNoticeCta({required this.label, this.route, this.url});
  final String label;

  /// Rota interna do app (começa com `/`). Exclusivo com [url].
  final String? route;

  /// Link externo (ex.: portal Partners). Só https em hosts brawe.app/brawe.io (ver [isAllowedNoticeUrl]).
  final String? url;
}

/// Só abre links https de domínios da Brawe (brawe.app / brawe.io e subdomínios), sem credenciais embutidas.
bool isAllowedNoticeUrl(String? raw) {
  final u = Uri.tryParse((raw ?? '').trim());
  if (u == null || u.scheme != 'https' || u.userInfo.isNotEmpty || u.host.isEmpty) return false;
  final h = u.host.toLowerCase();
  return const ['brawe.app', 'brawe.io'].any((d) => h == d || h.endsWith('.$d'));
}

/// Aviso oficial da Brawe no chat (`message_type == "system_notice"`).
/// Vem em `meta`: {type, event, title, body, icon, tone, cta:{label,route|url}|null,
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
      final url = c['url']?.toString().trim() ?? '';
      if (label.isNotEmpty && route.startsWith('/')) {
        cta = SystemNoticeCta(label: label, route: route);
      } else if (label.isNotEmpty && isAllowedNoticeUrl(url)) {
        cta = SystemNoticeCta(label: label, url: url);
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
