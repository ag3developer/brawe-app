import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/themes/app_colors.dart';
import '../../core/ui/app_spacing.dart';
import '../view_models/gift_catalog_view_model.dart';
import '../view_models/send_gift_view_model.dart';
import '../../core/view_models/credits_view_model.dart';
import '../../../domain/models/gift.dart';

class GiftsOverlay extends ConsumerStatefulWidget {
  final String roomId;
  final String streamerId;

  const GiftsOverlay({
    super.key,
    required this.roomId,
    required this.streamerId,
  });

  static void show(BuildContext context, String roomId, String streamerId) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => GiftsOverlay(roomId: roomId, streamerId: streamerId),
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

    final success = await ref.read(sendGiftViewModelProvider.notifier).sendGift(
      roomId: widget.roomId,
      giftId: _selectedGift!.id,
    );

    if (success && mounted) {
      ref.read(creditsViewModelProvider.notifier).refresh();
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sent ${_selectedGift!.name}!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
                    const Text(
                      'Send a Gift',
                      style: TextStyle(
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
                    ? const Center(child: Text('No gifts available', style: TextStyle(color: Colors.white54)))
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
                            '${balanceState.value?.toInt() ?? 0} Credits',
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
                            : const Text('SEND'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error loading gifts: $e', style: const TextStyle(color: Colors.white))),
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
                '${gift.price.toInt()} pts',
                style: const TextStyle(color: AppColors.coolCyan, fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        );
      },
    );
  }
}
