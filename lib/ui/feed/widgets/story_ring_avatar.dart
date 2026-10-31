import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/providers/story_active_status_provider.dart';
import '../../../data/repositories/stories_repository.dart';
import '../../../domain/models/story.dart';
import '../../core/themes/app_colors.dart';
import '../../core/themes/brawe_colors.dart';
import '../../core/themes/force_dark_theme.dart';
import '../../profile/widgets/profile_screen.dart' show userStoriesProvider;
import 'story_viewer.dart';
import 'package:brawe_app/ui/core/ui/image_decode.dart';

/// Avatar reutilizável com anel de stories.
///
/// - Lê `storyActiveStatusProvider(userId)` (batch + cache) para saber se o
///   usuário tem stories ativas e se há alguma não-vista.
/// - Ao tocar:
///   * Se tem stories → abre o `StoryViewer` em fullscreen.
///   * Caso contrário → executa `onTapWithoutStories` (ex.: ir para perfil).
/// - Pode renderizar um indicador "online" no canto inferior direito.
///
/// Use em qualquer lugar que mostre avatar de usuário (chat header,
/// post header, comentários, lista de conversas, etc.) para incentivar
/// descoberta orgânica de stories.
class StoryRingAvatar extends ConsumerWidget {
  const StoryRingAvatar({
    super.key,
    required this.userId,
    this.avatarUrl,
    this.fallbackText,
    this.radius = 18,
    this.onTapWithoutStories,
    this.isOnline = false,
    this.showOnlineIndicator = false,
    this.backgroundColor,
  });

  final String userId;
  final String? avatarUrl;

  /// Texto exibido quando não há `avatarUrl` (ex.: inicial do nome).
  final String? fallbackText;

  final double radius;

  /// Callback quando o usuário não tem stories ativas.
  final VoidCallback? onTapWithoutStories;

  /// Se `true` e [showOnlineIndicator] também, renderiza o ponto verde.
  final bool isOnline;
  final bool showOnlineIndicator;

  final Color? backgroundColor;

  static const _unviewedGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: AppColors.brandGradient,
  );

  static const _onlineGradient = LinearGradient(
    colors: [AppColors.braweBlue, AppColors.braweSky],
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusAsync = userId.isEmpty
        ? null
        : ref.watch(storyActiveStatusProvider(userId));
    final status = statusAsync?.asData?.value;
    final hasStories = status?.hasStories ?? false;
    final hasUnviewed = status?.hasUnviewed ?? false;

    final showOnline = isOnline && showOnlineIndicator;
    final ringPadding = (hasStories || showOnline) ? 2.0 : 0.0;

    LinearGradient? gradient;
    Color? ringColor;
    if (hasUnviewed) {
      gradient = _unviewedGradient;
    } else if (hasStories) {
      ringColor = context.colors.border;
    } else if (showOnline) {
      gradient = _onlineGradient;
    }

    final avatar = Container(
      padding: EdgeInsets.all(ringPadding),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: gradient,
        color: gradient == null ? ringColor : null,
      ),
      child: CircleAvatar(
        radius: radius,
        backgroundColor: backgroundColor ?? AppColors.slate,
        backgroundImage: (avatarUrl != null && avatarUrl!.isNotEmpty)
            ? ResizeImage(NetworkImage(avatarUrl!), width: context.decodePx(radius * 2))
            : null,
        child: (avatarUrl == null || avatarUrl!.isEmpty)
            ? Text(
                (fallbackText != null && fallbackText!.isNotEmpty)
                    ? fallbackText![0].toUpperCase()
                    : '?',
                style: TextStyle(
                  // Com fundo do tema (backgroundColor) a inicial usa
                  // textPrimary — branco fixo sumia no tema claro.
                  color: backgroundColor != null
                      ? context.colors.textPrimary
                      : Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: radius * 0.85,
                ),
              )
            : null,
      ),
    );

    final dotSize = (radius * 0.6).clamp(8.0, 14.0);
    final tappable = GestureDetector(
      onTap: () => _handleTap(context, ref, hasUnviewed),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          avatar,
          if (showOnline)
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: dotSize,
                height: dotSize,
                decoration: BoxDecoration(
                  color: Colors.greenAccent.shade400,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: context.colors.background,
                    width: 1.8,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.greenAccent.withValues(alpha: 0.6),
                      blurRadius: 6,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );

    return tappable;
  }

  Future<void> _handleTap(
    BuildContext context,
    WidgetRef ref,
    bool hasUnviewed,
  ) async {
    // Se não há stories não-vistas, vai direto para o perfil.
    if (!hasUnviewed) {
      onTapWithoutStories?.call();
      return;
    }

    // Busca os stories do usuário sob demanda (só quando realmente
    // vai abrir o viewer) — evita carregar a lista completa para todos
    // os avatares na tela.
    final repo = ref.read(storiesRepositoryProvider);
    List<Story> stories;
    try {
      stories = await repo.getUserStories(userId);
    } catch (_) {
      stories = const <Story>[];
    }

    if (!context.mounted) return;

    // Filtra somente stories ainda não vistos.
    final unseen = stories.where((s) => !s.isSeen).toList(growable: false);

    if (unseen.isEmpty) {
      // Status estava desatualizado — invalida e cai pra ação alternativa.
      invalidateStoryActiveStatus(ref, userId);
      onTapWithoutStories?.call();
      return;
    }

    // ── Fullscreen TRUE (estilo Instagram/TikTok) ──────────────────────
    //
    // ⚠️ DOIS detalhes críticos pra ficar igual ao Instagram:
    //
    // 1) `rootNavigator: true` — sem isso o push acontece no Navigator
    //    do ShellRoute (router.dart linha 128), que tem o
    //    `bottomNavigationBar: HomeBottomNav()` SEMPRE renderizado por
    //    baixo. Resultado: o story aparece com a nav bar embaixo,
    //    cortando ~80px do final da mídia. Com `rootNavigator: true`
    //    o push vai no Navigator raiz (acima do Shell), ocupando 100%
    //    da viewport — exatamente como o Instagram.
    //
    // 2) `SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky)`
    //    esconde a status bar (relógio + bateria) e a nav bar do Android
    //    (botões home/back) durante o viewer. Restauramos para `edgeToEdge`
    //    no `.then()` quando o usuário volta. O modo `immersiveSticky`
    //    deixa a barra aparecer rapidamente em swipe da borda mas volta
    //    a esconder sozinha — padrão de apps de mídia (YouTube, IG, TikTok).
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    final navigator = Navigator.of(context, rootNavigator: true);
    await navigator.push(
      PageRouteBuilder(
        // Página opaca preta — sem transparência o GPU não precisa
        // compor a árvore antiga embaixo, economizando frame budget
        // no momento mais "wow" da animação de abertura.
        opaque: true,
        barrierColor: Colors.black,
        fullscreenDialog: true,
        // Duração da transição igual ao Instagram (~280ms). Curva
        // `easeOutCubic` dá o efeito de "puxar pra cima" rápido no
        // início e desacelera no final — sensação de inércia natural.
        transitionDuration: const Duration(milliseconds: 280),
        reverseTransitionDuration: const Duration(milliseconds: 220),
        pageBuilder: (_, _, _) => ForceDarkTheme(
          child: StoryViewer(
            stories: unseen,
            initialIndex: 0,
            onStoryViewed: (_) {
              // Invalida estado para refletir "todos vistos" após o viewer.
              invalidateStoryActiveStatus(ref, userId);
              ref.invalidate(userStoriesProvider(userId));
            },
          ),
        ),
        transitionsBuilder: (_, animation, _, child) {
          // Combo "scale + fade" estilo Instagram: o story "explode"
          // a partir do avatar tocado. Não conseguimos ancorar no avatar
          // exato (precisa de Hero animation, refatoração maior), mas
          // o scale de 0.92 → 1.0 + fade dá a sensação certa.
          return FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.92, end: 1.0).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
              ),
              child: child,
            ),
          );
        },
      ),
    );

    // ── Restaura system UI ao voltar ──
    // `edgeToEdge` é o modo padrão do app (status bar transparente
    // sobreposta ao conteúdo, sem padding reservado). Sem essa linha
    // a status bar ficaria escondida pra sempre após fechar o viewer.
    if (context.mounted) {
      SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.edgeToEdge,
        overlays: SystemUiOverlay.values,
      );
    }

    // Garante refresh ao voltar do viewer.
    invalidateStoryActiveStatus(ref, userId);
  }
}
