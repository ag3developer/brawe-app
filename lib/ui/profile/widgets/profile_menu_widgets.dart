import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/themes/brawe_colors.dart';

/// Peças do menu "⋮" do perfil: folha com grupos (estilo Ajustes do iOS),
/// cada item com ícone num quadradinho colorido, título e subtítulo opcional.

/// Folha rolável com alça e altura máxima — o conteúdo vem em [children].
class ProfileMenuSheet extends StatelessWidget {
  const ProfileMenuSheet({super.key, required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final maxH = MediaQuery.sizeOf(context).height * 0.86;
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxH),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 10, bottom: 6),
              decoration: BoxDecoration(
                color: colors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: children,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Grupo de itens com título pequeno em cima.
class ProfileMenuGroup extends StatelessWidget {
  const ProfileMenuGroup({super.key, this.title, required this.items});
  final String? title;
  final List<Widget> items;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    if (items.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 0, 4, 6),
              child: Text(
                title!.toUpperCase(),
                style: TextStyle(
                  color: colors.textTertiary,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                ),
              ),
            ),
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Material(
              color: colors.surface,
              child: Column(
                children: [
                  for (var i = 0; i < items.length; i++) ...[
                    if (i > 0)
                      Padding(
                        padding: const EdgeInsets.only(left: 58),
                        child: Divider(
                          height: 1,
                          thickness: 0.6,
                          color: colors.divider,
                        ),
                      ),
                    items[i],
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Item do menu.
class ProfileMenuItem extends StatelessWidget {
  const ProfileMenuItem({
    super.key,
    required this.icon,
    required this.color,
    required this.title,
    this.subtitle,
    this.onTap,
    this.destructive = false,
    this.showChevron = true,
    this.trailing,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final bool destructive;
  final bool showChevron;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final fg = destructive ? colors.danger : colors.textPrimary;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 18, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: fg,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 1),
                    Text(
                      subtitle!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: colors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            ?trailing,
            if (showChevron && !destructive)
              Icon(
                LucideIcons.chevronRight,
                size: 18,
                color: colors.textTertiary,
              ),
          ],
        ),
      ),
    );
  }
}
