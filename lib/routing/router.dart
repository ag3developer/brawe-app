import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../config/feature_flags.dart';
import '../data/repositories/auth_state_provider.dart';
import '../data/repositories/live_repository.dart';
import '../domain/models/live_room.dart';
import '../ui/auth/widgets/login_screen.dart';
import '../ui/auth/widgets/signup_screen.dart';
import '../ui/auth/widgets/welcome_screen.dart';
import '../ui/auth/widgets/forgot_password_screen.dart';
import '../ui/auth/widgets/reset_password_screen.dart';
import '../ui/settings/widgets/change_password_screen.dart';
import '../ui/settings/widgets/delete_account_screen.dart';
import '../ui/feed/widgets/feed_screen.dart';
import '../ui/home/widgets/home_screen.dart';
import '../ui/home/widgets/for_you_screen.dart';
import '../ui/live_feed/widgets/for_you_live_list_screen.dart';
import '../ui/live_feed/widgets/live_player_screen.dart';
import '../ui/live_feed/widgets/viewer_battle_screen.dart';
import '../ui/chat/widgets/chat_list_screen.dart';
import '../ui/chat/widgets/chat_detail_screen.dart';
import '../ui/chat/widgets/new_conversation_screen.dart';
import '../ui/broadcaster/widgets/start_live_screen.dart';
import '../ui/broadcaster/widgets/broadcaster_screen.dart';
import '../ui/core/themes/force_dark_theme.dart';
import '../ui/profile/widgets/profile_screen.dart';
import '../ui/settings/widgets/settings_screen.dart';
import '../ui/quests/widgets/quests_screen.dart';
import '../ui/wallet/widgets/wallet_screen.dart';
import '../ui/notifications/widgets/notifications_screen.dart';
import '../ui/follows/widgets/follows_screen.dart';
import '../ui/edit_profile/widgets/edit_profile_screen.dart';
import '../ui/explore/widgets/explore_screen.dart';
import '../ui/follows/view_models/follows_view_model.dart';
import '../ui/home/widgets/home_bottom_nav.dart';

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
          state.matchedLocation == '/welcome' ||
          state.matchedLocation == '/forgot-password' ||
          state.matchedLocation.startsWith('/reset-password');

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
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/reset-password',
        builder: (context, state) {
          final token = state.uri.queryParameters['token'] ?? '';
          return ResetPasswordScreen(token: token);
        },
      ),
      // ── Shell: rotas com HomeBottomNav global ────────────────────────────
      //
      // Usamos Scaffold + bottomNavigationBar (em vez de Stack+Positioned)
      // para que o nav reserve altura real. Assim:
      //  • Conteúdo das telas não fica atrás do nav.
      //  • FABs dos Scaffolds internos flutuam logo acima do nav.
      //  • SafeArea funciona corretamente.
      ShellRoute(
        builder: (context, state, child) => Scaffold(
          backgroundColor: Colors.transparent,
          extendBody: false,
          resizeToAvoidBottomInset: false,
          body: child,
          bottomNavigationBar: const HomeBottomNav(),
        ),
        routes: [
          // Telas imersivas de mídia continuam dark-fixo (padrão TikTok/IG).
          GoRoute(
            path: '/home',
            builder: (context, state) =>
                const ForceDarkTheme(child: ForYouScreen()),
          ),
          GoRoute(
            path: '/home/classic',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: '/feed',
            builder: (context, state) => const FeedScreen(),
          ),
          GoRoute(
            path: '/live',
            builder: (context, state) =>
                const ForceDarkTheme(child: ForYouLiveListScreen()),
          ),
          // /live/start fica dentro do shell (tem bottom nav — tela de setup).
          GoRoute(
            path: '/live/start',
            builder: (context, state) =>
                const ForceDarkTheme(child: StartLiveScreen()),
          ),
          GoRoute(
            path: '/chat',
            builder: (context, state) => const ChatListScreen(),
          ),
          GoRoute(
            path: '/chat/new',
            builder: (context, state) => const NewConversationScreen(),
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
            path: '/settings/change-password',
            builder: (context, state) => const ChangePasswordScreen(),
          ),
          GoRoute(
            path: '/settings/delete-account',
            builder: (context, state) => const DeleteAccountScreen(),
          ),
          GoRoute(
            path: '/quests',
            builder: (context, state) => const QuestsScreen(),
          ),
          GoRoute(
            path: '/wallet',
            redirect: (_, __) => kEnableMonetization ? null : '/',
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
      ),
      // ── Rotas fullscreen (sem HomeBottomNav) ─────────────────────────────
      // Live broadcast, viewer e battle são imersivas fullscreen — sem bottom nav.
      GoRoute(
        path: '/live/broadcast',
        builder: (context, state) {
          final extraRoom = state.extra as LiveRoom?;
          final roomId = state.uri.queryParameters['roomId'];
          if (extraRoom != null) {
            return ForceDarkTheme(child: BroadcasterScreen(room: extraRoom));
          }
          if (roomId != null && roomId.isNotEmpty) {
            return ForceDarkTheme(
              child: _LiveRoomResolver(
                roomId: roomId,
                builder: (room) => BroadcasterScreen(room: room),
              ),
            );
          }
          return const ForceDarkTheme(child: StartLiveScreen());
        },
      ),
      GoRoute(
        path: '/live/battle/:battleId',
        builder: (context, state) {
          final battleId = state.pathParameters['battleId'] ?? '';
          return ForceDarkTheme(
            child: ViewerBattleScreen(battleId: battleId),
          );
        },
      ),
      GoRoute(
        path: '/live/:roomId',
        builder: (context, state) {
          final extraRoom = state.extra as LiveRoom?;
          final roomId = state.pathParameters['roomId'] ?? '';
          const reserved = {'start', 'broadcast', 'new', 'create'};
          if (reserved.contains(roomId.toLowerCase())) {
            return const ForceDarkTheme(child: StartLiveScreen());
          }
          if (extraRoom != null) {
            return ForceDarkTheme(child: LivePlayerScreen(room: extraRoom));
          }
          return ForceDarkTheme(
            child: _LiveRoomResolver(
              roomId: roomId,
              builder: (room) => LivePlayerScreen(room: room),
            ),
          );
        },
      ),
      // A tela de conversa aberta é imersiva — nada de bottom nav atrapalhando.
      // Usa CupertinoPage para habilitar o swipe-back nativo do iOS.
      GoRoute(
        path: '/chat/:conversationId',
        pageBuilder: (context, state) {
          final conversationId = state.pathParameters['conversationId']!;
          final extra = state.extra as Map<String, dynamic>?;
          return CupertinoPage(
            key: state.pageKey,
            child: ChatDetailScreen(
              conversationId: conversationId,
              participantName: extra?['participantName'] as String? ?? 'Chat',
              participantAvatarUrl: extra?['participantAvatarUrl'] as String?,
              participantId: extra?['participantId'] as String?,
            ),
          );
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


/// Helper que resolve um LiveRoom a partir do ID/slug quando o `extra` é null
/// (deep links, push notifications ou navegação simples por
/// `context.push('/live/<id>')`).
class _LiveRoomResolver extends ConsumerStatefulWidget {
  const _LiveRoomResolver({required this.roomId, required this.builder});

  final String roomId;
  final Widget Function(LiveRoom room) builder;

  @override
  ConsumerState<_LiveRoomResolver> createState() => _LiveRoomResolverState();
}

class _LiveRoomResolverState extends ConsumerState<_LiveRoomResolver> {
  late Future<LiveRoom?> _future;

  @override
  void initState() {
    super.initState();
    _future = _fetch();
  }

  Future<LiveRoom?> _fetch() {
    return ref.read(liveRepositoryProvider).getRoom(widget.roomId);
  }

  void _retry() {
    setState(() => _future = _fetch());
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<LiveRoom?>(
      future: _future,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Colors.black,
            body: Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
          );
        }
        final room = snap.data;
        if (snap.hasError || room == null) {
          return Scaffold(
            backgroundColor: Colors.black,
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.live_tv_outlined,
                        color: Colors.white54, size: 64),
                    const SizedBox(height: 16),
                    const Text(
                      'Live indisponível',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Essa transmissão terminou ou ainda não começou.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        OutlinedButton(
                          onPressed: () => Navigator.of(context).maybePop(),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: BorderSide(
                                color: Colors.white.withValues(alpha: 0.3)),
                          ),
                          child: const Text('Voltar'),
                        ),
                        const SizedBox(width: 12),
                        FilledButton(
                          onPressed: _retry,
                          child: const Text('Tentar de novo'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        }
        return widget.builder(room);
      },
    );
  }
}

