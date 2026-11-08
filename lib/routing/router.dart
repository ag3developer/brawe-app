import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../ui/feed/widgets/video_upload_pill.dart';

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
import '../ui/settings/widgets/security_screen.dart';
import '../ui/settings/widgets/account_suspended_screen.dart';
import '../core/network/account_suspension.dart';
import '../ui/settings/widgets/delete_account_screen.dart';
import '../ui/feed/widgets/feed_screen.dart';
import '../ui/feed/widgets/post_detail_screen.dart';
import '../ui/feed/widgets/post_likers_screen.dart';
import '../ui/feed/widgets/video_fullscreen_screen.dart';
import '../ui/home/widgets/for_you_screen.dart';
import '../ui/live_feed/widgets/for_you_live_list_screen.dart';
import '../ui/live_feed/widgets/own_live_gate.dart';
import '../ui/chat/widgets/chat_list_screen.dart';
import '../ui/chat/widgets/chat_detail_screen.dart';
import '../ui/chat/widgets/new_conversation_screen.dart';
import '../ui/broadcaster/widgets/start_live_screen.dart';
import '../ui/broadcaster/widgets/broadcaster_screen.dart';
import '../ui/broadcaster/widgets/live_summary_screen.dart';
import '../ui/core/themes/force_dark_theme.dart';
import '../ui/profile/widgets/profile_screen.dart';
import '../ui/settings/widgets/settings_screen.dart';
import '../ui/quests/widgets/quests_screen.dart';
import '../ui/live/shared/widgets/gifter_level/gifter_level_screen.dart';
import '../ui/edit_profile/widgets/artist_profile_screen.dart';
import '../ui/edit_profile/widgets/business_profile_screen.dart';
import '../ui/wallet/widgets/wallet_screen.dart';
import '../ui/wallet/widgets/earnings_screen.dart';
import '../ui/notifications/widgets/new_followers_screen.dart';
import '../ui/notifications/widgets/notifications_screen.dart';
import '../ui/find_friends/widgets/find_friends_screen.dart';
import '../ui/find_friends/widgets/qr_scanner_screen.dart';
import '../ui/follows/widgets/follows_screen.dart';
import '../ui/edit_profile/widgets/edit_profile_screen.dart';
import '../ui/explore/widgets/explore_screen.dart';
import '../ui/explore/widgets/hashtag_results_screen.dart';
import '../ui/follows/view_models/follows_view_model.dart';
import '../ui/home/widgets/home_bottom_nav.dart';
import '../ui/creator/widgets/creator_analytics_hub_screen.dart';
import '../ui/creator/widgets/creator_program_intro_screen.dart';
import '../ui/creator/widgets/creator_levels_screen.dart';
import '../ui/creator/widgets/creator_application_form_screen.dart';
import '../ui/creator/widgets/creator_application_submitted_screen.dart';
import '../ui/creator/widgets/creator_application_status_screen.dart';
import '../ui/creator/widgets/creator_onboarding_screen.dart';
import '../ui/sounds/widgets/sounds_catalog_screen.dart';
import '../ui/creator/widgets/creator_badge_screen.dart';
import '../ui/creator/widgets/creator_dashboard_screen.dart';
import '../ui/creator/widgets/agency/agency_invite_screen.dart';
import '../ui/creator/widgets/admin_creator_applications_screen.dart';
import '../ui/creator/widgets/admin_creator_application_detail_screen.dart';
import '../ui/creator/widgets/admin_creators_management_screen.dart';
import '../ui/shop/pages/shop_product_page.dart';
import '../ui/shop/pages/shop_store_page.dart';
import '../ui/shop/pages/shop_vitrine_page.dart';
import '../ui/shop/pages/shop_cart_page.dart';
import '../ui/shop/pages/shop_checkout_page.dart';
import '../ui/shop/pages/shop_payment_page.dart';
import '../ui/onboarding/onboarding_gate.dart';
import '../ui/onboarding/onboarding_screen.dart';
import '../data/services/profile_service.dart';
import '../ui/account/about_you_screen.dart';
import '../ui/account/account_type_screen.dart';
import '../ui/account/verify_account_screen.dart';
import '../ui/account/verify_business_screen.dart';
import '../ui/account/verify_identity_screen.dart';
import '../ui/ads/boost/boost_flow_screen.dart';
import '../ui/ads/boost/boost_preview.dart';
import '../ui/ads/boost/my_ads_screen.dart';

part 'router.g.dart';

/// Idiomas suportados pelo site Next.js (prefixo de locale nas URLs
/// públicas, ex.: `brawe.app/pt/connect/...`). Mantido em paralelo aos
/// `.arb` do app (`pt`, `es`, `en`) — usado só para stripar o prefixo de
/// deep links recebidos, não define o idioma do app em si.
const _kWebLocales = {'pt', 'es', 'en'};

/// Primeiro segmento das páginas da rede social no endereço curto do site
/// (`brawe.app/pt/u/:id` = `brawe.app/pt/connect/u/:id`).
const _kConnectShortSegments = {
  'u',
  'p',
  'profile',
  'foryou',
  'explore',
  'lives',
  'live',
  'messages',
  'notifications',
  'settings',
  'wallet',
  'quests',
  'battles',
  'coins',
  'saved',
  'following',
  'followers',
  'favorites',
  'analytics',
  'shopping',
  'go-live',
  'help',
  'mystery-gifts',
  'shop',
  'search',
  'ranking',
};

/// Páginas do site (já sem o prefixo de idioma) → rota equivalente no app.
const _kWebPathAliases = {
  '/': '/home',
  '/connect': '/home',
  '/connect/foryou': '/home',
  '/connect/lives': '/live',
  '/connect/explore': '/explore',
  '/connect/search': '/explore',
  '/connect/ranking': '/explore',
  '/connect/messages': '/chat',
  '/connect/notifications': '/notifications',
  '/connect/quests': '/quests',
  '/connect/settings': '/settings',
  '/connect/profile': '/edit-profile',
};

/// Normaliza um deep link (Universal Link/App Link) recebido de fora do
/// app para uma rota conhecida pelo `GoRouter`, ou retorna `null` se a
/// localização já é válida/não precisa de tradução.
///
/// Cobre dois casos que o AASA (`paths: ["*"]`) deixa passar direto para
/// o app, mas que não existem como rota nativa:
/// 1. Prefixo de idioma do site (`/pt/...`, `/es/...`, `/en/...`).
/// 2. Rota interna do site `/connect/profile/:id` (usada em links DENTRO
///    do Next.js), diferente da rota canônica de compartilhamento
///    `/connect/u/:id` (única que o `GoRoute` abaixo reconhece).
String? _normalizeDeepLink(Uri uri) {
  var path = uri.path;

  // 1) Remove prefixo de locale: "/pt/connect/..." → "/connect/...".
  //    Endereço curto do site (padrão das grandes redes): "/pt/u/:id",
  //    "/pt/p/:id", "/pt/foryou"… → mesma página com "/connect" na frente.
  final segments = uri.pathSegments;
  if (segments.isNotEmpty && _kWebLocales.contains(segments.first)) {
    path = '/${segments.skip(1).join('/')}';
    if (segments.length == 1) {
      path = '/connect';
    } else if (_kConnectShortSegments.contains(segments[1])) {
      path = '/connect$path';
    }
  }

  // 2) Alias interno do site → rota canônica de perfil do app.
  //    "/connect/profile/:id" → "/connect/u/:id" (mesmo GoRoute de
  //    `/connect/u/:userId`, que resolve para ProfileScreen).
  const profileAlias = '/connect/profile/';
  if (path.startsWith(profileAlias)) {
    final id = path.substring(profileAlias.length);
    path = '/connect/u/$id';
  }

  // 3) Live compartilhada pelo site: "/connect/live/:slug" → "/live/:slug"
  //    (o `_LiveRoomResolver` aceita id ou slug). Os presentes misteriosos
  //    acontecem dentro da live, então "/connect/mystery-gifts/:slug" também.
  for (final liveAlias in const ['/connect/live/', '/connect/mystery-gifts/']) {
    if (path.startsWith(liveAlias) && path.length > liveAlias.length) {
      path = '/live/${path.substring(liveAlias.length)}';
    }
  }

  // 3b) Página da marca no site: "/connect/shop/:slug" → loja nativa.
  const shopAlias = '/connect/shop/';
  if (path.startsWith(shopAlias) && path.length > shopAlias.length) {
    path = '/shop/store/${path.substring(shopAlias.length)}';
  } else if (path == '/connect/shopping' || path == '/connect/shop') {
    path = '/home';
  }

  // 3c) Busca do site com hashtag ("/connect/search?q=%23moda") → tela da
  //     hashtag no app; as demais buscas abrem o Explorar (alias abaixo).
  if (path == '/connect/search') {
    final q = (uri.queryParameters['q'] ?? '').trim();
    final tag = RegExp(
      r'^#([\p{L}\p{N}_]+)$',
      unicode: true,
    ).firstMatch(q)?.group(1);
    if (tag != null) {
      return '/explore/hashtag/${Uri.encodeComponent(tag)}';
    }
  }

  // 4) Formas `brawe://` do backend (`link_url` das notificações) que não
  //    são rotas: "brawe://user/:id" → perfil; "brawe://gifts[/:id]" → carteira.
  if (path.startsWith('/user/')) {
    path = '/profile/${path.substring('/user/'.length)}';
  } else if (path == '/gifts' || path.startsWith('/gifts/')) {
    path = '/wallet';
  }

  // 5) Demais páginas do site que têm equivalente no app; o resto cai no
  //    `onException` do GoRouter, que manda para /home.
  path = _kWebPathAliases[path] ?? path;

  if (path == uri.path) {
    return null; // nada mudou — deixa o redirect normal seguir
  }
  final query = uri.query.isNotEmpty ? '?${uri.query}' : '';
  return '$path$query';
}

/// Destino aberto antes do login (deep link), consumido logo após entrar.
String? _pendingAuthLocation;

bool _isSharedContentPath(String path) =>
    (path.startsWith('/live/') &&
        !const {
          '/live/start',
          '/live/summary',
          '/live/broadcast',
        }.contains(path)) ||
    path.startsWith('/post/') ||
    path.startsWith('/profile/') ||
    path.startsWith('/connect/') ||
    path.startsWith('/explore/hashtag/') ||
    path.startsWith('/shop/product/') ||
    path.startsWith('/shop/store/');

@riverpod
GoRouter router(Ref ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/home',
    refreshListenable: RouterRefreshListenable(ref),
    // Link do site sem tela equivalente no app (loja, marketplace…): abre o
    // início em vez da tela "Page Not Found".
    onException: (_, state, router) {
      debugPrint('Router: rota desconhecida ${state.uri} → /home');
      router.go('/home');
    },
    redirect: (context, state) {
      // ── Normalização de Universal Links (iOS) / App Links (Android) ────
      // O AASA/assetlinks está configurado com "paths": ["*"] — o app
      // intercepta QUALQUER link de brawe.app, incluindo URLs que só
      // existem no site Next.js (prefixo de idioma `/pt|es|en/...` e a
      // rota interna `/connect/profile/:id`, usada nos links de dentro do
      // próprio site, diferente do link canônico de compartilhamento
      // `/connect/u/:id`). Sem essa normalização, abrir um link de perfil
      // com o app instalado cai em `GoException: no routes for location`
      // (tela de erro em branco) em vez de abrir o perfil.
      final normalized = _normalizeDeepLink(state.uri);
      if (normalized != null) return normalized;

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
        // Guarda o link aberto (ex.: live recebida no WhatsApp) para abrir
        // depois do login, em vez de perder o destino e cair no início.
        // Só links de conteúdo: no logout, a tela atual (ex.: /settings) não
        // deve virar destino do próximo login.
        if (!isLoggingIn && _isSharedContentPath(state.uri.path)) {
          _pendingAuthLocation = state.uri.toString();
        }
        return isLoggingIn ? null : '/welcome';
      }

      // ── Conta suspensa pela moderação ─────────────────────────────────
      // O interceptor do Dio liga `AccountSuspension` ao receber 403
      // `account_suspended`; enquanto durar, o usuário só vê /suspended.
      final suspended = AccountSuspension.instance.value != null;
      final onSuspended = state.matchedLocation == '/suspended';
      if (suspended && !onSuspended) return '/suspended';
      if (!suspended && onSuspended) return '/home';

      if (isLoggingIn) {
        final pending = _pendingAuthLocation;
        _pendingAuthLocation = null;
        return pending ?? '/home';
      }

      // ── Cadastro em passos (onboarding) ───────────────────────────────
      // Falta data de nascimento (18+), @ ou foto → /onboarding, que mostra
      // só os passos que faltam e termina no Feed. Contas antigas sem esses
      // dados passam por ele uma única vez.
      final onOnboarding = state.matchedLocation == '/onboarding';
      if (onOnboarding) return null;
      final gate = OnboardingGate.instance;
      gate.ensureFor(
        user.id,
        () => ref.read(profileServiceProvider).getMyProfile(),
      );
      final needsAvatar = (user.avatarUrl?.trim() ?? '').isEmpty;
      if (needsAvatar || (gate.value?.blocking ?? false)) {
        return '/onboarding';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/welcome',
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      // Conta: tipo de conta e verificação (tela cheia).
      GoRoute(path: '/account/type', builder: (context, state) => const AccountTypeScreen()),
      GoRoute(path: '/account/about', builder: (context, state) => const AboutYouScreen()),
      GoRoute(path: '/account/verify', builder: (context, state) => const VerifyAccountScreen()),
      GoRoute(path: '/account/verify/identity', builder: (context, state) => const VerifyIdentityScreen()),
      GoRoute(path: '/account/verify/business', builder: (context, state) => const VerifyBusinessScreen()),
      // Anúncios (impulsionar e Meus anúncios): tela cheia, sem o menu de baixo.
      GoRoute(
        path: '/ads/boost',
        builder: (context, state) => BoostFlowScreen(
          contentType: state.uri.queryParameters['type'] ?? 'post',
          contentId: state.uri.queryParameters['id'] ?? '',
          preview: state.extra is BoostPreviewData
              ? state.extra as BoostPreviewData
              : null,
        ),
      ),
      GoRoute(
        path: '/ads/campaigns',
        builder: (context, state) => const MyAdsScreen(),
      ),
      GoRoute(
        path: '/ads/campaigns/:id',
        builder: (context, state) =>
            MyAdDetailScreen(id: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/suspended',
        builder: (context, state) => const AccountSuspendedScreen(),
      ),
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
        // Voltar do Android: as abas (feed, live, chat, perfil) são abertas
        // com `context.go`, então ficam sozinhas na pilha — sem isto o
        // voltar FECHAVA o app em qualquer aba. Agora, fora da Home, o
        // voltar leva para /home; na Home, sai do app como de costume.
        // Telas empilhadas com `push` dentro do shell são desempilhadas
        // antes (o go_router consulta o navigator interno primeiro).
        // No iOS não há botão voltar do sistema → sem efeito.
        builder: (context, state, child) => PopScope(
          canPop:
              defaultTargetPlatform != TargetPlatform.android ||
              state.uri.path == '/home',
          onPopInvokedWithResult: (didPop, _) {
            if (didPop) return;
            context.go('/home');
          },
          child: Scaffold(
            backgroundColor: Colors.transparent,
            extendBody: false,
            resizeToAvoidBottomInset: false,
            body: Stack(
              children: [
                child,
                // Progresso global do envio de vídeo (sobrevive às abas).
                const Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: VideoUploadPill(),
                ),
              ],
            ),
            bottomNavigationBar: const HomeBottomNav(),
          ),
        ),
        routes: [
          // Telas imersivas de mídia continuam dark-fixo (padrão TikTok/IG).
          GoRoute(
            path: '/home',
            builder: (context, state) =>
                const ForceDarkTheme(child: ForYouScreen()),
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
              return ProfileScreen(
                userId: userId,
                section: state.uri.queryParameters['section'],
              );
            },
          ),
          // Alias usado no CONTEÚDO do QR code de perfil e nos links
          // públicos compartilhados (`AppConstants.profileUrl` gera
          // `brawe.app/connect/u/:userId`). Universal Links (iOS) / App
          // Links (Android) abrem o app direto nesta rota sem passar pelo
          // navegador; sem o app instalado, o mesmo link cai na página web
          // `/connect/u/[id]` (ver frontend), que redireciona para o
          // perfil completo. Mantém o mesmo comportamento de `/profile/:userId`.
          GoRoute(
            path: '/connect/u/:userId',
            builder: (context, state) {
              var userId = state.pathParameters['userId']!;
              if (userId.startsWith('@')) {
                userId = userId.substring(1);
              }
              return ProfileScreen(
                userId: userId,
                section: state.uri.queryParameters['section'],
              );
            },
          ),
          GoRoute(
            path: '/settings',
            builder: (context, state) => const SettingsScreen(),
          ),
          GoRoute(
            path: '/settings/delete-account',
            builder: (context, state) => const DeleteAccountScreen(),
          ),
          GoRoute(
            path: '/quests',
            builder: (context, state) {
              // Notificação: "/quests?quest=<key>" abre na missão;
              // "/quests?tab=achievements|journey" abre na aba.
              final qp = state.uri.queryParameters;
              final tab = switch (qp['tab']) {
                'achievements' || 'awards' || 'badges' => 1,
                'journey' || 'timeline' => 2,
                _ => 0,
              };
              return QuestsScreen(
                key: ValueKey(state.uri.toString()),
                highlightQuest: qp['quest'],
                initialTab: tab,
              );
            },
          ),
          GoRoute(
            path: '/wallet',
            redirect: (_, _) => kEnableMonetization ? null : '/home',
            builder: (context, state) => const WalletScreen(),
          ),
          GoRoute(
            path: '/notifications',
            builder: (context, state) => const NotificationsScreen(),
          ),
          GoRoute(
            path: '/notifications/:id/followers',
            builder: (context, state) => NewFollowersScreen(
              notificationId: state.pathParameters['id'] ?? '',
            ),
          ),
          GoRoute(
            path: '/find-friends',
            builder: (context, state) => const FindFriendsScreen(),
          ),
          GoRoute(
            path: '/scan-qr',
            builder: (context, state) => const QrScannerScreen(),
          ),
          GoRoute(
            path: '/edit-profile',
            builder: (context, state) => const EditProfileScreen(),
          ),
          GoRoute(
            path: '/artist-profile',
            builder: (context, state) => const ArtistProfileScreen(),
          ),
          GoRoute(
            path: '/business-profile',
            builder: (context, state) => const BusinessProfileScreen(),
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
            path: '/explore/hashtag/:tag',
            builder: (context, state) {
              final tag = state.pathParameters['tag']!;
              return HashtagResultsScreen(tag: tag);
            },
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
          GoRoute(path: '/creator', redirect: (_, _) => '/creator/intro'),
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
            builder: (context, state) => const CreatorApplicationFormScreen(),
          ),
          GoRoute(
            path: '/creator/submitted',
            builder: (context, state) =>
                const CreatorApplicationSubmittedScreen(),
          ),
          GoRoute(
            path: '/creator/status',
            builder: (context, state) => const CreatorApplicationStatusScreen(),
          ),
          GoRoute(
            path: '/creator/onboarding',
            builder: (context, state) => const CreatorOnboardingScreen(),
          ),
          // Rota antiga (tela placeholder removida): vai para Editar perfil.
          GoRoute(
            path: '/creator/profile-settings',
            redirect: (_, _) => '/edit-profile',
          ),
          GoRoute(
            path: '/creator/badge',
            builder: (context, state) => const CreatorBadgeScreen(),
          ),
          // Brawe Partners: "Minha agência" (convites, contrato, desempenho).
          // (mantida para links antigos e atalhos: abre o painel na aba Agência)
          GoRoute(
            path: '/creator/agency',
            redirect: (_, _) => '/creator/dashboard?tab=agency',
          ),
          GoRoute(
            path: '/creator/dashboard',
            builder: (context, state) => CreatorDashboardScreen(
              initialTab: state.uri.queryParameters['tab'],
            ),
          ),
          // Hub de análises (período único + abas). As rotas antigas
          // redirecionam para a aba certa, preservando links existentes.
          GoRoute(
            path: '/creator/analytics',
            builder: (context, state) => CreatorAnalyticsHubScreen(
              initialTab: state.uri.queryParameters['tab'],
            ),
          ),
          GoRoute(
            path: '/creator/analytics/viewers',
            redirect: (_, _) => '/creator/analytics?tab=audience',
          ),
          GoRoute(
            path: '/creator/analytics/followers',
            redirect: (_, _) => '/creator/analytics?tab=followers',
          ),
          GoRoute(
            path: '/creator/analytics/lives',
            redirect: (_, _) => '/creator/analytics?tab=lives',
          ),
          GoRoute(
            path: '/creator/analytics/reach',
            redirect: (_, _) => '/creator/analytics?tab=earnings',
          ),
          // ── Admin ───────────────────────────────────────────────
          GoRoute(
            path: '/admin/creator/applications',
            builder: (context, state) => const AdminCreatorApplicationsScreen(),
          ),
          GoRoute(
            path: '/admin/creator/applications/:id',
            builder: (context, state) => AdminCreatorApplicationDetailScreen(
              id: state.pathParameters['id']!,
            ),
          ),
          GoRoute(
            path: '/admin/creator/creators',
            builder: (context, state) => const AdminCreatorsManagementScreen(),
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
      // Resumo exibido imediatamente após o streamer encerrar a live —
      // ver LiveSummaryScreen doc header. Se `extra` vier ausente/incorreto
      // (ex.: navegação direta via deep link), cai num resumo vazio em vez
      // de quebrar — NUNCA deve resultar em tela branca.
      GoRoute(
        path: '/live/summary',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final data =
              extra?['data'] as LiveSummaryData? ?? const LiveSummaryData();
          final roomTitle = extra?['roomTitle'] as String?;
          return LiveSummaryScreen(data: data, roomTitle: roomTitle);
        },
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
      // Perfil em tela cheia, no mesmo nível da live: abrir um perfil de
      // dentro da live por `/profile/:id` (que vive no Shell com a barra de
      // baixo) dava tela preta. Telas de tela cheia usam esta rota.
      GoRoute(
        path: '/people/:userId',
        builder: (context, state) {
          var userId = state.pathParameters['userId']!;
          if (userId.startsWith('@')) userId = userId.substring(1);
          return ProfileScreen(userId: userId);
        },
      ),
      // "Meu nível" do presenteador: fora do Shell (no mesmo nível da live)
      // para abrir POR CIMA da live — dentro do Shell ela abria por baixo.
      // Cadastro em passos — fora do Shell (sem barra de baixo).
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/gifter-level',
        builder: (context, state) => const GifterLevelScreen(),
      ),
      // Recompensas do criador: fora do Shell para poder abrir por cima do
      // chat (o cofre tem "Ver recompensas") e da live. Dentro do Shell,
      // abrir a partir de /chat criava um 2º Shell → crash de GlobalKey.
      GoRoute(
        path: '/earnings',
        redirect: (_, _) => kEnableMonetization ? null : '/home',
        builder: (context, state) => const EarningsScreen(),
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
            return ForceDarkTheme(child: LiveViewerGate(room: extraRoom));
          }
          return ForceDarkTheme(
            child: _LiveRoomResolver(
              roomId: roomId,
              builder: (room) => LiveViewerGate(room: room),
            ),
          );
        },
      ),
      // Convite de agência: fora do shell (tela cheia) porque é aberto também
      // a partir da conversa (/chat/:id), que fica fora do shell — empilhar
      // uma rota do shell por cima dela quebra o Navigator (keyReservation).
      GoRoute(
        path: '/creator/agency/invite/:id',
        pageBuilder: (context, state) => CupertinoPage(
          key: state.pageKey,
          child: AgencyInviteScreen(inviteId: state.pathParameters['id']!),
        ),
      ),
      // Segurança da conta e troca de senha: fora do shell (tela cheia) porque
      // `/settings/security?secure=1` é aberto a partir da conversa oficial
      // (`/chat/:id`, fora do shell) — empilhar rota do shell por cima dela
      // quebra o Navigator (keyReservation).
      GoRoute(
        path: '/settings/security',
        pageBuilder: (context, state) => CupertinoPage(
          key: state.pageKey,
          child: SecurityScreen(
            openProtect: state.uri.queryParameters['secure'] == '1',
          ),
        ),
      ),
      GoRoute(
        path: '/settings/change-password',
        pageBuilder: (context, state) => CupertinoPage(
          key: state.pageKey,
          child: ChangePasswordScreen(
            required: state.uri.queryParameters['required'] == '1',
          ),
        ),
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
      // ── Marketplace (Vitrine + Compras) — estilo TikTok Shop ─────────────
      // Fullscreen de propósito: a vitrine/produto/carrinho/checkout cobrem
      // a bottom nav por completo (igual /live/:roomId e /chat/:id acima),
      // entrando com slide-up para parecer um "app dentro do app".
      // Vitrine dedicada de um criador/parceiro específico — NUNCA misturada
      // com posts/vídeos/galeria do perfil social (ver ShopVitrinePage doc).
      GoRoute(
        path: '/shop/creator/:userId',
        name: 'shop-creator-vitrine',
        pageBuilder: (context, state) {
          final userId = state.pathParameters['userId']!;
          return BraweTransitions.slideUp(
            key: state.pageKey,
            child: ShopVitrinePage(userId: userId),
          );
        },
      ),
      GoRoute(
        path: '/shop/store/:slug',
        name: 'shop-store',
        pageBuilder: (context, state) {
          final slug = state.pathParameters['slug']!;
          return BraweTransitions.slideUp(
            key: state.pageKey,
            child: ShopStorePage(storeSlug: slug),
          );
        },
      ),
      GoRoute(
        path: '/shop/product/:id',
        name: 'shop-product',
        pageBuilder: (context, state) {
          final id = state.pathParameters['id']!;
          return BraweTransitions.slideUp(
            key: state.pageKey,
            child: ShopProductPage(productId: id),
          );
        },
      ),
      GoRoute(
        path: '/shop/cart',
        name: 'shop-cart',
        pageBuilder: (context, state) => BraweTransitions.slideUp(
          key: state.pageKey,
          child: const ShopCartPage(),
        ),
      ),
      GoRoute(
        path: '/shop/checkout',
        name: 'shop-checkout',
        pageBuilder: (context, state) => BraweTransitions.slideUp(
          key: state.pageKey,
          child: const ShopCheckoutPage(),
        ),
        routes: [
          GoRoute(
            path: 'payment/:orderId',
            name: 'shop-payment',
            pageBuilder: (context, state) {
              final orderId = state.pathParameters['orderId']!;
              return BraweTransitions.slideUp(
                key: state.pageKey,
                child: ShopPaymentPage(orderId: orderId),
              );
            },
          ),
        ],
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
    AccountSuspension.instance.addListener(notifyListeners);
    OnboardingGate.instance.addListener(notifyListeners);
  }

  late final ProviderSubscription _subscription;

  @override
  void dispose() {
    _subscription.close();
    AccountSuspension.instance.removeListener(notifyListeners);
    OnboardingGate.instance.removeListener(notifyListeners);
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
            body: Center(child: CircularProgressIndicator(color: Colors.white)),
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
                    const Icon(
                      Icons.live_tv_outlined,
                      color: Colors.white54,
                      size: 64,
                    ),
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
                              color: Colors.white.withValues(alpha: 0.3),
                            ),
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
