import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'config/locale_provider.dart';
import 'data/providers/cart_notifier_provider.dart';
import 'data/repositories/auth_state_provider.dart';
import 'data/services/cart_session_manager.dart';
import 'data/services/iap_service.dart';
import 'data/services/notification_navigation_service.dart';
import 'data/services/push_notification_service.dart';
import 'gen/l10n/app_localizations.dart';
import 'routing/router.dart';
import 'ui/core/themes/app_theme.dart';
import 'ui/core/view_models/app_badge_controller.dart';
import 'ui/settings/view_models/theme_view_model.dart';
import 'ui/core/themes/app_colors.dart';

Future<void> main() async {
  runZonedGuarded<Future<void>>(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      // Initialize cart session persistence
      try {
        final sessionManager = await CartSessionManager.create();
        await CartSession.initialize(sessionManager);
      } catch (e) {
        debugPrint('Failed to initialize CartSession: $e');
      }

      // ── Video backend ──────────────────────────────────────────────────
      // Android usa o player nativo do video_player (ExoPlayer/media3), igual
      // ao iOS com AVFoundation: qualidade adaptativa no HLS (cai de
      // resolução com rede/aparelho fraco), decodificação em hardware e pouca
      // memória. O `fvp` (MDK/FFmpeg) que estava aqui contornava faixas
      // verdes do Impeller — que está desligado no AndroidManifest — e
      // tocava sempre a resolução mais alta: travava e enchia a memória.
      // Ainda pesa: ver também _ImageMemoryGuard (cache de imagens).

      // Firebase init is best-effort; app must boot even without config files.
      var firebaseReady = false;
      try {
        await Firebase.initializeApp();
        firebaseReady = true;
      } catch (e) {
        debugPrint(
          'Firebase.initializeApp failed (push & crash reports disabled): $e',
        );
      }

      if (firebaseReady) {
        // Crashlytics: capture Flutter framework errors.
        FlutterError.onError = (FlutterErrorDetails details) {
          FlutterError.presentError(details);
          FirebaseCrashlytics.instance.recordFlutterFatalError(details);
        };
        // Crashlytics: capture errors from the platform/Dart side outside Flutter.
        PlatformDispatcher.instance.onError = (error, stack) {
          FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
          return true;
        };
        // Disable collection in debug builds to avoid spam during development.
        await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(
          !kDebugMode,
        );

        try {
          FirebaseMessaging.onBackgroundMessage(
            firebaseMessagingBackgroundHandler,
          );
        } catch (e) {
          debugPrint('FirebaseMessaging background handler failed: $e');
        }
      }

      // ── Rede de segurança global contra tela branca/travada ──────────
      // Por padrão, se um widget lançar uma exceção durante o build em
      // modo release, o Flutter renderiza um `ErrorWidget` cinza/em branco
      // sem nenhuma ação possível — foi essa a causa raiz de telas brancas
      // travadas (ex.: bug ao encerrar uma live no Android, ver
      // BUG_LIVE_END_BLANK_SCREEN.md). Este builder garante que QUALQUER
      // erro de renderização mostre, no mínimo, uma tela com um botão
      // "Recarregar" que leva o usuário de volta pra Home — nunca fica
      // preso sem nenhuma ação possível.
      ErrorWidget.builder = (FlutterErrorDetails details) {
        FlutterError.presentError(details);
        return _GlobalErrorFallback(details: details);
      };

      _ImageMemoryGuard.install();
      // App de vídeo vertical: só retrato. A tela cheia de vídeo horizontal
      // (LandscapeVideoPage) libera paisagem enquanto está aberta.
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
      runApp(const ProviderScope(child: BraweApp()));
    },
    (error, stack) {
      // Catch anything that escapes the zone.
      try {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      } catch (_) {
        debugPrint('Uncaught zone error: $error');
      }
    },
  );
}

class BraweApp extends ConsumerStatefulWidget {
  const BraweApp({super.key});

  @override
  ConsumerState<BraweApp> createState() => _BraweAppState();
}

class _BraweAppState extends ConsumerState<BraweApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(_lifecycleObserver);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(pushNotificationServiceProvider).init();
      // Arma o badge do ícone do app: instanciar o controller (keepAlive) faz
      // ele observar notificações + DMs não lidas e refletir no ícone do SO.
      ref.read(appBadgeControllerProvider);
      // Inicializa o IAP no boot para capturar compras pendentes
      // (recibos da Play/App Store que ficaram travados sem crédito,
      // ex: rede caiu entre a cobrança e a validação no backend).
      // O `purchaseStream` reentrega esses recibos automaticamente.
      ref.read(iapServiceProvider).init();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(_lifecycleObserver);
    super.dispose();
  }

  /// Reavalia o badge sempre que o app volta para o primeiro plano — cobre o
  /// caso de pushes recebidos em background (que não passam pelo handler de
  /// foreground) e de notificações lidas em outro dispositivo.
  late final _AppLifecycleObserver _lifecycleObserver = _AppLifecycleObserver(
    onResume: () => ref.read(appBadgeControllerProvider.notifier).refresh(),
  );

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeControllerProvider);
    final locale = ref.watch(localeControllerProvider);

    // Quando a sessão fica pronta (login ou restauração no boot), consome um
    // eventual deep link de push que chegou antes do usuário estar logado
    // (ex.: app aberto a partir de uma notificação em estado terminado).
    ref.listen(authStateProvider, (previous, next) {
      final isAuthenticated = next.asData?.value != null;
      if (isAuthenticated) {
        ref.read(notificationNavigationServiceProvider).consumePending();
      } else {
        ref.read(notificationNavigationServiceProvider).clearPending();
      }
    });

    return MaterialApp.router(
      title: 'Brawe',
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      routerConfig: router,
      // ── i18n ──────────────────────────────────────────
      locale: locale,
      supportedLocales: LocaleController.supportedLocales,
      localizationsDelegates: const [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      // ── Contraste padrão das barras do sistema (edge-to-edge) ─────────
      // A maioria das telas usa Scaffold sem AppBar (headers customizados),
      // então o `systemOverlayStyle` do AppBarTheme (ver app_theme.dart)
      // nunca é aplicado nelas. Este builder garante um fallback global
      // consistente com o tema ativo (claro/escuro) para status bar e nav
      // bar transparentes com ícones de contraste correto. Telas que
      // precisam de um estilo diferente (ex.: Stories, fundo sempre escuro)
      // continuam podendo sobrepor com seu próprio `AnnotatedRegion` — o
      // mais próximo na árvore prevalece. Ver ANDROID_EDGE_TO_EDGE_AUDIT.md,
      // Fase H.
      builder: (context, child) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: isDark
              ? SystemUiOverlayStyle.light.copyWith(
                  statusBarColor: Colors.transparent,
                  systemNavigationBarColor: Colors.transparent,
                  systemNavigationBarIconBrightness: Brightness.light,
                  systemNavigationBarDividerColor: Colors.transparent,
                )
              : SystemUiOverlayStyle.dark.copyWith(
                  statusBarColor: Colors.transparent,
                  systemNavigationBarColor: Colors.transparent,
                  systemNavigationBarIconBrightness: Brightness.dark,
                  systemNavigationBarDividerColor: Colors.transparent,
                ),
          child: child!,
        );
      },
    );
  }
}

/// Tela mínima de recuperação exibida quando QUALQUER widget lança uma
/// exceção durante o build (substitui o `ErrorWidget` padrão do Flutter,
/// que em release é apenas uma tela cinza/branca sem nenhuma ação
/// possível). Sempre oferece um botão para recarregar o app na Home,
/// evitando que o usuário fique travado numa tela sem saída.
class _GlobalErrorFallback extends StatelessWidget {
  const _GlobalErrorFallback({required this.details});

  final FlutterErrorDetails details;

  @override
  Widget build(BuildContext context) {
    if (kDebugMode) {
      // Em debug, mantém o comportamento padrão (tela vermelha com stack
      // trace) — é essencial pra debugar durante o desenvolvimento.
      return ErrorWidget(details.exception);
    }
    return Material(
      color: const Color(0xFF0B0F1A),
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.error_outline_rounded,
                  color: Colors.white54,
                  size: 48,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Algo deu errado',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Toque no botão abaixo para voltar ao início.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white54, fontSize: 14),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    // Tenta navegar via GoRouter usando o contexto local
                    // (ainda válido, é o build acima do erro). Se falhar
                    // por qualquer motivo, fecha o app como último
                    // recurso — nunca deixa o usuário sem ação possível.
                    try {
                      GoRouter.of(context).go('/home');
                    } catch (_) {
                      SystemNavigator.pop();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.braweBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text('Recarregar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Observer mínimo de ciclo de vida: dispara [onResume] quando o app volta ao
/// primeiro plano. Mantido fora do State para não poluir o `build`.
class _AppLifecycleObserver with WidgetsBindingObserver {
  _AppLifecycleObserver({required this.onResume});

  final VoidCallback onResume;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      onResume();
    }
  }
}


/// Teto do cache de imagens decodificadas + limpeza quando o sistema pede.
///
/// O padrão do Flutter guarda até 1000 imagens / 100 MB, e cada foto aberta
/// no tamanho original pesa dezenas de MB — no Android o sistema matava o
/// app ("fecha sozinho"). Aqui: teto menor, e o cache é esvaziado quando o
/// Android/iOS avisa memória baixa e quando o app vai para segundo plano.
class _ImageMemoryGuard with WidgetsBindingObserver {
  _ImageMemoryGuard._();

  static void install() {
    final cache = PaintingBinding.instance.imageCache;
    cache.maximumSize = 150; // imagens
    cache.maximumSizeBytes = 80 << 20; // 80 MB
    WidgetsBinding.instance.addObserver(_ImageMemoryGuard._());
  }

  void _trim() {
    final cache = PaintingBinding.instance.imageCache;
    cache.clear();
    cache.clearLiveImages();
  }

  @override
  void didHaveMemoryPressure() => _trim();

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) _trim();
  }
}
