// =============================================================================
// 🎁 STORY GIFT SHEET — Brawe Pulse
// =============================================================================
// Bottom sheet aberto a partir do StoryViewer para enviar um presente ao
// creator do story. Funciona praticamente igual ao gift sheet das lives, mas
// chama o endpoint `POST /stories/{storyId}/gift` (60% creator / 40% Brawe).
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/models/gift.dart';
import '../../../data/repositories/gift_repository.dart';
import '../../../gen/l10n/app_localizations.dart';
import '../../core/themes/app_colors.dart';
import '../../core/themes/force_dark_theme.dart';
import '../../live_feed/view_models/gift_catalog_view_model.dart';

class StoryGiftResult {
  const StoryGiftResult({
    required this.giftId,
    required this.giftName,
    required this.giftEmoji,
    required this.iconUrl,
    required this.quantity,
    required this.totalCredits,
  });

  final String giftId;
  final String giftName;
  final String? giftEmoji;
  final String? iconUrl;
  final int quantity;
  final int totalCredits;
}

class StoryGiftSheet extends ConsumerStatefulWidget {
  const StoryGiftSheet({
    super.key,
    required this.storyId,
    required this.creatorName,
    this.creatorAvatarUrl,
  });

  final String storyId;
  final String creatorName;
  final String? creatorAvatarUrl;

  static Future<StoryGiftResult?> show(
    BuildContext context, {
    required String storyId,
    required String creatorName,
    String? creatorAvatarUrl,
  }) {
    return showModalBottomSheet<StoryGiftResult>(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.55),
      builder: (_) => ForceDarkTheme(
        child: StoryGiftSheet(
          storyId: storyId,
          creatorName: creatorName,
          creatorAvatarUrl: creatorAvatarUrl,
        ),
      ),
    );
  }

  @override
  ConsumerState<StoryGiftSheet> createState() => _StoryGiftSheetState();
}

class _StoryGiftSheetState extends ConsumerState<StoryGiftSheet>
    with TickerProviderStateMixin {
  Gift? _selected;
  int _quantity = 1;
  bool _sending = false;
  TabController? _tabs;

  static const List<int> _quickQuantities = [1, 5, 10, 99];

  @override
  void dispose() {
    _tabs?.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final gift = _selected;
    if (gift == null || _sending) return;
    setState(() => _sending = true);
    try {
      await ref.read(giftRepositoryProvider).sendStoryGift(
            storyId: widget.storyId,
            giftId: gift.id,
            quantity: _quantity,
          );
      if (!mounted) return;
      Navigator.of(context).pop(
        StoryGiftResult(
          giftId: gift.id,
          giftName: gift.name,
          giftEmoji: gift.emoji,
          iconUrl: gift.iconUrl,
          quantity: _quantity,
          totalCredits: (gift.priceCredits * _quantity).round(),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.mutedRed,
          content: Text(S.of(context).giftSendError(e)),
        ),
      );
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final catalog = ref.watch(giftCatalogViewModelProvider);
    final mediaInsets = MediaQuery.of(context).viewInsets;

    return Padding(
      padding: EdgeInsets.only(bottom: mediaInsets.bottom),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        decoration: const BoxDecoration(
          color: AppColors.nearBlack,
          borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(
                width: 38,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 14),
              _Header(
                creatorName: widget.creatorName,
                creatorAvatarUrl: widget.creatorAvatarUrl,
              ),
              const SizedBox(height: 10),
              Expanded(
                child: catalog.when(
                  loading: () => const Center(
                    child: CircularProgressIndicator(color: Colors.white70),
                  ),
                  error: (e, _) => Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        S.of(context).giftLoadError(e),
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ),
                  ),
                  data: (tiers) {
                    if (tiers.isEmpty) {
                      return Center(
                        child: Text(
                          S.of(context).giftEmptyState,
                          style: const TextStyle(color: Colors.white70),
                        ),
                      );
                    }
                    _tabs ??= TabController(length: tiers.length, vsync: this);
                    return Column(
                      children: [
                        TabBar(
                          controller: _tabs,
                          isScrollable: true,
                          tabAlignment: TabAlignment.start,
                          indicatorColor: AppColors.electricPurple,
                          labelColor: Colors.white,
                          unselectedLabelColor: Colors.white54,
                          labelStyle: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                          tabs: [
                            for (final t in tiers)
                              Tab(text: _capitalize(t.name)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Expanded(
                          child: TabBarView(
                            controller: _tabs,
                            children: [
                              for (final t in tiers)
                                _GiftGrid(
                                  gifts: t.gifts,
                                  selectedId: _selected?.id,
                                  onSelect: (g) =>
                                      setState(() => _selected = g),
                                ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              _Footer(
                selected: _selected,
                quantity: _quantity,
                sending: _sending,
                onQuantity: (q) => setState(() => _quantity = q),
                quickQuantities: _quickQuantities,
                onSend: _send,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.creatorName, this.creatorAvatarUrl});

  final String creatorName;
  final String? creatorAvatarUrl;

  @override
  Widget build(BuildContext context) {
    final url = creatorAvatarUrl;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.slate,
            backgroundImage:
                (url != null && url.isNotEmpty) ? NetworkImage(url) : null,
            child: (url == null || url.isEmpty)
                ? Text(
                    creatorName.isNotEmpty
                        ? creatorName.characters.first.toUpperCase()
                        : '?',
                    style: const TextStyle(color: Colors.white),
                  )
                : null,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  S.of(context).giftSendTo,
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
                Text(
                  '@$creatorName',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GiftGrid extends StatelessWidget {
  const _GiftGrid({
    required this.gifts,
    required this.selectedId,
    required this.onSelect,
  });

  final List<Gift> gifts;
  final String? selectedId;
  final ValueChanged<Gift> onSelect;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 14),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 0.85,
      ),
      itemCount: gifts.length,
      itemBuilder: (_, i) {
        final g = gifts[i];
        final selected = g.id == selectedId;
        return _GiftCard(gift: g, selected: selected, onTap: () => onSelect(g));
      },
    );
  }
}

class _GiftCard extends StatelessWidget {
  const _GiftCard({
    required this.gift,
    required this.selected,
    required this.onTap,
  });

  final Gift gift;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      decoration: BoxDecoration(
        color: selected
            ? AppColors.electricPurple.withValues(alpha: 0.18)
            : Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: selected ? AppColors.electricPurple : Colors.white12,
          width: selected ? 1.6 : 1,
        ),
        boxShadow: selected
            ? [
                BoxShadow(
                  color: AppColors.electricPurple.withValues(alpha: 0.35),
                  blurRadius: 12,
                  spreadRadius: 0.5,
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _GiftIcon(gift: gift),
                const SizedBox(height: 6),
                Text(
                  gift.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.diamond_outlined,
                        size: 11, color: AppColors.coolCyan),
                    const SizedBox(width: 3),
                    Text(
                      gift.priceCredits.toStringAsFixed(0),
                      style: const TextStyle(
                        color: AppColors.coolCyan,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GiftIcon extends StatelessWidget {
  const _GiftIcon({required this.gift});
  final Gift gift;

  @override
  Widget build(BuildContext context) {
    final iconUrl = gift.iconUrl;
    if (iconUrl != null && iconUrl.isNotEmpty) {
      return SizedBox(
        width: 42,
        height: 42,
        child: Image.network(
          iconUrl,
          fit: BoxFit.contain,
          errorBuilder: (_, _, _) => _emojiFallback(gift.emoji),
        ),
      );
    }
    return _emojiFallback(gift.emoji);
  }

  Widget _emojiFallback(String? emoji) {
    return SizedBox(
      width: 42,
      height: 42,
      child: Center(
        child: Text(
          (emoji != null && emoji.isNotEmpty) ? emoji : '🎁',
          style: const TextStyle(fontSize: 30),
        ),
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer({
    required this.selected,
    required this.quantity,
    required this.sending,
    required this.onQuantity,
    required this.quickQuantities,
    required this.onSend,
  });

  final Gift? selected;
  final int quantity;
  final bool sending;
  final ValueChanged<int> onQuantity;
  final List<int> quickQuantities;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    final canSend = selected != null && !sending;
    final total = selected == null
        ? 0
        : (selected!.priceCredits * quantity).round();
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 16),
      decoration: const BoxDecoration(
        color: Color(0xFF0E1320),
        border: Border(top: BorderSide(color: Colors.white10)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              for (final q in quickQuantities)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _QtyChip(
                    value: q,
                    selected: q == quantity,
                    onTap: () => onQuantity(q),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: Opacity(
              opacity: canSend ? 1 : 0.45,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.electricPurple, AppColors.coolCyan],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: canSend
                      ? [
                          BoxShadow(
                            color: AppColors.electricPurple
                                .withValues(alpha: 0.45),
                            blurRadius: 14,
                            spreadRadius: 0.5,
                          ),
                        ]
                      : null,
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: canSend ? onSend : null,
                    child: Center(
                      child: sending
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.2,
                                color: Colors.white,
                              ),
                            )
                          : Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.card_giftcard,
                                    color: Colors.white, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  selected == null
                                      ? S.of(context).giftChoose
                                      : S.of(context).giftSendCta(total),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.4,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QtyChip extends StatelessWidget {
  const _QtyChip({
    required this.value,
    required this.selected,
    required this.onTap,
  });

  final int value;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.electricPurple.withValues(alpha: 0.25)
              : Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppColors.electricPurple : Colors.white24,
          ),
        ),
        child: Text(
          'x$value',
          style: TextStyle(
            color: selected ? Colors.white : Colors.white70,
            fontWeight: FontWeight.w800,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

String _capitalize(String s) =>
    s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';
