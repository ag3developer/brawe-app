import 'dart:async';
import 'dart:io' show Platform;

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fvp/fvp.dart' as fvp;

import 'config/locale_provider.dart';
import 'data/repositories/auth_state_provider.dart';
import 'data/services/iap_service.dart';
import 'data/services/notification_navigation_service.dart';
import 'data/services/push_notification_service.dart';
import 'gen/l10n/app_localizations.dart';
import 'routing/router.dart';
import 'ui/core/themes/app_theme.dart';
import 'ui/settings/view_models/theme_view_model.dart';

Future<void> main() async {
  runZonedGuarded<Future<void>>(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      // ── Video backend ──────────────────────────────────────────────────
      // Android: usar `fvp` (MDK/FFmpeg) como backend do `video_player`.
      // O backend padrão do Android usa SurfaceTexture + MediaCodec, que
      // apresenta artefatos gráficos (faixas verdes em diagonal, lixo
      // visual) quando combinado com o renderizador Impeller do Flutter
      // em vários dispositivos (Motorola, Samsung mid-range, Xiaomi etc).
      // No iOS o AVFoundation nativo continua sendo usado (funciona 100%).
      if (!kIsWeb && Platform.isAndroid) {
        fvp.registerWith(
          options: {
            // Apenas Android — não substitui o player no iOS.
            'platforms': ['android'],
            // Decoders por ordem de preferência: hardware → software.
            // FFmpeg garante fallback se o codec hw do device estiver bugado.
            'video.decoders': ['AMediaCodec', 'FFmpeg'],
          },
        );
      }

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(pushNotificationServiceProvider).init();
      // Inicializa o IAP no boot para capturar compras pendentes
      // (recibos da Play/App Store que ficaram travados sem crédito,
      // ex: rede caiu entre a cobrança e a validação no backend).
      // O `purchaseStream` reentrega esses recibos automaticamente.
      ref.read(iapServiceProvider).init();
    });
  }

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
    );
  }
}
