import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:brawe_app/config/feature_flags.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../../core/ui/app_spacing.dart';
import '../../../../../core/utils/gift_tier_names.dart';
import '../../../../live_feed/view_models/gift_catalog_view_model.dart';
import '../../../../live_feed/view_models/send_gift_view_model.dart';
import '../../../../live_feed/view_models/gifter_level_view_model.dart';
import '../../../../core/view_models/credits_view_model.dart';
import '../../../../wallet/widgets/top_up_coins_sheet.dart';
import '../../../../../data/repositories/auth_state_provider.dart';
import '../../../../../domain/models/gift.dart';
import '../../../../../domain/models/gifter_level.dart';
import '../../../../../domain/models/user.dart';
import '../../../../../gen/l10n/app_localizations.dart';
import '../../../../core/themes/force_dark_theme.dart';
import 'package:brawe_app/ui/core/ui/image_decode.dart';

/// 🎁 Catálogo de presentes — layout TikTok-style.
class GiftsOverlay extends ConsumerStatefulWidget {
  final String roomId;
  final String streamerId;
  final String? battleId;

  /// Pontos (moedas) que faltam para retomar uma posição no ranking. Quando
  /// informado, pré-seleciona o presente mais barato que cobre a diferença
  /// (e que o usuário pode pagar) e mostra uma dica no topo.
  final int? needPoints;

  /// Abre já com este presente selecionado (atalho da meta da live).
  final String? preselectGiftSlug;

  const GiftsOverlay({
    super.key,
    required this.roomId,
    required this.streamerId,
    this.battleId,
    this.needPoints,
    this.preselectGiftSlug,
  });

  static void show(
    BuildContext context,
    String roomId,
    String streamerId, {
    String? battleId,
    int? needPoints,
    String? preselectGiftSlug,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      // Sheet da live: sempre dark, igual à tela que o abriu.
      builder: (context) => ForceDarkTheme(
        child: GiftsOverlay(
          roomId: roomId,
          streamerId: streamerId,
          battleId: battleId,
          needPoints: needPoints,
          preselectGiftSlug: preselectGiftSlug,
        ),
      ),
    );
  }

  @override
  ConsumerState<GiftsOverlay> createState() => _GiftsOverlayState();
}

class _GiftsOverlayState extends ConsumerState<GiftsOverlay>
    with TickerProviderStateMixin {
  late TabController _tabController;
  Gift? _selectedGift;
  bool _preselectDone = false;
  bool _needHintNoGift = false;
  bool _isSending = false; // debounce — evita múltiplos POSTs simultâneos

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 0, vsync: this);
  }

  /// Retorna o índice da aba "basic" na lista de tiers vinda do backend.
  /// Se não existir (catálogo customizado), cai no índice 0 como fallback
  /// seguro em vez de quebrar.
  int _preferredTierIndex(List<GiftTier> tiers) {
    final idx = tiers.indexWhere((t) => t.name.trim().toLowerCase() == 'basic');
    return idx >= 0 ? idx : 0;
  }

  /// Presente mais barato que cobre [need] pontos e cabe no saldo.
  /// Pago: pontos = créditos. FREE: pontos = coins (saldo de coins não é
  /// conhecido no cliente — o servidor valida o envio).
  Gift? _cheapestCovering(List<GiftTier> tiers, int need, int balance) {
    Gift? best;
    for (final t in tiers) {
      for (final g in t.gifts) {
        final points = g.isMonetary ? g.priceCredits.ceil() : g.priceCoins;
        if (points < need) continue;
        if (g.isMonetary && balance < points) continue;
        if (best == null || points < _giftPoints(best)) best = g;
      }
    }
    return best;
  }

  int _giftPoints(Gift g) =>
      g.isMonetary ? g.priceCredits.ceil() : g.priceCoins;

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _handleSend() async {
    if (_selectedGift == null || _isSending) return;

    final gift = _selectedGift!;
    final s = S.of(context);

    // Verifica saldo ANTES de tentar enviar — se insuficiente abre top-up
    if (gift.isMonetary) {
      final balance = ref.read(creditsViewModelProvider).value?.toInt() ?? 0;
      final cost = gift.priceCredits.ceil();
      if (balance < cost) {
        if (kCoinPurchaseEnabled) {
          await TopUpCoinsSheet.show(
            context,
            reason: widget.battleId != null ? 'battle' : 'gift',
          );
        } else {
          // Compra de moedas ainda não existe: só avisa o saldo.
          ScaffoldMessenger.maybeOf(context)?.showSnackBar(
            SnackBar(content: Text(s.topUpReasonGift)),
          );
        }
        return;
      }
    }

    // Debounce — bloqueia novos taps enquanto este request está em voo
    setState(() => _isSending = true);

    // Captura TUDO que será usado depois do await ANTES do pop: o sheet é
    // desmontado no pop e `ref`/`context` dele deixam de ser utilizáveis
    // (antes o erro era engolido e o saldo nunca atualizava).
    final sendNotifier = ref.read(sendGiftViewModelProvider.notifier);
    final creditsNotifier = ref.read(creditsViewModelProvider.notifier);
    final levelNotifier = ref.read(gifterLevelViewModelProvider.notifier);
    final scaffoldMessenger = ScaffoldMessenger.maybeOf(context);
    final navigator = Navigator.of(context);
    final reason = widget.battleId != null ? 'battle' : 'gift';

    // Vibração proporcional ao presente: quem envia "sente" o envio.
    switch (gift.tier.toLowerCase()) {
      case 'luxury':
      case 'legendary':
        HapticFeedback.heavyImpact();
      case 'premium':
        HapticFeedback.mediumImpact();
      default:
        HapticFeedback.lightImpact();
    }

    // ── POP OTIMISTA: fecha a tela imediatamente ──
    // A animação do gift dispara via socket assim que o backend processa —
    // o usuário não precisa esperar a resposta HTTP.
    navigator.pop();

    final success = await sendNotifier.sendGift(
      roomId: widget.roomId,
      giftId: gift.id,
      receiverId: widget.streamerId,
      battleId: widget.battleId,
    );

    if (success) {
      creditsNotifier.refresh();
      levelNotifier.refresh();
      return; // a animação na tela já é a confirmação
    }

    final message =
        sendNotifier.lastErrorMessage ?? s.giftsError('Tente novamente');
    scaffoldMessenger
      ?..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red.shade700,
          action: kCoinPurchaseEnabled &&
                  sendNotifier.lastErrorIsBalance &&
                  gift.isMonetary
              ? SnackBarAction(
                  label: s.liveTopUpAction,
                  textColor: Colors.white,
                  onPressed: () {
                    if (navigator.mounted) {
                      TopUpCoinsSheet.show(navigator.context, reason: reason);
                    }
                  },
                )
              : null,
        ),
      );
    // Saldo pode ter mudado (ex.: outro dispositivo) — ressincroniza.
    creditsNotifier.refresh();
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final catalogState = ref.watch(giftCatalogViewModelProvider);
    final sendState = ref.watch(sendGiftViewModelProvider);

    return Container(
      height: MediaQuery.of(context).size.height * 0.62,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0F1C4D), Color(0xFF0A1230), Color(0xFF070A18)],
          stops: [0.0, 0.45, 1.0],
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
        border: Border(
          top: BorderSide(
            color: Colors.white.withValues(alpha: 0.08),
            width: 0.8,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.braweOrange.withValues(alpha: 0.25),
            blurRadius: 30,
            spreadRadius: -8,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: -40,
            left: -20,
            right: -20,
            height: 140,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.topCenter,
                    radius: 0.9,
                    colors: [
                      AppColors.braweOrange.withValues(alpha: 0.18),
                      AppColors.braweEmber.withValues(alpha: 0.10),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                ),
              ),
            ),
          ),
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
            child: _buildContent(context, s, catalogState, sendState),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    S s,
    AsyncValue<List<GiftTier>> catalogState,
    dynamic sendState,
  ) {
    return catalogState.when(
      data: (tiers) {
        final need = widget.needPoints;
        final credits = ref.watch(creditsViewModelProvider);
        var initialIndex = _preferredTierIndex(tiers);
        final goalSlug = widget.preselectGiftSlug;
        if (goalSlug != null && !_preselectDone) {
          _preselectDone = true;
          for (var i = 0; i < tiers.length; i++) {
            final hit = tiers[i].gifts.where((g) => g.slug == goalSlug);
            if (hit.isEmpty) continue;
            _selectedGift = hit.first;
            initialIndex = i;
            if (_tabController.length == tiers.length) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) _tabController.animateTo(i);
              });
            }
            break;
          }
        }
        if (need != null && !_preselectDone && credits.hasValue) {
          _preselectDone = true;
          final pick = _cheapestCovering(
            tiers,
            need,
            credits.value?.toInt() ?? 0,
          );
          if (pick != null) {
            _selectedGift = pick;
            final i = tiers.indexWhere((t) => t.gifts.any((g) => g.id == pick.id));
            if (i >= 0) {
              initialIndex = i;
              // Controller já criado (saldo chegou depois): move a aba.
              if (_tabController.length == tiers.length) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) _tabController.animateTo(i);
                });
              }
            }
          } else {
            _needHintNoGift = true;
          }
        }
        if (_tabController.length != tiers.length) {
          // Abre por padrão na aba "basic" (não no "free"/Cofre) —
          // presentes básicos são a experiência principal de envio; o
          // Cofre é secundário.
          _tabController = TabController(
            length: tiers.length,
            vsync: this,
            initialIndex: initialIndex,
          );
        }
        return Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 8),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            if (need != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Text(
                  _needHintNoGift
                      ? s.giftsNeedHintNone('$need')
                      : s.giftsNeedHint('$need'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFFFFD166),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            const _GamerLevelHeader(),
            if (tiers.isNotEmpty)
              TabBar(
                controller: _tabController,
                isScrollable: true,
                indicatorColor: AppColors.braweBlue,
                indicatorWeight: 2.5,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white54,
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  letterSpacing: 0.3,
                ),
                tabs: tiers
                    .map<Widget>(
                      // Localizado via GiftTierNames — "free" vira
                      // "COFRE" (PT) / "VAULT" (EN) / "BÓVEDA" (ES). UPPER
                      // pra manter o estilo TikTok dos tabs da live.
                      (t) => Tab(text: GiftTierNames.label(context, t.name, t.names).toUpperCase()),
                    )
                    .toList(),
              ),
            Expanded(
              child: tiers.isEmpty
                  ? Center(
                      child: Text(
                        s.giftsEmpty,
                        style: const TextStyle(color: Colors.white54),
                      ),
                    )
                  : TabBarView(
                      controller: _tabController,
                      children: tiers
                          .map<Widget>(
                            (tier) => _GiftsGrid(
                              gifts: tier.gifts,
                              selectedGift: _selectedGift,
                              onSelect: (gift) =>
                                  setState(() => _selectedGift = gift),
                              onConfirmTap: _handleSend,
                            ),
                          )
                          .toList(),
                    ),
            ),
            _BalanceFooter(
              isSending: _isSending,
              canSend: _selectedGift != null,
              onSend: _handleSend,
            ),
          ],
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppColors.braweBlue),
      ),
      error: (e, _) => Center(
        child: Text(
          s.giftsError(e.toString()),
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}

class _GamerLevelHeader extends ConsumerWidget {
  const _GamerLevelHeader();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final user = authState is AsyncData<User?> ? authState.value : null;
    final levelAsync = ref.watch(gifterLevelViewModelProvider);
    final data = levelAsync.value ?? GifterLevel.placeholder();
    final level = data.level;
    final next = data.nextLevel;
    final progress = next?.progressFraction ?? 1.0;
    final missing = next?.xpNeeded ?? 0;
    final badgeEmoji = data.badge.emoji;
    final badgeColor = _parseHex(data.badge.color) ?? const Color(0xFF3B82F6);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.sm,
        AppSpacing.sm,
      ),
      child: Row(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [AppColors.braweSpark, AppColors.braweEmber],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.braweEmber.withValues(alpha: 0.35),
                      blurRadius: 10,
                      spreadRadius: -1,
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(2),
                child: ClipOval(
                  child:
                      (user?.avatarUrl != null && user!.avatarUrl!.isNotEmpty)
                      ? Image.network(
                        cacheWidth: context.decodePx(44),
                          user.avatarUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => _avatarFallback(user),
                        )
                      : _avatarFallback(user),
                ),
              ),
              Positioned(
                left: -4,
                bottom: -2,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 1,
                  ),
                  decoration: BoxDecoration(
                    color: badgeColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: const Color(0xFF0A1230),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (badgeEmoji != null && badgeEmoji.isNotEmpty)
                        Text(
                          badgeEmoji,
                          style: const TextStyle(fontSize: 9, height: 1.0),
                        )
                      else
                        const Icon(
                          Icons.diamond_rounded,
                          size: 9,
                          color: Colors.white,
                        ),
                      const SizedBox(width: 2),
                      Text(
                        '$level',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          height: 1.0,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  next == null
                      ? 'Nível máximo alcançado 👑'
                      : 'Mais ${fmtThousands(missing)} XP para subir de nível',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 5),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Stack(
                    children: [
                      Container(
                        height: 6,
                        color: Colors.white.withValues(alpha: 0.10),
                      ),
                      FractionallySizedBox(
                        widthFactor: progress,
                        child: Container(
                          height: 6,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: AppColors.brandGradient,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right, color: Colors.white60),
            onPressed: () {},
            tooltip: 'Ver níveis',
          ),
        ],
      ),
    );
  }

  Widget _avatarFallback(User? user) {
    final initial = (user?.firstName.isNotEmpty == true)
        ? user!.firstName[0].toUpperCase()
        : '?';
    return Container(
      color: AppColors.deepBlue,
      alignment: Alignment.center,
      child: Text(
        initial,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
    );
  }

  static Color? _parseHex(String hex) {
    final h = hex.replaceAll('#', '');
    if (h.length != 6) return null;
    final v = int.tryParse(h, radix: 16);
    if (v == null) return null;
    return Color(0xFF000000 | v);
  }
}

String fmtThousands(int n) {
  final s = n.toString();
  final buf = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
    buf.write(s[i]);
  }
  return buf.toString();
}

class _GiftsGrid extends StatelessWidget {
  final List<Gift> gifts;
  final Gift? selectedGift;
  final ValueChanged<Gift> onSelect;
  final VoidCallback onConfirmTap;

  const _GiftsGrid({
    required this.gifts,
    required this.selectedGift,
    required this.onSelect,
    required this.onConfirmTap,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const cross = 4;
        const spacing = 6.0;
        const pad = 10.0;
        final tileW =
            (constraints.maxWidth - pad * 2 - spacing * (cross - 1)) / cross;
        final iconSize = (tileW * 0.92).clamp(64.0, 110.0);

        return GridView.builder(
          padding: const EdgeInsets.fromLTRB(pad, 8, pad, 8),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: cross,
            mainAxisSpacing: spacing,
            crossAxisSpacing: spacing,
            childAspectRatio: 0.78,
          ),
          itemCount: gifts.length,
          itemBuilder: (context, index) {
            final gift = gifts[index];
            final isSelected = selectedGift?.id == gift.id;
            return _GiftTile(
              gift: gift,
              isSelected: isSelected,
              iconSize: iconSize,
              onTap: () {
                if (isSelected) {
                  onConfirmTap();
                } else {
                  onSelect(gift);
                }
              },
            );
          },
        );
      },
    );
  }
}

class _GiftTile extends StatelessWidget {
  final Gift gift;
  final bool isSelected;
  final double iconSize;
  final VoidCallback onTap;

  const _GiftTile({
    required this.gift,
    required this.isSelected,
    required this.iconSize,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.braweBlue.withValues(alpha: 0.18)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppColors.braweBlue : Colors.transparent,
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.braweBlue.withValues(alpha: 0.35),
                    blurRadius: 14,
                    spreadRadius: -2,
                  ),
                ]
              : null,
        ),
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(
              child: Center(
                child: _GiftIcon(gift: gift, size: iconSize),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              gift.name,
              style: TextStyle(
                color: isSelected
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.88),
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                height: 1.1,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (gift.isFreeTier)
                  const Text('🪙', style: TextStyle(fontSize: 11))
                else
                  const _BraweCoin(size: 12),
                const SizedBox(width: 3),
                Text(
                  gift.isFreeTier
                      ? '${gift.priceCoins}'
                      : '${gift.price.toInt()}',
                  style: const TextStyle(
                    color: Color(0xFFFFD166),
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    height: 1.0,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BalanceFooter extends ConsumerWidget {
  final bool isSending;
  final bool canSend;
  final VoidCallback onSend;

  const _BalanceFooter({
    required this.isSending,
    required this.canSend,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final balance = ref.watch(creditsViewModelProvider).value?.toInt() ?? 0;
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.35),
        border: Border(
          top: BorderSide(
            color: Colors.white.withValues(alpha: 0.06),
            width: 0.5,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: 10,
          ),
          child: Row(
            children: [
              GestureDetector(
                onTap: kCoinPurchaseEnabled
                    ? () => TopUpCoinsSheet.show(context)
                    : null,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const _BraweCoin(size: 22),
                    const SizedBox(width: 6),
                    Text(
                      fmtThousands(balance),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: AppColors.braweOrange,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              SizedBox(
                height: 42,
                child: ElevatedButton(
                  onPressed: !canSend || isSending ? null : onSend,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.braweOrange,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.white12,
                    disabledForegroundColor: Colors.white38,
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(22),
                    ),
                    elevation: canSend ? 6 : 0,
                    shadowColor: AppColors.braweOrange.withValues(alpha: 0.5),
                  ),
                  child: isSending
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          S.of(context).giftsSendButton,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.3,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BraweCoin extends StatelessWidget {
  final double size;
  const _BraweCoin({this.size = 18});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/brawe_coin.png',
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (_, _, _) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            colors: [Color(0xFFFFE082), Color(0xFFFFB300)],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFFB300).withValues(alpha: 0.4),
              blurRadius: 4,
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          'B',
          style: TextStyle(
            color: const Color(0xFF7A4E00),
            fontSize: size * 0.6,
            fontWeight: FontWeight.w900,
            height: 1.0,
          ),
        ),
      ),
    );
  }
}

class _GiftIcon extends StatelessWidget {
  final Gift gift;
  final double size;
  const _GiftIcon({required this.gift, required this.size});

  @override
  Widget build(BuildContext context) {
    final assetPath = 'assets/images/gifts/${gift.tier}/${gift.slug}.png';
    // O asset 3.0x tem 768px (pensado pra animação grande); na sacola
    // decodifica só no tamanho do tile pra não pesar na memória.
    final cachePx = (size * MediaQuery.devicePixelRatioOf(context)).round();
    // Imagem subida no painel (URL absoluta) vence o PNG antigo do app.
    final url = gift.iconUrl?.trim() ?? '';
    if (url.startsWith('http') && !url.contains('/gifts/v1/')) {
      return Image.network(
        url,
        width: size,
        height: size,
        cacheWidth: cachePx,
        fit: BoxFit.contain,
        errorBuilder: (_, _, _) => Image.asset(
          assetPath,
          width: size,
          height: size,
          cacheWidth: cachePx,
          fit: BoxFit.contain,
          errorBuilder: (_, _, _) => _fallback(),
        ),
      );
    }
    return Image.asset(
      assetPath,
      width: size,
      height: size,
      cacheWidth: cachePx,
      fit: BoxFit.contain,
      errorBuilder: (_, _, _) {
        if (gift.iconUrl != null && gift.iconUrl!.isNotEmpty) {
          return Image.network(
            cacheWidth: context.decodePx(size),
            gift.iconUrl!,
            width: size,
            height: size,
            fit: BoxFit.contain,
            errorBuilder: (_, _, _) => _fallback(),
          );
        }
        return _fallback();
      },
    );
  }

  Widget _fallback() =>
      Icon(Icons.card_giftcard, color: Colors.white54, size: size * 0.8);
}
