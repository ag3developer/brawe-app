import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/repositories/auth_state_provider.dart';
import '../ui/auth/widgets/login_screen.dart';
import '../ui/auth/widgets/signup_screen.dart';
import '../ui/auth/widgets/welcome_screen.dart';
import '../ui/feed/widgets/feed_screen.dart';
import '../ui/home/widgets/home_screen.dart';
import '../ui/home/widgets/for_you_screen.dart';
import '../ui/live_feed/widgets/for_you_live_list_screen.dart';
import '../ui/live_feed/widgets/live_player_screen.dart';
import '../ui/chat/widgets/chat_list_screen.dart';
import '../ui/chat/widgets/chat_detail_screen.dart';
import '../ui/broadcaster/widgets/start_live_screen.dart';
import '../ui/broadcaster/widgets/broadcaster_screen.dart';
import '../ui/profile/widgets/profile_screen.dart';
import '../ui/settings/widgets/settings_screen.dart';
import '../ui/quests/widgets/quests_screen.dart';
import '../ui/wallet/widgets/wallet_screen.dart';
import '../ui/notifications/widgets/notifications_screen.dart';
import '../ui/follows/widgets/follows_screen.dart';
import '../ui/edit_profile/widgets/edit_profile_screen.dart';
import '../ui/explore/widgets/explore_screen.dart';
import '../ui/follows/view_models/follows_view_model.dart';
import '../domain/models/live_room.dart';

part 'router.g.dart';

@riverpod
GoRouter router(Ref ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/home',
    refreshListenable: RouterRefreshListenable(ref),
    redirect: (context, state) {
      final isLoading = authState.isLoading;
      final isAuth = authState.asData?.value != null;
      final isLoggingIn =
          state.matchedLocation == '/login' ||
          state.matchedLocation == '/signup' ||
          state.matchedLocation == '/welcome';

      if (isLoading) return null;

      if (!isAuth) {
        return isLoggingIn ? null : '/welcome';
      }

      if (isLoggingIn) {
        return '/home';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/welcome',
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(path: '/feed', builder: (context, state) => const FeedScreen()),
      GoRoute(
        path: '/live',
        builder: (context, state) => const ForYouLiveListScreen(),
      ),
      GoRoute(
        path: '/live/:roomId',
        builder: (context, state) {
          final room = state.extra as LiveRoom?;
          if (room == null) {
            return const Scaffold(
              body: Center(child: Text('Room not found.')),
            );
          }
          return LivePlayerScreen(room: room);
        },
      ),
      GoRoute(
        path: '/live/start',
        builder: (context, state) => const StartLiveScreen(),
      ),
      GoRoute(
        path: '/live/broadcast',
        builder: (context, state) {
          final room = state.extra as LiveRoom?;
          if (room == null) {
            return const Scaffold(
              body: Center(child: Text('Room not found.')),
            );
          }
          return BroadcasterScreen(room: room);
        },
      ),
      GoRoute(path: '/home', builder: (context, state) => const ForYouScreen()),
      GoRoute(
        path: '/home/classic',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/chat',
        builder: (context, state) => const ChatListScreen(),
      ),
      GoRoute(
        path: '/chat/:conversationId',
        builder: (context, state) {
          final conversationId = state.pathParameters['conversationId']!;
          final extra = state.extra as Map<String, dynamic>?;
          return ChatDetailScreen(
            conversationId: conversationId,
            participantName: extra?['participantName'] as String? ?? 'Chat',
            participantAvatarUrl: extra?['participantAvatarUrl'] as String?,
            participantId: extra?['participantId'] as String?,
          );
        },
      ),
      GoRoute(
        // Aceita UUID, username ou @username — o backend resolve em /profile/{slug}.
        path: '/profile/:userId',
        builder: (context, state) {
          var userId = state.pathParameters['userId']!;
          if (userId.startsWith('@')) {
            userId = userId.substring(1);
          }
          return ProfileScreen(userId: userId);
        },
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/quests',
        builder: (context, state) => const QuestsScreen(),
      ),
      GoRoute(
        path: '/wallet',
        builder: (context, state) => const WalletScreen(),
      ),
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: '/edit-profile',
        builder: (context, state) => const EditProfileScreen(),
      ),
      GoRoute(
        path: '/explore',
        builder: (context, state) => const ExploreScreen(),
      ),
      GoRoute(
        path: '/follows/:userId',
        builder: (context, state) {
          final userId = state.pathParameters['userId']!;
          final tabParam = state.uri.queryParameters['tab'];
          final tab = tabParam == 'following'
              ? FollowsTab.following
              : FollowsTab.followers;
          return FollowsScreen(userId: userId, initialTab: tab);
        },
      ),
    ],
  );
}

class RouterRefreshListenable extends ChangeNotifier {
  RouterRefreshListenable(Ref ref) {
    _subscription = ref.listen(
      authStateProvider,
      (previous, next) => notifyListeners(),
    );
  }

  late final ProviderSubscription _subscription;

  @override
  void dispose() {
    _subscription.close();
    super.dispose();
  }
}
