// Lista agrupada no padrão dos Ajustes do iOS/Instagram (Configurações, Editar perfil, Tipo de conta, Verificação):
// cartões com legenda pequena em cinza acima, linhas com ícone discreto, valor atual à direita e seta.

import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../themes/brawe_colors.dart';

/// Conteúdo rolável centralizado (até 640 px em tablet).
class GroupedBody extends StatelessWidget {
  const GroupedBody({
    super.key,
    required this.children,
    this.padding = const EdgeInsets.fromLTRB(16, 8, 16, 24),
  });
  final List<Widget> children;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.topCenter,
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 640),
      child: ListView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: padding,
        children: children,
      ),
    ),
  );
}

/// Grupo em cartão. [caption] em maiúsculas pequenas acima; [footer] em cinza abaixo (explicação curta).
class GroupedSection extends StatelessWidget {
  const GroupedSection({
    super.key,
    required this.children,
    this.caption,
    this.footer,
    this.indent = 52,
  });
  final String? caption;
  final String? footer;
  final List<Widget> children;

  /// recuo da linha divisória (alinha com o texto quando há ícone)
  final double indent;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final rows = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      if (i > 0)
        rows.add(
          Divider(
            height: 0.5,
            thickness: 0.5,
            indent: indent,
            color: colors.divider,
          ),
        );
      rows.add(children[i]);
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (caption != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 7),
              child: Text(
                caption!.toUpperCase(),
                style: TextStyle(
                  color: colors.textTertiary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.6,
                ),
              ),
            ),
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Material(
              color: colors.surface,
              child: Column(children: rows),
            ),
          ),
          if (footer != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 8, 14, 0),
              child: Text(
                footer!,
                style: TextStyle(
                  color: colors.textTertiary,
                  fontSize: 12.5,
                  height: 1.35,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Linha: ícone · título (+ subtítulo) · valor · seta ou [trailing].
class GroupedRow extends StatelessWidget {
  const GroupedRow({
    super.key,
    required this.title,
    this.icon,
    this.subtitle,
    this.value,
    this.valueColor,
    this.trailing,
    this.onTap,
    this.danger = false,
    this.centered = false,
  });
  final IconData? icon;
  final String title;
  final String? subtitle;
  final String? value;
  final Color? valueColor;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool danger;
  final bool centered;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final fg = danger ? colors.danger : colors.textPrimary;
    return InkWell(
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 50),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 20,
                  color: danger ? colors.danger : colors.textSecondary,
                ),
                const SizedBox(width: 16),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: centered
                      ? CrossAxisAlignment.center
                      : CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      textAlign: centered ? TextAlign.center : TextAlign.start,
                      style: TextStyle(
                        color: fg,
                        fontSize: 15.5,
                        fontWeight: centered
                            ? FontWeight.w600
                            : FontWeight.w500,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: TextStyle(
                          color: colors.textSecondary,
                          fontSize: 13,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (value != null) ...[
                const SizedBox(width: 8),
                Text(
                  value!,
                  style: TextStyle(
                    color: valueColor ?? colors.textSecondary,
                    fontSize: 14.5,
                  ),
                ),
              ],
              if (trailing != null)
                trailing!
              else if (onTap != null && !centered) ...[
                const SizedBox(width: 6),
                Icon(
                  LucideIcons.chevronRight,
                  size: 18,
                  color: colors.textTertiary,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Campo de texto dentro de um cartão: rótulo pequeno acima, sem borda (o cartão é a moldura).
class GroupedField extends StatelessWidget {
  const GroupedField({
    super.key,
    required this.label,
    required this.child,
    this.trailing,
  });
  final String label;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 12, 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: colors.textSecondary,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                child,
              ],
            ),
          ),
          if (trailing != null)
            Padding(
              padding: const EdgeInsets.only(top: 18, left: 8),
              child: trailing,
            ),
        ],
      ),
    );
  }
}

/// Decoração dos campos dentro do cartão (sem borda, sem fundo).
InputDecoration groupedInput(
  BuildContext context, {
  String? hint,
  String? prefix,
  String? counter,
}) => InputDecoration(
  hintText: hint,
  prefixText: prefix,
  counterText: counter,
  isDense: true,
  border: InputBorder.none,
  enabledBorder: InputBorder.none,
  focusedBorder: InputBorder.none,
  contentPadding: const EdgeInsets.symmetric(vertical: 8),
  hintStyle: TextStyle(color: context.colors.textTertiary),
);
