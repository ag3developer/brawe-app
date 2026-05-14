import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/models/feed_item.dart';
import '../../core/themes/app_colors.dart';
import '../view_models/for_you_feed_view_model.dart';
import 'home_bottom_nav.dart';
import 'views/live_commerce_view.dart';
import 'views/live_battle_view.dart';
import 'views/live_chat_view.dart';
import 'views/video_view.dart';
import 'views/photo_post_view.dart';

/// 🏠 Tela inicial inteligente — For You feed em PageView vertical.
/// Renderiza UI diferente para cada tipo de FeedItem.
class ForYouScreen extends ConsumerStatefulWidget {
  const ForYouScreen({super.key});

  @override
  ConsumerState<ForYouScreen> createState() => _ForYouScreenState();
}

class _ForYouScreenState extends ConsumerState<ForYouScreen> {
  final _ctrl = PageController();
  String _tab = 'forYou';

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Widget _buildView(FeedItem item) {
    return switch (item) {
      LiveCommerceItem() => LiveCommerceView(item: item),
      LiveBattleItem() => LiveBattleView(item: item),
      LiveChatItem() => LiveChatView(item: item),
      VideoFeedItem() => VideoView(item: item),
      PhotoPostFeedItem() => PhotoPostView(item: item),
    };
  }

  @override
  Widget build(BuildContext context) {
    final asyncItems = ref.watch(forYouFeedViewModelProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          asyncItems.when(
            loading: () => const Center(
              child: CircularProgressIndicator(
                color: AppColors.electricPurple,
              ),
            ),
            error: (_, __) => Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.wifi_off,
                        color: Colors.white54, size: 48),
                    const SizedBox(height: 12),
                    const Text(
                      'Não foi possível carregar o feed.',
                      style: TextStyle(color: Colors.white70),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: () => ref
                          .read(forYouFeedViewModelProvider.notifier)
                          .refresh(),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Tentar novamente'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.electricPurple,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            data: (items) {
              if (items.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.play_circle_outline,
                            color: Colors.white24, size: 64),
                        const SizedBox(height: 16),
                        const Text(
                          'Nenhum vídeo ou foto por aqui ainda.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                              fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Siga creators ou volte mais tarde.\nPosts de texto estão na aba Feed.',
                          textAlign: TextAlign.center,
                          style:
                              TextStyle(color: Colors.white38, fontSize: 13),
                        ),
                        const SizedBox(height: 24),
                        TextButton.icon(
                          onPressed: () => ref
                              .read(forYouFeedViewModelProvider.notifier)
                              .refresh(),
                          icon: const Icon(Icons.refresh,
                              color: AppColors.electricPurple),
                          label: const Text('Atualizar',
                              style: TextStyle(
                                  color: AppColors.electricPurple)),
                        ),
                      ],
                    ),
                  ),
                );
              }
              return RefreshIndicator(
                color: AppColors.electricPurple,
                onRefresh: () => ref
                    .read(forYouFeedViewModelProvider.notifier)
                    .refresh(),
                child: PageView.builder(
                  controller: _ctrl,
                  scrollDirection: Axis.vertical,
                  itemCount: items.length,
                  itemBuilder: (_, i) => _buildView(items[i]),
                ),
              );
            },
          ),

          // Top bar: Following | For You + search
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  const Spacer(),
                  _TopTab(
                    label: 'Seguindo',
                    selected: _tab == 'following',
                    onTap: () => setState(() => _tab = 'following'),
                  ),
                  const SizedBox(width: 18),
                  _TopTab(
                    label: 'Para Você',
                    selected: _tab == 'forYou',
                    onTap: () => setState(() => _tab = 'forYou'),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.search, color: Colors.white),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ),

          // Bottom nav
          const Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: HomeBottomNav(),
          ),
        ],
      ),
    );
  }
}

class _TopTab extends StatelessWidget {
  const _TopTab({
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : Colors.white60,
              fontSize: 16,
              fontWeight: selected ? FontWeight.bold : FontWeight.w500,
              shadows: const [Shadow(color: Colors.black54, blurRadius: 6)],
            ),
          ),
          const SizedBox(height: 4),
          Container(
            width: 24,
            height: 3,
            decoration: BoxDecoration(
              color: selected ? AppColors.electricPurple : Colors.transparent,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }
}
