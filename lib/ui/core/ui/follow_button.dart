import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../view_models/follow_view_model.dart';
import '../themes/brawe_colors.dart';
import '../../../gen/l10n/app_localizations.dart';

/// Botão de Seguir / Seguindo reutilizável.
///
/// Usado em 4 contextos:
/// - Overlay de live/HUD (sempre sobre vídeo escuro — usa branco fixo)
/// - Feed de curtidas (sempre sobre superfície escura da lista)
/// - Perfil (claro/escuro — usa `context.colors` via [useThemeColors])
///
/// ⭐ FIX: antes, quando `isFollowing == true`, o widget retornava
/// `SizedBox.shrink()` e escondia o botão por completo — o usuário não
/// tinha como deixar de seguir. Agora sempre renderiza, alternando o label
/// entre "Seguir" (`actionFollow`) e "Seguindo" (`actionUnfollow`), e o tap
/// sempre chama `toggleFollow()` (que já decide follow vs unfollow).
class FollowButton extends ConsumerWidget {
  final String userId;
  final bool compact;

  /// Quando `true`, usa `context.colors` (tema claro/escuro) em vez do
  /// branco fixo — necessário apenas no perfil, onde o botão pode aparecer
  /// sobre fundo claro. Overlays de vídeo/HUD devem manter o padrão (false).
  final bool useThemeColors;

  /// Quando `true`, usa um estilo "pill" preenchido (fundo sólido enquanto
  /// NÃO segue, outline neutro quando já segue) e ocupa a altura total do
  /// container pai — pensado para ficar visualmente em pé de igualdade com
  /// o botão de Mensagem no cabeçalho do perfil. Overlays de vídeo/HUD e o
  /// botão compacto do feed continuam com o outline fino de sempre (false).
  final bool filled;

  const FollowButton({
    super.key,
    required this.userId,
    this.compact = false,
    this.useThemeColors = false,
    this.filled = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final followState = ref.watch(followViewModelProvider(userId));

    final borderColor = useThemeColors ? context.colors.border : Colors.white;
    final textColor = useThemeColors
        ? context.colors.textPrimary
        : Colors.white;
    final accent = useThemeColors ? context.colors.accentPrimary : Colors.white;

    void onTap() =>
        ref.read(followViewModelProvider(userId).notifier).toggleFollow();

    return followState.when(
      data: (isFollowing) {
        final label = isFollowing
            ? S.of(context).actionUnfollow
            : S.of(context).actionFollow;

        if (!filled) {
          return GestureDetector(
            onTap: onTap,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: compact ? 8 : 12,
                vertical: compact ? 4 : 6,
              ),
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: borderColor, width: 1),
              ),
              child: Text(
                label,
                style: TextStyle(
                  color: textColor,
                  fontSize: compact ? 10 : 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        }

        // Estilo "pill" preenchido, para uso no cabeçalho do perfil —
        // preenchido/chamativo quando NÃO segue (call-to-action), outline
        // neutro quando já segue (ação secundária de "desfazer").
        return SizedBox(
          height: 40,
          width: double.infinity,
          child: GestureDetector(
            onTap: onTap,
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isFollowing ? Colors.transparent : accent,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isFollowing ? context.colors.divider : accent,
                ),
              ),
              child: Text(
                label,
                style: TextStyle(
                  color: isFollowing
                      ? context.colors.textPrimary
                      : context.colors.textOnAccent,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        );
      },
      loading: () => SizedBox(
        width: filled ? double.infinity : 16,
        height: filled ? 40 : 16,
        child: Center(
          child: SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2, color: textColor),
          ),
        ),
      ),
      error: (_, _) => const SizedBox.shrink(),
    );
  }
}
