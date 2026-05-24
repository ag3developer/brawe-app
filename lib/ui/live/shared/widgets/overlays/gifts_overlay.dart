import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../../core/ui/app_spacing.dart';
import '../../../../live_feed/view_models/gift_catalog_view_model.dart';
import '../../../../live_feed/view_models/send_gift_view_model.dart';
import '../../../../core/view_models/credits_view_model.dart';
import '../../../../../domain/models/gift.dart';
import '../../../../../gen/l10n/app_localizations.dart';

class GiftsOverlay extends ConsumerStatefulWidget {
  final String roomId;
  final String streamerId;
  final String? battleId;

  const GiftsOverlay({
    super.key,
    required this.roomId,
    required this.streamerId,
    this.battleId,
  });

  static void show(BuildContext context, String roomId, String streamerId, {String? battleId}) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => GiftsOverlay(roomId: roomId, streamerId: streamerId, battleId: battleId),
    );
  }

  @override
  ConsumerState<GiftsOverlay> createState() => _GiftsOverlayState();
}

class _GiftsOverlayState extends ConsumerState<GiftsOverlay> with TickerProviderStateMixin {
  late TabController _tabController;
  Gift? _selectedGift;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 0, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _handleSend() async {
    if (_selectedGift == null) return;

    final s = S.of(context);
    final giftName = _selectedGift!.name;
    final success = await ref.read(sendGiftViewModelProvider.notifier).sendGift(
      roomId: widget.roomId,
      giftId: _selectedGift!.id,
      receiverId: widget.streamerId,
      battleId: widget.battleId,
    );

    if (success && mounted) {
      ref.read(creditsViewModelProvider.notifier).refresh();
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(s.giftsSent(giftName))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final catalogState = ref.watch(giftCatalogViewModelProvider);
    final sendState = ref.watch(sendGiftViewModelProvider);

    return Container(
      height: MediaQuery.of(context).size.height * 0.5,
      decoration: const BoxDecoration(
        color: AppColors.nearBlack,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: catalogState.when(
        data: (tiers) {
          if (_tabController.length != tiers.length) {
            _tabController = TabController(length: tiers.length, vsync: this);
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      s.giftsTitle,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              if (tiers.isNotEmpty)
                TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  indicatorColor: AppColors.electricPurple,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white54,
                  tabs: tiers.map((t) => Tab(text: t.name.toUpperCase())).toList(),
                ),
              Expanded(
                child: tiers.isEmpty
                    ? Center(child: Text(s.giftsEmpty, style: const TextStyle(color: Colors.white54)))
                    : TabBarView(
                        controller: _tabController,
                        children: tiers.map((tier) => _GiftsGrid(
                          gifts: tier.gifts,
                          selectedGift: _selectedGift,
                          onSelect: (gift) => setState(() => _selectedGift = gift),
                        )).toList(),
                      ),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Row(
                    children: [
                      const Icon(Icons.account_balance_wallet, color: AppColors.coolCyan, size: 20),
                      const SizedBox(width: 8),
                      Consumer(
                        builder: (context, ref, child) {
                          final balanceState = ref.watch(creditsViewModelProvider);
                          return Text(
                            s.giftsCreditsLabel(balanceState.value?.toInt() ?? 0),
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          );
                        },
                      ),
                      const Spacer(),
                      ElevatedButton(
                        onPressed: _selectedGift == null || sendState.isLoading ? null : _handleSend,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.electricPurple,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: Colors.white10,
                          minimumSize: const Size(100, 40),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        ),
                        child: sendState.isLoading
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : Text(s.giftsSendButton),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(s.giftsError(e.toString()), style: const TextStyle(color: Colors.white))),
      ),
    );
  }
}

class _GiftsGrid extends StatelessWidget {
  final List<Gift> gifts;
  final Gift? selectedGift;
  final Function(Gift) onSelect;

  const _GiftsGrid({
    required this.gifts,
    required this.selectedGift,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return GridView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.8,
      ),
      itemCount: gifts.length,
      itemBuilder: (context, index) {
        final gift = gifts[index];
        final isSelected = selectedGift?.id == gift.id;

        return GestureDetector(
          onTap: () => onSelect(gift),
          child: Column(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.electricPurple.withValues(alpha: 0.2) : Colors.white10,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected ? AppColors.electricPurple : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: gift.iconUrl != null
                        ? Image.network(gift.iconUrl!, width: 40, height: 40)
                        : const Icon(Icons.card_giftcard, color: Colors.white54, size: 32),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                gift.name,
                style: const TextStyle(color: Colors.white, fontSize: 10),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                s.giftsPriceLabel(gift.price.toInt()),
                style: const TextStyle(color: AppColors.coolCyan, fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        );
      },
    );
  }
}
