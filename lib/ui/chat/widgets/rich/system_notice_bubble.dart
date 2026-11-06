import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../domain/models/conversation.dart';
import '../../../../domain/models/system_notice.dart';
import '../../../../gen/l10n/app_localizations.dart';
import '../../../core/themes/brawe_colors.dart';

/// Avatar oficial da Brawe (logo) usado na conversa de avisos do sistema.
class BraweOfficialAvatar extends StatelessWidget {
  const BraweOfficialAvatar({super.key, this.radius = 18});
  final double radius;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return CircleAvatar(
      radius: radius,
      backgroundColor: c.surfaceElevated,
      child: ClipOval(
        child: Image.asset(
          'assets/images/brawe-icon.png',
          width: radius * 2,
          height: radius * 2,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => Icon(LucideIcons.badgeCheck, size: radius, color: c.accentPrimary),
        ),
      ),
    );
  }
}

/// Ícone Lucide a partir do nome enviado pelo backend (kebab-case).
IconData systemNoticeIcon(String name) {
  switch (name) {
    case 'badge-check':
      return LucideIcons.badgeCheck;
    case 'circle-x':
      return LucideIcons.circleX;
    case 'circle-check':
      return LucideIcons.circleCheck;
    case 'hourglass':
      return LucideIcons.hourglass;
    case 'file-pen-line':
      return LucideIcons.filePenLine;
    case 'crown':
      return LucideIcons.crown;
    case 'trending-up':
      return LucideIcons.trendingUp;
    case 'trending-down':
      return LucideIcons.trendingDown;
    case 'award':
      return LucideIcons.award;
    case 'triangle-alert':
      return LucideIcons.triangleAlert;
    case 'ban':
      return LucideIcons.ban;
    case 'log-out':
      return LucideIcons.logOut;
    case 'message-square-x':
      return LucideIcons.messageSquareX;
    case 'clock':
      return LucideIcons.clock;
    case 'hand-heart':
      return LucideIcons.handHeart;
    case 'shield-check':
      return LucideIcons.shieldCheck;
    default:
      return LucideIcons.bell;
  }
}

Color systemNoticeToneColor(BraweColors c, SystemNoticeTone tone) {
  switch (tone) {
    case SystemNoticeTone.success:
      return c.success;
    case SystemNoticeTone.warning:
      return c.warning;
    case SystemNoticeTone.danger:
      return c.danger;
    case SystemNoticeTone.info:
      return c.accentPrimary;
  }
}

/// Rotas de tela cheia (fora do ShellRoute) podem ser empilhadas com `push`;
/// qualquer outra é do shell e, a partir de `/chat/:id` (fora do shell), só
/// funciona com `go` — `push` quebra o Navigator (keyReservation).
bool isTopLevelNoticeRoute(String route) => route.startsWith('/creator/agency/invite/');

void openSystemNoticeRoute(BuildContext context, String route) {
  if (isTopLevelNoticeRoute(route)) {
    context.push(route);
  } else {
    context.go(route);
  }
}

/// Abre o link externo do aviso no navegador (só https em brawe.app/brawe.io).
Future<void> openSystemNoticeUrl(String url) async {
  if (!isAllowedNoticeUrl(url)) return;
  await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
}

/// Cartão do aviso oficial da Brawe (`message_type == "system_notice"`).
class SystemNoticeBubble extends StatelessWidget {
  const SystemNoticeBubble({super.key, required this.message, this.onCta, this.onUrl});
  final ChatMessage message;

  /// Para testes/overrides do link externo; por padrão abre no navegador.
  final void Function(String url)? onUrl;

  /// Para testes/overrides; por padrão navega com go_router.
  final void Function(String route)? onCta;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final n = message.systemNotice;
    if (n == null) {
      // Sem `meta` (ex.: mensagem antiga): mostra o texto simples.
      return ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 340),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: c.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: c.border),
          ),
          child: Text(message.content, style: TextStyle(color: c.textPrimary, fontSize: 14, height: 1.35)),
        ),
      );
    }
    final tone = systemNoticeToneColor(c, n.tone);
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 340, minWidth: 220),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: tone.withValues(alpha: 0.45)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(color: tone.withValues(alpha: 0.14), shape: BoxShape.circle),
                  child: Icon(systemNoticeIcon(n.icon), size: 20, color: tone),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      n.title,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: c.textPrimary, fontSize: 15, fontWeight: FontWeight.w800, height: 1.2),
                    ),
                  ),
                ),
              ],
            ),
            if (n.body.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(n.body, style: TextStyle(color: c.textSecondary, fontSize: 13.5, height: 1.4)),
            ],
            if (n.cta != null) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(backgroundColor: tone, foregroundColor: c.textOnAccent),
                  onPressed: () {
                    final cta = n.cta!;
                    if (cta.url != null) {
                      onUrl != null ? onUrl!(cta.url!) : openSystemNoticeUrl(cta.url!);
                    } else if (cta.route != null) {
                      onCta != null ? onCta!(cta.route!) : openSystemNoticeRoute(context, cta.route!);
                    }
                  },
                  child: Text(n.cta!.label, maxLines: 1, overflow: TextOverflow.ellipsis),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Rodapé da conversa oficial: no lugar do campo de mensagem (somente leitura).
class SystemReadOnlyFooter extends StatelessWidget {
  const SystemReadOnlyFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(color: c.background, border: Border(top: BorderSide(color: c.divider))),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(LucideIcons.lock, size: 14, color: c.textTertiary),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  S.of(context).chatSystemReadOnlyNote,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: c.textSecondary, fontSize: 13, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
