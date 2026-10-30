// ============================================================================
// GIFTERS SECTION — Histórico social agrupado por pessoa (estilo TikTok)
// ----------------------------------------------------------------------------
// Substitui a lista linear `_TransactionsList` da wallet. Em vez de mostrar
// "Castelo -30000 | Tsunami -25000 | Rosa -10 | Rosa -10 | Rosa -10", agrupa
// por contraparte e mostra um card por pessoa com:
//   • Avatar + nome + rank
//   • Total enviado/recebido + nº de lives
//   • Preview dos top 3 gifts (mini ícones)
//   • Botões: Mensagem (abre chat 1:1) e Seguir (se ainda não segue)
//
// Tap no card → bottom sheet com o breakdown completo (cada gift agrupado
// com qty total e valor).
//
// Estrutura:
//   [GiftersSection]            — widget público (toggle + lista)
//   [_GiftersTabs]              — chips Recebidos / Enviados
//   [_GifterCard]               — card de uma pessoa
//   [_GifterTopGiftBadge]       — mini ícone de gift no preview
//   [GifterDetailSheet]         — bottom sheet com breakdown completo
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/utils/gift_names.dart';
import '../../../data/repositories/chat_repository.dart';
import '../../../data/repositories/social_repository.dart';
import '../../../domain/models/gifter_summary.dart';
import '../../../gen/l10n/app_localizations.dart';
import '../../core/themes/app_colors.dart';
import '../../core/widgets/brawe_coin.dart';
import '../../core/widgets/gift_icon.dart';
import '../view_models/wallet_view_model.dart';

// ============================================================================
// Public widget
// ============================================================================

/// Seção completa: toggle Recebidos/Enviados + lista de gifter cards.
class GiftersSection extends ConsumerStatefulWidget {
  const GiftersSection({super.key});

  @override
  ConsumerState<GiftersSection> createState() => _GiftersSectionState();
}

class _GiftersSectionState extends ConsumerState<GiftersSection> {
  String _direction = 'received';

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final async = ref.watch(giftersProvider(direction: _direction));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _GiftersTabs(
          direction: _direction,
          onChanged: (d) => setState(() => _direction = d),
        ),
        const SizedBox(height: 12),
        async.when(
          loading: () => const Padding(
            padding: EdgeInsets.symmetric(vertical: 32),
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          ),
          error: (_, _) => _ErrorBox(
            message: s.giftersLoadError,
            onRetry: () =>
                ref.invalidate(giftersProvider(direction: _direction)),
          ),
          data: (items) {
            if (items.isEmpty) {
              return _EmptyView(direction: _direction);
            }
            return Column(
              children: [
                for (final g in items)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _GifterCard(gifter: g, direction: _direction),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

// ============================================================================
// Tabs
// ============================================================================

class _GiftersTabs extends StatelessWidget {
  final String direction;
  final ValueChanged<String> onChanged;
  const _GiftersTabs({required this.direction, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final scheme = Theme.of(context).colorScheme;
    Widget chip(String value, String label) {
      final selected = direction == value;
      return GestureDetector(
        onTap: () => onChanged(value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: selected ? AppColors.braweBlue : scheme.surface,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: selected
                  ? AppColors.braweBlue
                  : Theme.of(context).dividerColor,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : scheme.onSurface,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ),
      );
    }

    return Row(
      children: [
        chip('received', s.giftersTabReceived),
        const SizedBox(width: 8),
        chip('sent', s.giftersTabSent),
      ],
    );
  }
}

// ============================================================================
// Card
// ============================================================================

class _GifterCard extends ConsumerWidget {
  final GifterSummary gifter;
  final String direction;
  const _GifterCard({required this.gifter, required this.direction});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = S.of(context);
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => GifterDetailSheet.show(
        context,
        userId: gifter.userId,
        direction: direction,
      ),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Avatar(url: gifter.avatarUrl, size: 48),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              gifter.displayName.isNotEmpty
                                  ? gifter.displayName
                                  : gifter.username,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 15,
                              ),
                            ),
                          ),
                          if (gifter.rank != null &&
                              gifter.rank!.isNotEmpty) ...[
                            const SizedBox(width: 6),
                            _RankPill(rank: gifter.rank!),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          if (gifter.username.isNotEmpty)
                            Flexible(
                              child: Text(
                                '@${gifter.username}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: scheme.onSurface.withValues(
                                    alpha: 0.55,
                                  ),
                                ),
                              ),
                            ),
                          if (gifter.isFollower) ...[
                            if (gifter.username.isNotEmpty)
                              const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 1,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.braweBlue.withValues(
                                  alpha: 0.14,
                                ),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                s.giftersBadgeFollowsYou,
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.braweBlue,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                // Total à direita
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const BraweCoin(size: 16),
                        const SizedBox(width: 4),
                        Text(
                          _fmt(gifter.totalCredits),
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      s.giftersInLives(gifter.liveCount),
                      style: TextStyle(
                        fontSize: 11,
                        color: scheme.onSurface.withValues(alpha: 0.55),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Top 3 gifts
            if (gifter.topGifts.isNotEmpty)
              Row(
                children: [
                  for (int i = 0; i < gifter.topGifts.length; i++) ...[
                    _GifterTopGiftBadge(gift: gifter.topGifts[i]),
                    if (i < gifter.topGifts.length - 1)
                      const SizedBox(width: 8),
                  ],
                  const Spacer(),
                  Text(
                    s.giftersGiftsCount(gifter.giftCount),
                    style: TextStyle(
                      fontSize: 11,
                      color: scheme.onSurface.withValues(alpha: 0.55),
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 12),
            // Ações
            Row(
              children: [
                Expanded(
                  child: _ActionBtn(
                    icon: Icons.chat_bubble_outline,
                    label: direction == 'received'
                        ? s.giftersActionThank
                        : s.giftersActionMessage,
                    onTap: () => _openChat(context, ref),
                  ),
                ),
                if (!gifter.isFollowing) ...[
                  const SizedBox(width: 8),
                  Expanded(
                    child: _ActionBtn(
                      icon: Icons.person_add_alt_1_outlined,
                      label: s.giftersActionFollow,
                      filled: true,
                      onTap: () => _follow(context, ref),
                    ),
                  ),
                ] else ...[
                  const SizedBox(width: 8),
                  Expanded(
                    child: _ActionBtn(
                      icon: Icons.check,
                      label: s.giftersActionFollowing,
                      muted: true,
                      onTap: () {},
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openChat(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final convId = await ref
          .read(chatRepositoryProvider)
          .startConversation(participantId: gifter.userId);
      if (!context.mounted) return;
      context.push(
        '/chat/$convId',
        extra: {
          'participantName': gifter.displayName,
          'participantAvatarUrl': gifter.avatarUrl,
          'participantId': gifter.userId,
        },
      );
    } catch (_) {
      messenger.showSnackBar(
        SnackBar(content: Text(S.of(context).giftersLoadError)),
      );
    }
  }

  Future<void> _follow(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    final errorMsg = S.of(context).giftersFollowError;
    try {
      await ref.read(socialRepositoryProvider).followUser(gifter.userId);
      // Refaz a lista pra refletir o estado atual.
      ref.invalidate(giftersProvider(direction: direction));
    } catch (_) {
      messenger.showSnackBar(SnackBar(content: Text(errorMsg)));
    }
  }
}

// ============================================================================
// Helpers visuais
// ============================================================================

class _Avatar extends StatelessWidget {
  final String? url;
  final double size;
  const _Avatar({required this.url, this.size = 48});

  @override
  Widget build(BuildContext context) {
    final hasUrl = (url ?? '').isNotEmpty;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.braweBlue.withValues(alpha: 0.15),
        shape: BoxShape.circle,
        image: hasUrl
            ? DecorationImage(image: NetworkImage(url!), fit: BoxFit.cover)
            : null,
      ),
      child: hasUrl
          ? null
          : Icon(
              Icons.person,
              size: size * 0.55,
              color: AppColors.braweBlue,
            ),
    );
  }
}

class _RankPill extends StatelessWidget {
  final String rank;
  const _RankPill({required this.rank});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(
        color: AppColors.braweBlue.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        rank,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: AppColors.braweBlue,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

class _GifterTopGiftBadge extends StatelessWidget {
  final GifterTopGift gift;
  const _GifterTopGiftBadge({required this.gift});

  @override
  Widget build(BuildContext context) {
    final localizedName = GiftNames.of(context, gift.slug, fallback: gift.name);
    return Tooltip(
      message: '$localizedName ×${gift.quantity}',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        decoration: BoxDecoration(
          color: Theme.of(
            context,
          ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            GiftIcon(
              slug: gift.slug,
              tier: gift.tier,
              iconUrl: gift.iconUrl,
              size: 22,
            ),
            const SizedBox(width: 4),
            Text(
              '×${gift.quantity}',
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool filled;
  final bool muted;
  const _ActionBtn({
    required this.icon,
    required this.label,
    required this.onTap,
    this.filled = false,
    this.muted = false,
  });

  @override
  Widget build(BuildContext context) {
    final fg = filled
        ? Colors.white
        : muted
        ? Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.55)
        : AppColors.braweBlue;
    final bg = filled
        ? AppColors.braweBlue
        : muted
        ? Theme.of(
            context,
          ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.4)
        : AppColors.braweBlue.withValues(alpha: 0.10);
    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 9),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 15, color: fg),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: fg,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// Empty / Error
// ============================================================================

class _EmptyView extends StatelessWidget {
  final String direction;
  const _EmptyView({required this.direction});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final isReceived = direction == 'received';
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        children: [
          Image.asset(
            isReceived
                ? 'assets/images/illustrations/gift_3d.png'
                : 'assets/images/illustrations/coin_3d.png',
            width: 80,
            height: 80,
            errorBuilder: (_, _, _) => const Icon(
              Icons.card_giftcard_outlined,
              size: 60,
              color: AppColors.braweBlue,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            isReceived ? s.giftersEmptyReceivedTitle : s.giftersEmptySentTitle,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
          ),
          const SizedBox(height: 6),
          Text(
            isReceived ? s.giftersEmptyReceivedBody : s.giftersEmptySentBody,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              height: 1.4,
              color: scheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorBox extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorBox({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, size: 18),
          const SizedBox(width: 8),
          Expanded(child: Text(message)),
          TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}

// ============================================================================
// Detail bottom sheet
// ============================================================================

class GifterDetailSheet extends ConsumerWidget {
  final String userId;
  final String direction;
  const GifterDetailSheet({
    super.key,
    required this.userId,
    required this.direction,
  });

  static Future<void> show(
    BuildContext context, {
    required String userId,
    String direction = 'received',
  }) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => GifterDetailSheet(userId: userId, direction: direction),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = S.of(context);
    final scheme = Theme.of(context).colorScheme;
    final async = ref.watch(
      gifterDetailsProvider(userId: userId, direction: direction),
    );
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      builder: (_, controller) {
        return async.when(
          loading: () =>
              const Center(child: CircularProgressIndicator(strokeWidth: 2)),
          error: (_, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(s.giftersLoadError),
            ),
          ),
          data: (details) {
            final g = details.user;
            return ListView(
              controller: controller,
              // + viewPadding.bottom: fim da lista acima da barra de
              // navegação do Android (edge-to-edge).
              padding: EdgeInsets.fromLTRB(
                20,
                12,
                20,
                28 + MediaQuery.of(context).viewPadding.bottom,
              ),
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: scheme.onSurface.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                // Header
                Row(
                  children: [
                    _Avatar(url: g.avatarUrl, size: 64),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  g.displayName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                              if (g.rank != null && g.rank!.isNotEmpty) ...[
                                const SizedBox(width: 6),
                                _RankPill(rank: g.rank!),
                              ],
                            ],
                          ),
                          if (g.username.isNotEmpty)
                            Text(
                              '@${g.username}',
                              style: TextStyle(
                                fontSize: 12,
                                color: scheme.onSurface.withValues(alpha: 0.55),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                // Total + lives
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.braweBlue.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppColors.braweBlue.withValues(alpha: 0.25),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              direction == 'received'
                                  ? s.giftersDetailTotalReceived
                                  : s.giftersDetailTotalSent,
                              style: TextStyle(
                                fontSize: 11,
                                color: scheme.onSurface.withValues(alpha: 0.6),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const BraweCoin(size: 22),
                                const SizedBox(width: 6),
                                Text(
                                  _fmt(g.totalCredits),
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            s.giftersInLives(g.liveCount),
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            s.giftersGiftsCount(g.giftCount),
                            style: TextStyle(
                              fontSize: 11,
                              color: scheme.onSurface.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                // Lista de gifts
                Text(
                  s.giftersDetailGiftsTitle,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 10),
                for (final gift in details.gifts)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _GiftBreakdownTile(gift: gift),
                  ),
              ],
            );
          },
        );
      },
    );
  }
}

class _GiftBreakdownTile extends StatelessWidget {
  final GifterGiftBreakdown gift;
  const _GiftBreakdownTile({required this.gift});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          GiftIcon(
            slug: gift.slug,
            tier: gift.tier,
            iconUrl: gift.iconUrl,
            size: 36,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  GiftNames.of(context, gift.slug, fallback: gift.name),
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                Text(
                  '×${gift.quantity}',
                  style: TextStyle(
                    fontSize: 12,
                    color: scheme.onSurface.withValues(alpha: 0.55),
                  ),
                ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const BraweCoin(size: 14),
              const SizedBox(width: 4),
              Text(
                _fmt(gift.totalCredits),
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// Util
// ============================================================================

String _fmt(int n) {
  final s = n.toString();
  final b = StringBuffer();
  for (int j = 0; j < s.length; j++) {
    if (j > 0 && (s.length - j) % 3 == 0) b.write('.');
    b.write(s[j]);
  }
  return b.toString();
}
