
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../data/repositories/chat_repository.dart';
import '../../../../domain/models/creator_agency.dart';
import '../../../../gen/l10n/app_localizations.dart';
import '../../../core/themes/app_colors.dart';
import '../../../core/themes/brawe_colors.dart';
import 'agency_l10n.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Peças visuais do módulo de agência: densas, sóbrias, sem gamificação.
// ─────────────────────────────────────────────────────────────────────────────

/// Números alinhados (largura fixa) para valores que mudam.
const kTabularFigures = [FontFeature.tabularFigures()];

/// Estilos de texto do módulo (tamanhos em 8pt-friendly, cores do tema).
class AgencyText {
  AgencyText._();
  static TextStyle title(BuildContext c) =>
      TextStyle(color: c.colors.textPrimary, fontSize: 15, fontWeight: FontWeight.w700, height: 1.25);
  static TextStyle body(BuildContext c) => TextStyle(color: c.colors.textPrimary, fontSize: 14, height: 1.4);
  static TextStyle caption(BuildContext c) =>
      TextStyle(color: c.colors.textSecondary, fontSize: 12.5, height: 1.3);
  static TextStyle label(BuildContext c) => TextStyle(
      color: c.colors.textTertiary, fontSize: 11.5, fontWeight: FontWeight.w700, letterSpacing: .4, height: 1.2);
  static TextStyle number(BuildContext c, {double size = 20, Color? color}) => TextStyle(
        color: color ?? c.colors.textPrimary,
        fontSize: size,
        fontWeight: FontWeight.w800,
        height: 1.1,
        fontFeatures: kTabularFigures,
      );
}

/// Logo da agência, ou monograma quando não há logo (ou falha ao carregar).
class AgencyLogo extends StatelessWidget {
  const AgencyLogo({super.key, required this.name, this.url, this.size = 56});
  final String name;
  final String? url;
  final double size;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final mono = Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.braweDeep, AppColors.braweBlue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(size * 0.28),
      ),
      child: Text(_initials(name),
          textScaler: TextScaler.noScaling,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: size * 0.38)),
    );
    if (url == null) return mono;
    return ClipRRect(
      borderRadius: BorderRadius.circular(size * 0.28),
      child: Container(
        width: size,
        height: size,
        color: c.surfaceHighest,
        child: Image.network(
          url!,
          width: size,
          height: size,
          fit: BoxFit.cover,
          cacheWidth: (size * 3).round(),
          errorBuilder: (_, _, _) => mono,
        ),
      ),
    );
  }

  static String _initials(String n) {
    final parts = n.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.characters.first.toUpperCase();
    return (parts.first.characters.first + parts[1].characters.first).toUpperCase();
  }
}

class AgencyPersonAvatar extends StatelessWidget {
  const AgencyPersonAvatar({super.key, this.url, this.size = 40});
  final String? url;
  final double size;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final fallback = Icon(LucideIcons.userRound, size: size * 0.5, color: c.textTertiary);
    return ClipOval(
      child: Container(
        width: size,
        height: size,
        color: c.surfaceHighest,
        alignment: Alignment.center,
        child: url == null
            ? fallback
            : Image.network(url!,
                width: size, height: size, fit: BoxFit.cover, cacheWidth: (size * 3).round(), errorBuilder: (_, _, _) => fallback),
      ),
    );
  }
}

/// Cartão base: superfície + borda sutil.
class AgencyBox extends StatelessWidget {
  const AgencyBox({super.key, required this.child, this.padding = const EdgeInsets.all(16), this.onTap, this.borderColor});
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final radius = BorderRadius.circular(16);
    return Material(
      color: c.surface,
      shape: RoundedRectangleBorder(borderRadius: radius, side: BorderSide(color: borderColor ?? c.border)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(onTap: onTap, child: Padding(padding: padding, child: SizedBox(width: double.infinity, child: child))),
    );
  }
}

/// Título pequeno de bloco (ícone + texto), usado no topo de cartões.
class AgencyBoxTitle extends StatelessWidget {
  const AgencyBoxTitle({super.key, required this.icon, required this.text, this.trailing, this.color});
  final IconData icon;
  final String text;
  final Widget? trailing;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Row(children: [
      Icon(icon, size: 16, color: color ?? c.textSecondary),
      const SizedBox(width: 8),
      Expanded(child: Text(text, maxLines: 2, overflow: TextOverflow.ellipsis, style: AgencyText.title(context))),
      if (trailing != null) ...[const SizedBox(width: 8), Flexible(child: trailing!)],
    ]);
  }
}

class AgencyDivider extends StatelessWidget {
  const AgencyDivider({super.key});
  @override
  Widget build(BuildContext context) =>
      Divider(height: 1, thickness: 1, color: context.colors.divider);
}

class AgencyChip extends StatelessWidget {
  const AgencyChip({super.key, required this.label, this.icon, this.color, this.onTap});
  final String label;
  final IconData? icon;
  final Color? color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final col = color ?? c.textSecondary;
    return Material(
      color: col.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            if (icon != null) ...[Icon(icon, size: 13, color: col), const SizedBox(width: 5)],
            Flexible(
              child: Text(label,
                  maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: col, fontSize: 12, fontWeight: FontWeight.w700)),
            ),
          ]),
        ),
      ),
    );
  }
}

/// Barra de progresso fina.
class AgencyProgressBar extends StatelessWidget {
  const AgencyProgressBar({super.key, required this.value, this.color, this.height = 6});
  final double value;
  final Color? color;
  final double height;
  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return ClipRRect(
      borderRadius: BorderRadius.circular(height),
      child: LinearProgressIndicator(
        value: value.clamp(0.0, 1.0),
        minHeight: height,
        backgroundColor: c.surfaceHighest,
        valueColor: AlwaysStoppedAnimation(color ?? c.accentPrimary),
      ),
    );
  }
}

/// Linha rótulo + valor (valor à direita), com ícone opcional.
class AgencyInfoRow extends StatelessWidget {
  const AgencyInfoRow({super.key, required this.label, this.value, this.icon, this.trailing, this.onTap, this.valueColor});
  final String label;
  final String? value;
  final IconData? icon;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return InkWell(
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 44),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(children: [
            if (icon != null) ...[Icon(icon, size: 16, color: c.textTertiary), const SizedBox(width: 10)],
            Expanded(flex: 2, child: Text(label, style: AgencyText.caption(context))),
            if (value != null) ...[
              const SizedBox(width: 8),
              Flexible(
                flex: 3,
                child: Text(value!,
                    textAlign: TextAlign.end,
                    style: TextStyle(
                        color: valueColor ?? c.textPrimary,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        fontFeatures: kTabularFigures)),
              ),
            ],
            if (trailing != null) ...[const SizedBox(width: 6), trailing!],
          ]),
        ),
      ),
    );
  }
}

/// Bloco cinza de carregamento.
class AgencySkeletonBlock extends StatelessWidget {
  const AgencySkeletonBlock({super.key, required this.height, this.radius = 16});
  final double height;
  final double radius;
  @override
  Widget build(BuildContext context) => Container(
        height: height,
        decoration: BoxDecoration(color: context.colors.shimmerBase, borderRadius: BorderRadius.circular(radius)),
      );
}

/// Esqueleto de uma aba (alguns blocos).
class AgencySkeleton extends StatelessWidget {
  const AgencySkeleton({super.key, this.blocks = const [64, 120, 160]});
  final List<double> blocks;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        child: Column(children: [
          for (var i = 0; i < blocks.length; i++) ...[
            if (i > 0) const SizedBox(height: 12),
            AgencySkeletonBlock(height: blocks[i]),
          ],
        ]),
      );
}

/// Largura máxima + gutter de 16 + duas colunas em telas largas.
class AgencyColumns extends StatelessWidget {
  const AgencyColumns({super.key, required this.left, this.right = const []});
  final List<Widget> left;
  final List<Widget> right;

  static List<Widget> _spaced(List<Widget> l) => [
        for (var i = 0; i < l.length; i++) ...[if (i > 0) const SizedBox(height: 12), l[i]],
      ];

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1000),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          child: LayoutBuilder(builder: (context, box) {
            if (box.maxWidth >= 720 && right.isNotEmpty) {
              return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Expanded(child: Column(children: _spaced(left))),
                const SizedBox(width: 16),
                Expanded(child: Column(children: _spaced(right))),
              ]);
            }
            return Column(children: _spaced([...left, ...right]));
          }),
        ),
      ),
    );
  }
}

/// "Quem convidou": avatar, nome e papel — uma linha.
class AgencyInviterRow extends StatelessWidget {
  const AgencyInviterRow({super.key, required this.who, this.trailing});
  final AgencyInviter? who;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final c = context.colors;
    final name = who?.displayName ?? '';
    return Row(children: [
      AgencyPersonAvatar(url: who?.avatarUrl, size: 40),
      const SizedBox(width: 12),
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (name.isNotEmpty)
            Text(name, maxLines: 1, overflow: TextOverflow.ellipsis, style: AgencyText.title(context)),
          Row(children: [
            Icon(who?.isOwner == true ? LucideIcons.crown : LucideIcons.briefcase, size: 12, color: c.textTertiary),
            const SizedBox(width: 5),
            Expanded(
              child: Text(agencyRoleLabel(s, who), maxLines: 2, overflow: TextOverflow.ellipsis, style: AgencyText.caption(context)),
            ),
          ]),
        ]),
      ),
      if (trailing != null) ...[const SizedBox(width: 8), trailing!],
    ]);
  }
}

Future<void> openAgencyUrl(String raw) async {
  var u = raw.trim();
  if (!u.startsWith('http')) u = 'https://$u';
  final uri = Uri.tryParse(u);
  if (uri != null) await launchUrl(uri, mode: LaunchMode.externalApplication);
}

/// Abre (ou cria) a conversa com o representante da agência.
Future<void> openAgencyChat(BuildContext context, WidgetRef ref, AgencyInviter who) async {
  final messenger = ScaffoldMessenger.of(context);
  final router = GoRouter.maybeOf(context);
  final msg = S.of(context).agencyTalkError;
  try {
    final convId = await ref.read(chatRepositoryProvider).startConversation(participantId: who.userId);
    router?.push('/chat/$convId', extra: {
      'participantName': who.displayName,
      'participantAvatarUrl': who.avatarUrl,
      'participantId': who.userId,
    });
  } catch (_) {
    messenger.showSnackBar(SnackBar(content: Text(msg)));
  }
}

/// Diálogo de confirmação curto; [danger] pinta o botão de ação de vermelho.
Future<bool> showAgencyConfirm(
  BuildContext context, {
  required String title,
  required String body,
  required String action,
  bool danger = false,
  IconData? icon,
}) async {
  final s = S.of(context);
  final c = context.colors;
  final r = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      icon: icon == null ? null : Icon(icon, color: danger ? c.danger : c.accentPrimary),
      title: Text(title),
      content: SingleChildScrollView(child: Text(body)),
      actions: [
        TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: Text(s.actionCancel)),
        FilledButton(
          style: danger ? FilledButton.styleFrom(backgroundColor: c.danger, foregroundColor: Colors.white) : null,
          onPressed: () => Navigator.of(ctx).pop(true),
          child: Text(action),
        ),
      ],
    ),
  );
  return r == true;
}
