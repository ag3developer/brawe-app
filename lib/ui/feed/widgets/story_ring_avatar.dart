import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/providers/story_active_status_provider.dart';
import '../../../data/repositories/stories_repository.dart';
import '../../../domain/models/story.dart';
import '../../core/themes/app_colors.dart';
import '../../core/themes/force_dark_theme.dart';
import '../../profile/widgets/profile_screen.dart' show userStoriesProvider;
import 'story_viewer.dart';

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
    colors: [
      Color(0xFFE040FB),
      Color(0xFFFF6B35),
      Color(0xFF7C4DFF),
    ],
  );

  static const _onlineGradient = LinearGradient(
    colors: [AppColors.electricPurple, AppColors.coolCyan],
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
      ringColor = Colors.white24;
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
        backgroundImage:
            (avatarUrl != null && avatarUrl!.isNotEmpty)
                ? NetworkImage(avatarUrl!)
                : null,
        child: (avatarUrl == null || avatarUrl!.isEmpty)
            ? Text(
                (fallbackText != null && fallbackText!.isNotEmpty)
                    ? fallbackText![0].toUpperCase()
                    : '?',
                style: TextStyle(
                  color: Colors.white,
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
                  border:
                      Border.all(color: AppColors.nearBlack, width: 1.8),
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

    await Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => ForceDarkTheme(
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
      ),
    );

    // Garante refresh ao voltar do viewer.
    invalidateStoryActiveStatus(ref, userId);
  }
}
