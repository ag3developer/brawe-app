import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import 'in_app_link_webview_screen.dart';

/// Widget que renderiza texto de posts/comentários com:
/// - URLs (http/https/www) clicáveis → abrem em WebView in-app (com botão
///   "abrir externamente"), estilo Instagram/TikTok.
/// - @menções → navegam para o perfil do usuário mencionado.
/// - #hashtags → navegam para a tela de busca por hashtag.
///
/// Substitui os `Text(post.content)` simples usados no feed, chat e
/// comentários, sem exigir nenhuma mudança no backend (tudo é parseado
/// client-side a partir do texto puro já retornado pela API).
class BraweRichText extends StatelessWidget {
  const BraweRichText(
    this.text, {
    super.key,
    this.style,
    this.linkColor,
    this.maxLines,
    this.overflow,
    this.textAlign,
  });

  final String text;
  final TextStyle? style;
  final Color? linkColor;
  final int? maxLines;
  final TextOverflow? overflow;
  final TextAlign? textAlign;

  // URL: http(s):// ou www. seguido de qualquer caractere não-espaço.
  // @mention: @ seguido de letras/números/._- (mesmas regras de username).
  // #hashtag: # seguido de letras/números/_ (unicode-aware para acentos).
  static final RegExp _tokenRegex = RegExp(
    r'((?:https?:\/\/|www\.)[^\s]+)' // grupo 1: URL
    r'|(@[a-zA-Z0-9_.]{2,32})' // grupo 2: @mention
    r'|(#[\p{L}0-9_]{2,50})', // grupo 3: #hashtag
    unicode: true,
  );

  /// Retorna a primeira URL http(s)/www encontrada em [text], normalizada
  /// com esquema (`www.x.com` → `https://www.x.com`), ou `null` se não
  /// houver nenhuma. Usado pelo `LinkPreviewCard` pra saber qual link
  /// "unfurl" (o mesmo texto pode ter @menções/#hashtags misturados).
  static String? firstUrl(String text) {
    for (final match in _tokenRegex.allMatches(text)) {
      final urlMatch = match.group(1);
      if (urlMatch != null) {
        return urlMatch.startsWith('http') ? urlMatch : 'https://$urlMatch';
      }
    }
    return null;
  }

  /// Link de post do próprio Brawe (formato novo e legado).
  static final RegExp sharedPostRegex = RegExp(
    r'https?://(?:www\.)?brawe\.app/(?:post|connect/p)/[a-zA-Z0-9_\-\.]+',
  );

  /// Versão "bonita" de um link para exibir: só o site e um pedaço curto do
  /// caminho (`https://www.youtube.com/watch?v=abc` → `youtube.com/watch…`).
  /// O toque continua abrindo o link completo.
  static String prettyUrl(String url) {
    final normalized = url.startsWith('http') ? url : 'https://$url';
    final uri = Uri.tryParse(normalized);
    if (uri == null || uri.host.isEmpty) return url;
    final host = uri.host.replaceFirst(RegExp(r'^www\.'), '');
    final path = uri.path == '/' ? '' : uri.path;
    if (path.isEmpty && uri.query.isEmpty) return host;
    final firstSeg = path.split('/').firstWhere(
          (e) => e.isNotEmpty,
          orElse: () => '',
        );
    if (firstSeg.isEmpty) return host;
    final seg = firstSeg.length > 14 ? '${firstSeg.substring(0, 14)}…' : firstSeg;
    final more = path.split('/').where((e) => e.isNotEmpty).length > 1 ||
        uri.query.isNotEmpty;
    return '$host/$seg${more ? '…' : ''}';
  }

  /// Texto puro "humanizado" para prévias (notificações, lista de conversas):
  /// link de post vira [sharedPostLabel] e os demais links viram só o site.
  static String humanize(String text, {required String sharedPostLabel}) {
    var out = text.replaceAll(sharedPostRegex, '\u0000');
    out = out.replaceAllMapped(
      RegExp(r'(?:https?:\/\/|www\.)[^\s]+'),
      (m) => prettyUrl(m.group(0)!),
    );
    final trimmed = out.trim();
    if (trimmed == '\u0000') return sharedPostLabel;
    return out.replaceAll('\u0000', sharedPostLabel).trim();
  }

  /// `true` quando o texto é só um link (sem mais nada escrito).
  static bool isOnlyUrl(String text) {
    final t = text.trim();
    if (t.isEmpty || t.contains(RegExp(r'\s'))) return false;
    return RegExp(r'^(?:https?:\/\/|www\.)[^\s]+$').hasMatch(t);
  }

  @override
  Widget build(BuildContext context) {
    final baseStyle = style ?? DefaultTextStyle.of(context).style;
    final effectiveLinkColor =
        linkColor ?? Theme.of(context).colorScheme.primary;

    final spans = <InlineSpan>[];
    var lastEnd = 0;

    for (final match in _tokenRegex.allMatches(text)) {
      if (match.start > lastEnd) {
        spans.add(TextSpan(text: text.substring(lastEnd, match.start)));
      }

      final urlMatch = match.group(1);
      final mentionMatch = match.group(2);
      final hashtagMatch = match.group(3);

      if (urlMatch != null) {
        final normalizedUrl = urlMatch.startsWith('http')
            ? urlMatch
            : 'https://$urlMatch';
        spans.add(
          TextSpan(
            // Mostra só o site (e um pedaço do caminho), não a URL inteira.
            text: prettyUrl(urlMatch),
            style: baseStyle.copyWith(
              color: effectiveLinkColor,
              decoration: TextDecoration.underline,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () => _openLink(context, normalizedUrl),
          ),
        );
      } else if (mentionMatch != null) {
        final username = mentionMatch.substring(1);
        spans.add(
          TextSpan(
            text: mentionMatch,
            style: baseStyle.copyWith(
              color: effectiveLinkColor,
              fontWeight: FontWeight.w600,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () => context.push('/profile/$username'),
          ),
        );
      } else if (hashtagMatch != null) {
        final tag = hashtagMatch.substring(1);
        spans.add(
          TextSpan(
            text: hashtagMatch,
            style: baseStyle.copyWith(
              color: effectiveLinkColor,
              fontWeight: FontWeight.w600,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () =>
                  context.push('/explore/hashtag/${Uri.encodeComponent(tag)}'),
          ),
        );
      }

      lastEnd = match.end;
    }

    if (lastEnd < text.length) {
      spans.add(TextSpan(text: text.substring(lastEnd)));
    }

    return Text.rich(
      TextSpan(style: baseStyle, children: spans),
      maxLines: maxLines,
      overflow: overflow ?? TextOverflow.clip,
      textAlign: textAlign,
    );
  }

  Future<void> _openLink(BuildContext context, String url) async {
    // Links de WhatsApp/Telegram/etc já têm handler nativo no SO — deixamos
    // o SO decidir (abre o app instalado direto) via `launchUrl` externo.
    // Para links "de página" comuns (http/https genéricos), preferimos o
    // WebView in-app para não tirar o usuário do Brawe sem necessidade —
    // exatamente como Instagram/TikTok fazem.
    final uri = Uri.tryParse(url);
    if (uri == null) return;

    final isDeepLinkHost = _deepLinkHosts.any((h) => uri.host.contains(h));
    if (isDeepLinkHost) {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (launched) return;
    }

    if (!context.mounted) return;
    await InAppLinkWebViewScreen.open(context, url);
  }

  // Domínios que representam deep links de outros apps (grupo de WhatsApp,
  // Telegram, etc.) — melhor abrir direto no app nativo do que num WebView.
  static const _deepLinkHosts = [
    'chat.whatsapp.com',
    'wa.me',
    't.me',
    'telegram.me',
    'instagram.com',
    'twitter.com',
    'x.com',
    'youtube.com',
    'youtu.be',
    'tiktok.com',
  ];
}
