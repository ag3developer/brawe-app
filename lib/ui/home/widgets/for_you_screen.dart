import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/feature_flags.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/services/socket_service.dart';
import '../../../domain/models/feed_item.dart';
import '../../../gen/l10n/app_localizations.dart';
import '../../core/themes/app_colors.dart';
import '../view_models/for_you_feed_view_model.dart';
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

class _ForYouScreenState extends ConsumerState<ForYouScreen>
    with WidgetsBindingObserver {
  final _ctrl = PageController();
  String _tab = 'forYou';
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Escuta live_ended via socket — invalida o feed imediatamente quando
    // uma live encerra, sem esperar o timer de 30s.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final socket = ref.read(socketServiceProvider);
      socket.on(AppConstants.eventLiveEnded, _onLiveEnded);
    });
  }

  void _onLiveEnded(dynamic _) {
    // Live encerrou — refresh silencioso remove a live do feed sem flicker
    ref.read(forYouFeedViewModelProvider.notifier).refresh(silent: true);
    ref
        .read(followingForYouFeedViewModelProvider.notifier)
        .refresh(silent: true);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshLive();
    }
  }

  void _refreshLive() {
    ref.read(forYouFeedViewModelProvider.notifier).refresh();
    ref.read(followingForYouFeedViewModelProvider.notifier).refresh();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _ctrl.dispose();
    super.dispose();
  }

  Widget _buildView(FeedItem item, bool isActive) {
    return switch (item) {
      // v1.0: monetização desativada — lives de commerce renderizam
      // como live-chat comum (sem botão de compra/produtos).
      LiveCommerceItem() =>
        kEnableMonetization
            ? LiveCommerceView(item: item, isActive: isActive)
            : LiveChatView(
                isActive: isActive,
                item: LiveChatItem(
                  id: item.id,
                  author: item.author,
                  likesCount: item.likesCount,
                  commentsCount: item.commentsCount,
                  sharesCount: item.sharesCount,
                  userLiked: item.userLiked,
                  userFollowingAuthor: item.userFollowingAuthor,
                  caption: item.caption,
                  thumbnailUrl: item.thumbnailUrl,
                  viewerCount: item.viewerCount,
                  topic: '',
                ),
              ),
      LiveBattleItem() => LiveBattleView(item: item),
      LiveChatItem() => LiveChatView(item: item, isActive: isActive),
      VideoFeedItem() => VideoView(item: item, isActive: isActive),
      PhotoPostFeedItem() => PhotoPostView(item: item),
    };
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final isFollowing = _tab == 'following';
    final asyncItems = isFollowing
        ? ref.watch(followingForYouFeedViewModelProvider)
        : ref.watch(forYouFeedViewModelProvider);

    void onRefresh() => isFollowing
        ? ref.read(followingForYouFeedViewModelProvider.notifier).refresh()
        : ref.read(forYouFeedViewModelProvider.notifier).refresh();

    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          asyncItems.when(
            loading: () => const Center(
              child: CircularProgressIndicator(color: AppColors.electricPurple),
            ),
            error: (_, __) => Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.wifi_off, color: Colors.white54, size: 48),
                    const SizedBox(height: 12),
                    Text(
                      s.feedLoadError,
                      style: const TextStyle(color: Colors.white70),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: onRefresh,
                      icon: const Icon(Icons.refresh),
                      label: Text(s.actionRetry),
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
                        const Icon(
                          Icons.play_circle_outline,
                          color: Colors.white24,
                          size: 64,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          s.feedEmptyVideoTitle,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          s.feedEmptyVideoSubtitle,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white38,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 24),
                        TextButton.icon(
                          onPressed: onRefresh,
                          icon: const Icon(
                            Icons.refresh,
                            color: AppColors.electricPurple,
                          ),
                          label: Text(
                            s.actionRefresh,
                            style: const TextStyle(
                              color: AppColors.electricPurple,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
              return RefreshIndicator(
                color: AppColors.electricPurple,
                onRefresh: () async => onRefresh(),
                child: PageView.builder(
                  controller: _ctrl,
                  scrollDirection: Axis.vertical,
                  itemCount: items.length,
                  onPageChanged: (i) => setState(() => _currentIndex = i),
                  itemBuilder: (_, i) =>
                      _buildView(items[i], i == _currentIndex),
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
                    label: s.tabFollowing,
                    selected: _tab == 'following',
                    onTap: () => setState(() => _tab = 'following'),
                  ),
                  const SizedBox(width: 18),
                  _TopTab(
                    label: s.tabForYou,
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

          // Bottom nav — agora gerenciado pelo ShellRoute em router.dart
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
