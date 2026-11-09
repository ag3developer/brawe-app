// =============================================================================
// STORY GIFT SHEET — Brawe Pulse
// =============================================================================
// Bottom sheet aberto a partir do StoryViewer para enviar um presente ao
// creator do story (`POST /stories/{storyId}/gift`, 60% creator / 40% Brawe).
//
// Fluxo estilo TikTok: toque no presente seleciona (o próprio card mostra o
// pill "Enviar"); toque de novo no mesmo card envia. Sem botão no rodapé.
// Combo: reenviar o mesmo presente em até 3 s soma "x2", "x3"... no card.
// Cores seguem o tema do app (tokens `context.colors`); o StoryViewer é
// forçado ao escuro, mas este painel usa o tema real via `StoryAppTheme`.
// Não compartilha widget com a sacola de lives (gifts_overlay.dart).
// =============================================================================

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../data/services/iap_service.dart';
import '../../../core/utils/gift_tier_names.dart';
import '../../../data/repositories/gift_repository.dart';
import '../../../domain/models/gift.dart';
import '../../../gen/l10n/app_localizations.dart';
import '../../core/themes/app_colors.dart';
import '../../core/themes/brawe_colors.dart';
import '../../core/ui/image_decode.dart';
import '../../core/ui/verified_badge.dart';
import '../../core/view_models/credits_view_model.dart';
import '../../core/widgets/brawe_coin.dart';
import '../../live_feed/view_models/gift_catalog_view_model.dart';
import '../../wallet/widgets/top_up_coins_sheet.dart';
import 'story_sheet_theme.dart';

/// Presentes com preço igual ou acima disto pedem confirmação antes de enviar.
/// TODO: virar configuração de admin/plataforma (não existe hoje no app nem
/// vem do backend).
const int kStoryGiftConfirmThreshold = 1000;

/// Janela do combo: reenviar o mesmo presente dentro dela soma no contador.
const Duration kStoryGiftComboWindow = Duration(seconds: 3);

class StoryGiftResult {
  const StoryGiftResult({
    required this.giftId,
    required this.giftName,
    required this.giftSlug,
    required this.giftTier,
    required this.giftEmoji,
    required this.iconUrl,
    required this.quantity,
    required this.totalCredits,
    this.combo = 1,
  });

  final String giftId;
  final String giftName;
  final String giftSlug;
  final String giftTier;
  final String? giftEmoji;
  final String? iconUrl;
  final int quantity;
  final int totalCredits;

  /// Posição no combo atual (1 = primeiro envio, 2 = "x2"...).
  final int combo;
}

class StoryGiftSheet extends ConsumerStatefulWidget {
  const StoryGiftSheet({
    super.key,
    required this.storyId,
    required this.creatorName,
    this.creatorAvatarUrl,
    this.isVerified = false,
    this.onSent,
    this.onRecharge,
    this.confirmThreshold = kStoryGiftConfirmThreshold,
  });

  final String storyId;
  final String creatorName;
  final String? creatorAvatarUrl;
  final bool isVerified;

  /// Chamado a cada envio bem-sucedido (o sheet continua aberto por causa do
  /// combo). O StoryViewer usa para tocar a animação do presente.
  final ValueChanged<StoryGiftResult>? onSent;

  /// Substitui o fluxo padrão de recarga (`TopUpCoinsSheet`). Útil em testes.
  final VoidCallback? onRecharge;

  final int confirmThreshold;

  static Future<void> show(
    BuildContext context, {
    required String storyId,
    required String creatorName,
    String? creatorAvatarUrl,
    bool isVerified = false,
    ValueChanged<StoryGiftResult>? onSent,
  }) {
    return showModalBottomSheet<void>(
      useSafeArea: true,
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.4),
      builder: (_) => StoryAppTheme(
        child: StoryGiftSheet(
          storyId: storyId,
          creatorName: creatorName,
          creatorAvatarUrl: creatorAvatarUrl,
          isVerified: isVerified,
          onSent: onSent,
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
  bool _sending = false;
  TabController? _tabs;

  // Combo
  String? _comboGiftId;
  int _comboCount = 0;
  Timer? _comboTimer;

  // Saldo local: evita piscar/zerar durante o refresh e permite combos
  // seguidos com o saldo já descontado.
  int? _balance;

  @override
  void dispose() {
    _comboTimer?.cancel();
    _tabs?.dispose();
    super.dispose();
  }

  int _preferredTierIndex(List<GiftTier> tiers) {
    final idx = tiers.indexWhere((t) => t.name.trim().toLowerCase() == 'basic');
    return idx >= 0 ? idx : 0;
  }

  int _cost(Gift g) => g.isMonetary ? g.priceCredits.ceil() : 0;

  bool _insufficient(Gift g) {
    final b = _balance;
    return g.isMonetary && b != null && b < _cost(g);
  }

  bool get _comboActive => _comboTimer?.isActive ?? false;

  void _recharge() {
    final cb = widget.onRecharge;
    if (cb != null) {
      cb();
      return;
    }
    if (!ref.read(coinPurchaseOpenProvider)) {
      ScaffoldMessenger.maybeOf(context)
        ?..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(S.of(context).topUpReasonGift)));
      return;
    }
    TopUpCoinsSheet.show(context, reason: 'gift');
  }

  Future<void> _onTileTap(Gift g) async {
    if (_sending) return;
    if (_selected?.id != g.id) {
      HapticFeedback.selectionClick();
      setState(() => _selected = g);
      return;
    }
    if (_insufficient(g)) {
      _recharge();
      return;
    }
    final continuing = _comboGiftId == g.id && _comboActive;
    if (!continuing && _cost(g) >= widget.confirmThreshold) {
      final ok = await _confirm(g);
      if (ok != true || !mounted) return;
    }
    await _send(g);
  }

  Future<bool?> _confirm(Gift g) {
    final price = _fmt(_cost(g));
    return showDialog<bool>(
      context: context,
      builder: (ctx) {
        final c = ctx.colors;
        final s = S.of(ctx);
        return AlertDialog(
          backgroundColor: c.surfaceElevated,
          title: Text(
            s.storyGiftConfirmTitle(g.name, price),
            style: TextStyle(
              color: c.textPrimary,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(
                s.viewerCancel,
                style: TextStyle(color: c.textSecondary),
              ),
            ),
            TextButton(
              key: const Key('story-gift-confirm'),
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(
                s.storyGiftSend,
                style: TextStyle(
                  color: c.accentPrimary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _send(Gift gift) async {
    if (_sending) return;
    setState(() => _sending = true);
    try {
      await ref
          .read(giftRepositoryProvider)
          .sendStoryGift(storyId: widget.storyId, giftId: gift.id, quantity: 1);
      if (!mounted) return;
      switch (gift.tier.toLowerCase()) {
        case 'luxury':
        case 'legendary':
          HapticFeedback.heavyImpact();
        case 'premium':
          HapticFeedback.mediumImpact();
        default:
          HapticFeedback.lightImpact();
      }
      final continuing = _comboGiftId == gift.id && _comboActive;
      _comboGiftId = gift.id;
      _comboCount = continuing ? _comboCount + 1 : 1;
      _comboTimer?.cancel();
      _comboTimer = Timer(kStoryGiftComboWindow, () {
        if (mounted) setState(() => _comboCount = 0);
      });
      final b = _balance;
      if (b != null) _balance = b - _cost(gift) < 0 ? 0 : b - _cost(gift);
      widget.onSent?.call(
        StoryGiftResult(
          giftId: gift.id,
          giftName: gift.name,
          giftSlug: gift.slug,
          giftTier: gift.tier,
          giftEmoji: gift.emoji,
          iconUrl: gift.iconUrl,
          quantity: 1,
          totalCredits: _cost(gift),
          combo: _comboCount,
        ),
      );
      // Ressincroniza o saldo com o servidor sem bloquear o combo.
      try {
        unawaited(ref.read(creditsViewModelProvider.notifier).refresh());
      } catch (_) {}
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

  String _fmt(num n) => NumberFormat.decimalPattern(
    Localizations.localeOf(context).toString(),
  ).format(n);

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final catalog = ref.watch(giftCatalogViewModelProvider);
    ref.watch(
      coinPurchaseOpenProvider,
    ); // mantém o catálogo da loja carregado enquanto aberto
    ref.listen(creditsViewModelProvider, (_, next) {
      final v = next.value;
      if (v != null && !next.isLoading && mounted) {
        setState(() => _balance = v.toInt());
      }
    });
    _balance ??= ref.read(creditsViewModelProvider).value?.toInt();

    final mediaInsets = MediaQuery.of(context).viewInsets;
    final screenHeight = MediaQuery.of(context).size.height;
    final maxSheetHeight = (screenHeight * 0.72).clamp(380.0, 720.0);

    return Padding(
      padding: EdgeInsets.only(bottom: mediaInsets.bottom),
      child: Container(
        constraints: BoxConstraints(maxHeight: maxSheetHeight),
        decoration: BoxDecoration(
          color: c.surfaceElevated,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
          border: Border(top: BorderSide(color: c.border, width: 0.8)),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
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
                    color: c.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 14),
                _Header(
                  creatorName: widget.creatorName,
                  creatorAvatarUrl: widget.creatorAvatarUrl,
                  isVerified: widget.isVerified,
                  balance: _balance,
                  fmt: _fmt,
                  onTapBalance: _recharge,
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: catalog.when(
                    loading: () => Center(
                      child: CircularProgressIndicator(color: c.accentPrimary),
                    ),
                    error: (e, _) => Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          S.of(context).giftLoadError(e),
                          textAlign: TextAlign.center,
                          style: TextStyle(color: c.textSecondary),
                        ),
                      ),
                    ),
                    data: (tiers) {
                      if (tiers.isEmpty) {
                        return Center(
                          child: Text(
                            S.of(context).giftEmptyState,
                            style: TextStyle(color: c.textSecondary),
                          ),
                        );
                      }
                      _tabs ??= TabController(
                        length: tiers.length,
                        vsync: this,
                        initialIndex: _preferredTierIndex(tiers),
                      );
                      return Column(
                        children: [
                          TabBar(
                            controller: _tabs,
                            isScrollable: true,
                            tabAlignment: TabAlignment.start,
                            indicatorColor: c.accentPrimary,
                            indicatorWeight: 2.5,
                            dividerColor: c.divider,
                            labelColor: c.textPrimary,
                            unselectedLabelColor: c.textSecondary,
                            labelStyle: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                              letterSpacing: 0.3,
                            ),
                            tabs: [
                              for (final t in tiers)
                                Tab(
                                  text: GiftTierNames.ofUpper(context, t.name),
                                ),
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
                                    sending: _sending,
                                    comboGiftId: _comboGiftId,
                                    comboCount: _comboCount,
                                    insufficient: _insufficient,
                                    fmt: _fmt,
                                    onTap: _onTileTap,
                                  ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.creatorName,
    required this.creatorAvatarUrl,
    required this.isVerified,
    required this.balance,
    required this.fmt,
    required this.onTapBalance,
  });

  final String creatorName;
  final String? creatorAvatarUrl;
  final bool isVerified;
  final int? balance;
  final String Function(num) fmt;
  final VoidCallback onTapBalance;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final url = creatorAvatarUrl;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [AppColors.braweBlue, AppColors.braweSky],
              ),
            ),
            padding: const EdgeInsets.all(2),
            child: ClipOval(
              child: (url != null && url.isNotEmpty)
                  ? Image.network(
                      url,
                      cacheWidth: context.decodePx(44),
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => _fallback(c),
                    )
                  : _fallback(c),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  S.of(context).giftSendTo,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: c.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 1),
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        '@$creatorName',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: c.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    if (isVerified) const VerifiedBadge(size: 16, gap: 4),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (balance != null)
            Semantics(
              button: true,
              label: S.of(context).storyGiftBalance(fmt(balance!)),
              child: GestureDetector(
                key: const Key('story-gift-balance'),
                behavior: HitTestBehavior.opaque,
                onTap: onTapBalance,
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 120),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: c.surfaceHighest,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const BraweCoin(size: 18),
                        const SizedBox(width: 6),
                        Text(
                          fmt(balance!),
                          style: TextStyle(
                            color: c.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _fallback(BraweColors c) => Container(
    color: c.surfaceHighest,
    alignment: Alignment.center,
    child: Text(
      creatorName.isNotEmpty ? creatorName.characters.first.toUpperCase() : '?',
      style: TextStyle(
        color: c.textPrimary,
        fontWeight: FontWeight.bold,
        fontSize: 16,
      ),
    ),
  );
}

class _GiftGrid extends StatelessWidget {
  const _GiftGrid({
    required this.gifts,
    required this.selectedId,
    required this.sending,
    required this.comboGiftId,
    required this.comboCount,
    required this.insufficient,
    required this.fmt,
    required this.onTap,
  });

  final List<Gift> gifts;
  final String? selectedId;
  final bool sending;
  final String? comboGiftId;
  final int comboCount;
  final bool Function(Gift) insufficient;
  final String Function(num) fmt;
  final ValueChanged<Gift> onTap;

  static const double _iconSize = 40;
  static const double _vPad = 8;

  @override
  Widget build(BuildContext context) {
    final scaler = MediaQuery.textScalerOf(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        const hPad = 14.0;
        const gap = 10.0;
        final cols = (constraints.maxWidth / 90).floor().clamp(3, 5);
        final tileW =
            (constraints.maxWidth - hPad * 2 - gap * (cols - 1)) / cols;
        // Altura derivada do conteúdo (e da escala de texto), não de uma
        // proporção fixa: o preço/pill nunca é cortado. O FittedBox do card
        // ainda reduz o conteúdo se algo passar do previsto.
        final nameH = scaler.scale(11) * 1.35;
        final rowH = scaler.scale(11) * 1.3 + 10; // altura do pill
        final extent = _vPad * 2 + _iconSize + 6 + nameH + 4 + rowH;
        return GridView.builder(
          padding: const EdgeInsets.fromLTRB(hPad, 8, hPad, 16),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: cols,
            mainAxisSpacing: gap,
            crossAxisSpacing: gap,
            mainAxisExtent: extent,
          ),
          itemCount: gifts.length,
          itemBuilder: (_, i) {
            final g = gifts[i];
            final selected = g.id == selectedId;
            return _GiftTile(
              gift: g,
              width: tileW,
              selected: selected,
              sending: selected && sending,
              insufficient: selected && insufficient(g),
              combo: g.id == comboGiftId ? comboCount : 0,
              fmt: fmt,
              onTap: () => onTap(g),
            );
          },
        );
      },
    );
  }
}

class _GiftTile extends StatelessWidget {
  const _GiftTile({
    required this.gift,
    required this.width,
    required this.selected,
    required this.sending,
    required this.insufficient,
    required this.combo,
    required this.fmt,
    required this.onTap,
  });

  final Gift gift;
  final double width;
  final bool selected;
  final bool sending;
  final bool insufficient;
  final int combo;
  final String Function(num) fmt;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final s = S.of(context);
    final innerW = (width - 8).clamp(40.0, 400.0);

    Widget bottom;
    if (selected) {
      final recharge = insufficient;
      bottom = _Pill(
        key: Key('gift-pill-${gift.id}'),
        label: recharge ? s.liveTopUpAction : s.storyGiftSend,
        recharge: recharge,
        loading: sending,
      );
    } else {
      bottom = FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const BraweCoin(size: 13),
            const SizedBox(width: 3),
            Text(
              fmt(gift.price.round()),
              style: TextStyle(
                color: c.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      );
    }

    return AnimatedScale(
      scale: selected ? 1.04 : 1,
      duration: const Duration(milliseconds: 160),
      curve: Curves.easeOutBack,
      child: AnimatedContainer(
        key: Key('gift-tile-${gift.id}'),
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          color: selected ? c.accentPrimary.withValues(alpha: 0.12) : c.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? c.accentPrimary : c.border,
            width: selected ? 1.6 : 1,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              children: [
                Positioned.fill(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: _GiftGrid._vPad,
                      horizontal: 4,
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: SizedBox(
                        width: innerW,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _GiftIcon(gift: gift),
                            const SizedBox(height: 6),
                            Text(
                              gift.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: c.textPrimary,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            bottom,
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                if (combo >= 2)
                  Positioned(
                    top: 4,
                    right: 4,
                    child: TweenAnimationBuilder<double>(
                      key: ValueKey(combo),
                      tween: Tween(begin: 1.4, end: 1),
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeOutBack,
                      builder: (_, v, child) =>
                          Transform.scale(scale: v, child: child),
                      child: Container(
                        key: Key('gift-combo-${gift.id}'),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: c.accentPink,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'x$combo',
                          style: TextStyle(
                            color: c.textOnAccent,
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({
    super.key,
    required this.label,
    required this.recharge,
    required this.loading,
  });

  final String label;
  final bool recharge;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: recharge
                ? const [AppColors.braweOrange, AppColors.braweOrange]
                : [c.accentPrimary, c.accentSecondary],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: loading
            ? SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: c.textOnAccent,
                ),
              )
            : Text(
                label,
                maxLines: 1,
                style: TextStyle(
                  color: c.textOnAccent,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
      ),
    );
  }
}

/// Ícone de presente — MESMO padrão da sacola de Live/Batalha
/// (gifts_overlay.dart): asset local, depois rede (icon_url), depois emoji.
class _GiftIcon extends StatelessWidget {
  const _GiftIcon({required this.gift});
  final Gift gift;

  static const double _size = _GiftGrid._iconSize;

  @override
  Widget build(BuildContext context) {
    final assetPath = 'assets/images/gifts/${gift.tier}/${gift.slug}.png';
    return SizedBox(
      width: _size,
      height: _size,
      child: Image.asset(
        assetPath,
        width: _size,
        height: _size,
        cacheWidth: (_size * MediaQuery.devicePixelRatioOf(context)).round(),
        fit: BoxFit.contain,
        errorBuilder: (_, _, _) {
          final iconUrl = gift.iconUrl;
          if (iconUrl != null && iconUrl.isNotEmpty) {
            return Image.network(
              iconUrl,
              cacheWidth: context.decodePx(_size),
              width: _size,
              height: _size,
              fit: BoxFit.contain,
              errorBuilder: (_, _, _) => _emojiFallback(gift.emoji),
            );
          }
          return _emojiFallback(gift.emoji);
        },
      ),
    );
  }

  Widget _emojiFallback(String? emoji) {
    return SizedBox(
      width: _size,
      height: _size,
      child: Center(
        child: Text(
          (emoji != null && emoji.isNotEmpty) ? emoji : '🎁',
          style: const TextStyle(fontSize: 30),
        ),
      ),
    );
  }
}
