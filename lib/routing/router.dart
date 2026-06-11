import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'transitions.dart';
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
import '../ui/feed/widgets/post_detail_screen.dart';
import '../ui/feed/widgets/post_likers_screen.dart';
import '../ui/feed/widgets/video_fullscreen_screen.dart';
import '../ui/home/widgets/home_screen.dart';
import '../ui/home/widgets/for_you_screen.dart';
import '../ui/live_feed/widgets/for_you_live_list_screen.dart';
import '../ui/live_feed/widgets/live_player_screen.dart';
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
import '../ui/wallet/widgets/earnings_screen.dart';
import '../ui/notifications/widgets/notifications_screen.dart';
import '../ui/follows/widgets/follows_screen.dart';
import '../ui/edit_profile/widgets/edit_profile_screen.dart';
import '../ui/explore/widgets/explore_screen.dart';
import '../ui/follows/view_models/follows_view_model.dart';
import '../ui/home/widgets/home_bottom_nav.dart';
import '../ui/creator/widgets/creator_program_intro_screen.dart';
import '../ui/creator/widgets/creator_levels_screen.dart';
import '../ui/creator/widgets/creator_application_form_screen.dart';
import '../ui/creator/widgets/creator_application_submitted_screen.dart';
import '../ui/creator/widgets/creator_application_status_screen.dart';
import '../ui/creator/widgets/creator_onboarding_screen.dart';
import '../ui/creator/widgets/creator_profile_settings_screen.dart';
import '../ui/sounds/widgets/sounds_catalog_screen.dart';
import '../ui/creator/widgets/creator_badge_screen.dart';
import '../ui/creator/widgets/creator_dashboard_screen.dart';
import '../ui/creator/widgets/admin_creator_applications_screen.dart';
import '../ui/creator/widgets/admin_creator_application_detail_screen.dart';
import '../ui/creator/widgets/admin_creators_management_screen.dart';

part 'router.g.dart';

@riverpod
GoRouter router(Ref ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/home',
    refreshListenable: RouterRefreshListenable(ref),
    redirect: (context, state) {
      final isLoading = authState.isLoading;
      final user = authState.asData?.value;
      final isAuth = user != null;
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

      // ── Onboarding obrigatório de avatar ──────────────────────────────
      // Sem foto de perfil o usuário fica preso em /edit-profile. Isso é
      // requisito do gate de Live (e melhora qualidade geral da rede).
      final avatar = user.avatarUrl?.trim() ?? '';
      final needsAvatar = avatar.isEmpty;
      final isOnEditProfile = state.matchedLocation == '/edit-profile';
      final isOnSettings = state.matchedLocation.startsWith('/settings');
      if (needsAvatar && !isOnEditProfile && !isOnSettings) {
        return '/edit-profile';
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
          // Deep link de uma publicação individual.
          // Aceita /post/:id (rota canônica) e /connect/p/:id (legacy/web).
          GoRoute(
            path: '/post/:postId',
            pageBuilder: (context, state) {
              final postId = state.pathParameters['postId'] ?? '';
              return BraweTransitions.fadeUp(
                key: state.pageKey,
                child: PostDetailScreen(postId: postId),
              );
            },
          ),
          GoRoute(
            path: '/post/:postId/likes',
            pageBuilder: (context, state) {
              final postId = state.pathParameters['postId'] ?? '';
              return BraweTransitions.fadeUp(
                key: state.pageKey,
                child: PostLikersScreen(postId: postId),
              );
            },
          ),
          // Deep link de comentários (push de comentário / resposta / menção).
          // Abre o post e exibe automaticamente a folha de comentários,
          // destacando o comentário referenciado (?commentId=...).
          GoRoute(
            path: '/post/:postId/comments',
            pageBuilder: (context, state) {
              final postId = state.pathParameters['postId'] ?? '';
              final commentId = state.uri.queryParameters['commentId'];
              return BraweTransitions.fadeUp(
                key: state.pageKey,
                child: PostDetailScreen(
                  postId: postId,
                  openComments: true,
                  highlightCommentId: commentId,
                ),
              );
            },
          ),
          GoRoute(
            path: '/post/:postId/video',
            pageBuilder: (context, state) {
              final postId = state.pathParameters['postId'] ?? '';
              final initialUrl = state.uri.queryParameters['url'];
              return BraweTransitions.scaleFade(
                key: state.pageKey,
                child: VideoFullscreenScreen(
                  postId: postId,
                  initialUrl: initialUrl,
                ),
              );
            },
          ),
          GoRoute(
            path: '/connect/p/:postId',
            pageBuilder: (context, state) {
              final postId = state.pathParameters['postId'] ?? '';
              return BraweTransitions.fadeUp(
                key: state.pageKey,
                child: PostDetailScreen(postId: postId),
              );
            },
          ),
          GoRoute(
            path: '/live',
            builder: (context, state) =>
                const ForceDarkTheme(child: ForYouLiveListScreen()),
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
            path: '/earnings',
            redirect: (_, __) => kEnableMonetization ? null : '/',
            builder: (context, state) => const EarningsScreen(),
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
            path: '/sounds',
            builder: (context, state) => const SoundsCatalogScreen(),
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
          // ── Brawe Creator Network ─────────────────────────────────
          GoRoute(
            path: '/creator',
            redirect: (_, __) => '/creator/intro',
          ),
          GoRoute(
            path: '/creator/intro',
            builder: (context, state) => const CreatorProgramIntroScreen(),
          ),
          GoRoute(
            path: '/creator/levels',
            builder: (context, state) => const CreatorLevelsScreen(),
          ),
          GoRoute(
            path: '/creator/apply',
            builder: (context, state) =>
                const CreatorApplicationFormScreen(),
          ),
          GoRoute(
            path: '/creator/submitted',
            builder: (context, state) =>
                const CreatorApplicationSubmittedScreen(),
          ),
          GoRoute(
            path: '/creator/status',
            builder: (context, state) =>
                const CreatorApplicationStatusScreen(),
          ),
          GoRoute(
            path: '/creator/onboarding',
            builder: (context, state) => const CreatorOnboardingScreen(),
          ),
          GoRoute(
            path: '/creator/profile-settings',
            builder: (context, state) =>
                const CreatorProfileSettingsScreen(),
          ),
          GoRoute(
            path: '/creator/badge',
            builder: (context, state) => const CreatorBadgeScreen(),
          ),
          GoRoute(
            path: '/creator/dashboard',
            builder: (context, state) => const CreatorDashboardScreen(),
          ),
          // ── Admin ───────────────────────────────────────────────
          GoRoute(
            path: '/admin/creator/applications',
            builder: (context, state) =>
                const AdminCreatorApplicationsScreen(),
          ),
          GoRoute(
            path: '/admin/creator/applications/:id',
            builder: (context, state) =>
                AdminCreatorApplicationDetailScreen(
              id: state.pathParameters['id']!,
            ),
          ),
          GoRoute(
            path: '/admin/creator/creators',
            builder: (context, state) =>
                const AdminCreatorsManagementScreen(),
          ),
        ],
      ),
      // ── Rotas fullscreen (sem HomeBottomNav) ─────────────────────────────
      // Live broadcast e viewer são imersivas fullscreen — sem bottom nav.
      // (A batalha NÃO tem rota própria: é um overlay `ViewerBattleHud` por
      // cima da live no `LivePlayerScreen` — vídeo, chat, rosa e presentes
      // continuam vivos durante a disputa.)
      GoRoute(
        path: '/live/start',
        builder: (context, state) =>
            const ForceDarkTheme(child: StartLiveScreen()),
      ),
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

