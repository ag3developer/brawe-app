import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../data/repositories/auth_state_provider.dart';
import '../../../domain/models/story.dart';
import '../../../gen/l10n/app_localizations.dart';
import '../../core/themes/app_colors.dart';
import '../../core/themes/brawe_colors.dart';
import '../../core/themes/force_dark_theme.dart';
import '../../core/widgets/brawe_avatar.dart';
import '../view_models/stories_view_model.dart';
import 'story_composer_screen.dart';
import 'story_viewer.dart';
import 'package:brawe_app/ui/core/ui/verified_badge.dart';
import '../../ads/widgets/sponsored_story_screen.dart';

/// Fileira de stories — avatares circulares (padrão familiar).
///
/// - 1º item: "Seu story" (avatar do usuário + "+" azul). Sem stories próprios,
///   o toque abre o composer; com stories, o toque abre o viewer e o "+" /
///   long-press abrem o composer.
/// - Demais: anel com o gradiente da marca quando há stories não vistos,
///   anel `border` quando tudo foi visto, anel `liveRed` + selo quando ao vivo.
class StoriesRail extends ConsumerWidget {
  const StoriesRail({super.key});

  static const double _avatar = 64;
  static const double _ring = 2.5;
  static const double _gap = 2;
  static const double _outer = _avatar + (_ring + _gap) * 2;
  static const double _spacing = 14;
  static const double _height = _outer + 6 + 16 + 20; // anel + nome + padding

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncGroups = ref.watch(storiesViewModelProvider);

    return SizedBox(
      height: _height,
      child: asyncGroups.when(
        loading: () => _buildSkeleton(context),
        error: (_, _) => _buildError(context, ref),
        data: (groups) => _buildList(context, ref, groups),
      ),
    );
  }

  Widget _buildSkeleton(BuildContext context) {
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      itemCount: 6,
      separatorBuilder: (_, _) => const SizedBox(width: _spacing),
      itemBuilder: (_, _) => Column(
        children: [
          Container(
            width: _outer,
            height: _outer,
            decoration: BoxDecoration(
              color: context.colors.shimmerBase,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: 48,
            height: 10,
            decoration: BoxDecoration(
              color: context.colors.shimmerBase,
              borderRadius: BorderRadius.circular(5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(BuildContext context, WidgetRef ref) {
    return Center(
      child: TextButton.icon(
        icon: Icon(
          Icons.refresh,
          color: context.colors.textSecondary,
          size: 18,
        ),
        onPressed: () => ref.read(storiesViewModelProvider.notifier).refresh(),
        label: Text(
          S.of(context).storiesReload,
          style: TextStyle(color: context.colors.textSecondary),
        ),
      ),
    );
  }

  Widget _buildList(
    BuildContext context,
    WidgetRef ref,
    List<UserStoriesGroup> groups,
  ) {
    // O próprio usuário é representado pelo item "Seu story".
    final me = ref.watch(authStateProvider).asData?.value;
    final currentUserId = me?.id;
    final mine = currentUserId == null
        ? null
        : groups
              .where((g) => g.userId == currentUserId)
              .cast<UserStoriesGroup?>()
              .firstWhere((_) => true, orElse: () => null);
    final others = groups
        .where((g) => g.userId != currentUserId && g.stories.isNotEmpty)
        .toList();

    return ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      itemCount: others.length + 1,
      separatorBuilder: (_, _) => const SizedBox(width: _spacing),
      itemBuilder: (context, index) {
        if (index == 0) {
          final hasMine = mine != null && mine.stories.isNotEmpty;
          return _MyStoryItem(
            avatarUrl: me?.avatarUrl,
            name: me?.name ?? '',
            ring: hasMine
                ? (mine.hasUnviewed ? _RingStyle.unseen : _RingStyle.seen)
                : _RingStyle.none,
            onTap: hasMine
                ? () => _openViewer(context, ref, mine)
                : () => _openCreate(context),
            onCreate: () => _openCreate(context),
          );
        }
        final g = others[index - 1];
        final name =
            g.username ?? g.displayName ?? S.of(context).storiesFallbackUser;
        return _StoryItem(
          avatarUrl: g.avatarUrl,
          name: name,
          verified: g.isVerified,
          partnerAvatarUrl: g.hasLivePartner ? g.livePartnerAvatarUrl : null,
          partnerName: g.hasLivePartner ? (g.livePartnerName ?? '') : null,
          isBattle: g.liveKind == 'battle',
          ring: g.isLive
              ? _RingStyle.live
              : (g.hasUnviewed ? _RingStyle.unseen : _RingStyle.seen),
          onTap: () {
            if (g.isLive && g.liveRoomId != null) {
              context.push('/live/${g.liveRoomId}');
            } else {
              _openViewer(context, ref, g);
            }
          },
        );
      },
    );
  }

  void _openCreate(BuildContext context) {
    HapticFeedback.selectionClick();
    // rootNavigator: o editor de story é tela cheia — cobre a barra de
    // navegação (antes abria dentro da aba e a nav ficava por cima).
    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => const ForceDarkTheme(child: StoryComposerScreen()),
      ),
    );
  }

  Future<void> _openViewer(
    BuildContext context,
    WidgetRef ref,
    UserStoriesGroup group,
  ) async {
    // Modo imersivo — esconde status bar e nav bar do sistema durante o story.
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    // rootNavigator: true → sobe para o Navigator raiz (acima do ShellRoute),
    // cobrindo o BottomNavigationBar por completo — igual ao Instagram Stories.
    await Navigator.of(context, rootNavigator: true).push(
      PageRouteBuilder(
        opaque: false,
        fullscreenDialog: true,
        pageBuilder: (_, _, _) => ForceDarkTheme(
          child: StoryViewer(
            stories: group.stories,
            initialIndex: 0,
            onStoryViewed: (id) =>
                ref.read(storiesViewModelProvider.notifier).markAsViewed(id),
          ),
        ),
        transitionsBuilder: (_, animation, _, child) =>
            FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 200),
        reverseTransitionDuration: const Duration(milliseconds: 180),
      ),
    );

    // Brawe Ads: 1 anúncio entre grupos de stories (a cada N grupos, ver servidor)
    if (context.mounted) await maybeShowStoryAd(context, ref);

    // ── Restaura system UI ao voltar ──
    // Sem isso, ao fechar o viewer aberto a partir do stories_rail, a
    // status bar / nav bar continuariam escondidas para sempre (bug
    // confirmado em ANDROID_EDGE_TO_EDGE_AUDIT.md, Fase 8.2).
    if (context.mounted) {
      SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.edgeToEdge,
        overlays: SystemUiOverlay.values,
      );
    }
  }
}

enum _RingStyle { none, seen, unseen, live }

/// Avatar com anel (2.5px) + respiro (2px) no fundo do tema.
class _RingAvatar extends StatelessWidget {
  const _RingAvatar({
    required this.avatarUrl,
    required this.name,
    required this.ring,
  });

  final String? avatarUrl;
  final String name;
  final _RingStyle ring;

  @override
  Widget build(BuildContext context) {
    // Único lugar do feed onde o gradiente da marca aparece.
    final Gradient? gradient = ring == _RingStyle.unseen
        ? const LinearGradient(
            begin: Alignment.bottomLeft,
            end: Alignment.topRight,
            colors: AppColors.brandGradient,
          )
        : null;
    final Color? solid = switch (ring) {
      _RingStyle.seen => context.colors.border,
      _RingStyle.live => AppColors.liveRed,
      _RingStyle.none => Colors.transparent,
      _RingStyle.unseen => null,
    };

    return Container(
      width: StoriesRail._outer,
      height: StoriesRail._outer,
      padding: const EdgeInsets.all(StoriesRail._ring),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: gradient,
        color: solid,
      ),
      child: Container(
        padding: const EdgeInsets.all(StoriesRail._gap),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: context.colors.background,
        ),
        child: BraweAvatar(
          avatarUrl: avatarUrl,
          displayName: name,
          size: StoriesRail._avatar,
        ),
      ),
    );
  }
}

/// Duas fotos entrelaçadas como alianças: quem eu sigo (na frente, em cima à
/// esquerda) e o parceiro da conexão/batalha (atrás, embaixo à direita),
/// ambos com o anel vermelho de ao vivo.
class _LivePairAvatar extends StatelessWidget {
  const _LivePairAvatar({
    required this.avatarUrl,
    required this.name,
    required this.partnerAvatarUrl,
    required this.partnerName,
  });

  final String? avatarUrl;
  final String name;
  final String? partnerAvatarUrl;
  final String partnerName;

  static const double _d = 50; // diâmetro de cada anel

  Widget _ring(BuildContext context, String? url, String n) {
    const inner = _d - (StoriesRail._ring + StoriesRail._gap) * 2;
    return Container(
      width: _d,
      height: _d,
      padding: const EdgeInsets.all(StoriesRail._ring),
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.liveRed,
      ),
      child: Container(
        padding: const EdgeInsets.all(StoriesRail._gap),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: context.colors.background,
        ),
        child: BraweAvatar(avatarUrl: url, displayName: n, size: inner),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: StoriesRail._outer,
      height: StoriesRail._outer,
      child: Stack(
        children: [
          Positioned(
            right: 0,
            bottom: 0,
            child: _ring(context, partnerAvatarUrl, partnerName),
          ),
          Positioned(left: 0, top: 0, child: _ring(context, avatarUrl, name)),
        ],
      ),
    );
  }
}

class _ItemLabel extends StatelessWidget {
  const _ItemLabel(this.text, {this.verified = false});
  final String text;
  final bool verified;

  @override
  Widget build(BuildContext context) {
    final label = Text(
      text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      textAlign: TextAlign.center,
      style: TextStyle(
        color: context.colors.textSecondary,
        fontSize: 12,
        height: 1.3,
      ),
    );
    return SizedBox(
      width: StoriesRail._outer + 4,
      child: verified
          ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(child: label),
                const VerifiedBadge(size: 11, gap: 2),
              ],
            )
          : label,
    );
  }
}

/// Item "Seu story".
class _MyStoryItem extends StatelessWidget {
  const _MyStoryItem({
    required this.avatarUrl,
    required this.name,
    required this.ring,
    required this.onTap,
    required this.onCreate,
  });

  final String? avatarUrl;
  final String name;
  final _RingStyle ring;
  final VoidCallback onTap;
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    final label = S.of(context).storiesYour;
    return Semantics(
      button: true,
      label: label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        onLongPress: onCreate,
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                _RingAvatar(avatarUrl: avatarUrl, name: name, ring: ring),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: GestureDetector(
                    onTap: onCreate,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: context.colors.accentPrimary,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: context.colors.background,
                          width: 2.5,
                        ),
                      ),
                      child: Icon(
                        Icons.add_rounded,
                        color: context.colors.textOnAccent,
                        size: 15,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            _ItemLabel(label),
          ],
        ),
      ),
    );
  }
}

/// Story de outro usuário (ou live).
class _StoryItem extends StatelessWidget {
  const _StoryItem({
    required this.avatarUrl,
    required this.name,
    required this.ring,
    required this.onTap,
    this.verified = false,
    this.partnerAvatarUrl,
    this.partnerName,
    this.isBattle = false,
  });

  final String? avatarUrl;
  final String name;
  final bool verified;
  final _RingStyle ring;
  final VoidCallback onTap;

  /// Ao vivo em conexão/batalha: foto do parceiro entrelaçada ("alianças").
  final String? partnerAvatarUrl;
  final String? partnerName;
  final bool isBattle;

  @override
  Widget build(BuildContext context) {
    final isLive = ring == _RingStyle.live;
    return Semantics(
      button: true,
      label: name,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.bottomCenter,
              children: [
                if (isLive && partnerName != null)
                  _LivePairAvatar(
                    avatarUrl: avatarUrl,
                    name: name,
                    partnerAvatarUrl: partnerAvatarUrl,
                    partnerName: partnerName!,
                  )
                else
                  _RingAvatar(avatarUrl: avatarUrl, name: name, ring: ring),
                if (isLive)
                  Positioned(
                    bottom: -4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 1.5,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.liveRed,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: context.colors.background,
                          width: 1.5,
                        ),
                      ),
                      // Branco sobre o preenchimento vermelho (fixo).
                      child: Text(
                        isBattle
                            ? S.of(context).liveStoryBattleBadge
                            : S.of(context).liveBadge,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 8.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.4,
                          height: 1.1,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            _ItemLabel(name, verified: verified),
          ],
        ),
      ),
    );
  }
}
