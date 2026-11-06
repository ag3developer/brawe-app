import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;
import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/network/live_dio_provider.dart';
import '../../ui/core/view_models/app_badge_controller.dart';
import '../../ui/chat/view_models/unread_chats_provider.dart';
import 'notification_navigation_service.dart';
import 'push_grouping.dart';

part 'push_notification_service.g.dart';

/// Service responsible for FCM token registration, permission handling,
/// foreground message display via flutter_local_notifications, and
/// reporting the token to brawe-connect backend (`POST /devices/register`).
///
/// Designed to fail gracefully when Firebase config files are missing.
class PushNotificationService {
  final Dio _dio;
  final NotificationNavigationService _navigation;
  final Ref _ref;
  PushNotificationService(this._dio, this._navigation, this._ref);

  static const _androidChannel = AndroidNotificationChannel(
    'brawe_high_importance',
    'Brawe Notifications',
    description: 'Notificações gerais da Brawe',
    importance: Importance.high,
  );

  final FlutterLocalNotificationsPlugin _local =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  /// Call once at app startup (after Firebase.initializeApp).
  Future<void> init() async {
    if (_initialized) return;
    // Skip silently when Firebase has no default app configured (e.g. dev
    // build without GoogleService-Info.plist / google-services.json).
    if (Firebase.apps.isEmpty) {
      debugPrint(
        'PushNotificationService: Firebase not configured, skipping push setup.',
      );
      return;
    }
    try {
      // Request permission (iOS + Android 13+).
      await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      // Local notifications (foreground display on Android).
      // Usa o ícone monocromático `ic_stat_notification` (drawable) — exigência
      // do Android para notification bar (colorido só funciona via accent color).
      const androidInit = AndroidInitializationSettings('ic_stat_notification');
      const iosInit = DarwinInitializationSettings();
      await _local.initialize(
        settings: const InitializationSettings(
          android: androidInit,
          iOS: iosInit,
        ),
        onDidReceiveNotificationResponse: _onLocalNotificationTap,
      );
      await _local
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.createNotificationChannel(_androidChannel);

      // Foreground message handler.
      FirebaseMessaging.onMessage.listen(_onForegroundMessage);

      // App em background (não terminado) → usuário toca na notificação.
      FirebaseMessaging.onMessageOpenedApp.listen(_onMessageOpenedApp);

      // App terminado → aberto a partir de um toque na notificação.
      // Atrasa o tratamento para o próximo frame, garantindo que o GoRouter
      // e a sessão já estejam disponíveis (o destino vira "pendente" se a
      // sessão ainda não resolveu — ver NotificationNavigationService).
      unawaited(_handleInitialMessage());

      // Configura como exibir notificações em foreground no iOS
      await FirebaseMessaging.instance
          .setForegroundNotificationPresentationOptions(
            alert: true,
            badge: true,
            sound: true,
          );

      // Token refresh automático → re-registra no backend
      FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
        try {
          await _dio.post(
            '/devices/register',
            data: {
              'token': newToken,
              'platform': Platform.isIOS ? 'ios' : 'android',
            },
          );
        } catch (e) {
          debugPrint('onTokenRefresh re-register failed: $e');
        }
      });

      _initialized = true;
    } catch (e, st) {
      debugPrint('PushNotificationService.init failed: $e\n$st');
    }
  }

  /// Fetch the current FCM token and register it with the backend.
  /// Should be called after a successful login.
  Future<void> registerWithBackend() async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token == null) return;
      await _dio.post(
        '/devices/register',
        data: {'token': token, 'platform': Platform.isIOS ? 'ios' : 'android'},
      );
    } catch (e) {
      debugPrint('registerWithBackend failed: $e');
    }
  }

  /// Unregister the current device token (on logout).
  Future<void> unregister() async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token == null) return;
      await _dio.delete(
        '/devices/unregister',
        queryParameters: {'token': token},
      );
    } catch (e) {
      debugPrint('unregister failed: $e');
    }
  }

  Future<void> _onForegroundMessage(RemoteMessage message) async {
    // Atualiza o badge do ícone (notificações + DMs) assim que o push chega
    // com o app aberto. O controller recalcula a partir das fontes existentes.
    _ref.read(appBadgeControllerProvider.notifier).refresh();
    final chats = _ref.read(unreadChatsProvider.notifier);
    chats.refresh();

    // Já está na conversa: nada de banner (a mensagem aparece na tela).
    if (PushGrouping.shouldSuppress(message.data, chats.activeConversationId)) {
      return;
    }

    final notification = message.notification;
    if (notification == null) return;
    // Mesma conversa → mesmo id/tag: a notificação nova SUBSTITUI a anterior.
    final group = PushGrouping.groupKey(message.data);
    await _local.show(
      id: group != null
          ? PushGrouping.notificationId(group)
          : notification.hashCode,
      title: notification.title,
      body: notification.body,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          _androidChannel.id,
          _androidChannel.name,
          channelDescription: _androidChannel.description,
          icon: '@mipmap/ic_launcher',
          tag: group,
        ),
        iOS: DarwinNotificationDetails(threadIdentifier: group),
      ),
      // Serializa o `data` em JSON para que o toque na notificação local
      // (foreground) consiga reconstruir o payload e navegar.
      payload: message.data.isEmpty ? null : jsonEncode(message.data),
    );
  }

  /// Remove as notificações dessa conversa (ao abri-la). Android: cancela pela
  /// tag (a local e a do FCM, que usa id 0). iOS: o `apns-collapse-id` já
  /// mantém só uma; o plugin não remove notificações remotas entregues.
  Future<void> clearConversationNotifications(String conversationId) async {
    try {
      await _local.cancel(
        id: PushGrouping.notificationId(conversationId),
        tag: conversationId,
      );
      await _local.cancel(id: 0, tag: conversationId);
    } catch (e) {
      debugPrint('clearConversationNotifications falhou: $e');
    }
  }

  /// App em foreground: usuário tocou na notificação local exibida acima.
  void _onLocalNotificationTap(NotificationResponse response) {
    final raw = response.payload;
    if (raw == null || raw.isEmpty) return;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map) {
        _navigation.handleData(Map<String, dynamic>.from(decoded));
      }
    } catch (e) {
      debugPrint('Falha ao decodificar payload da notificação local: $e');
    }
  }

  /// App em background (vivo): usuário tocou na notificação do sistema.
  void _onMessageOpenedApp(RemoteMessage message) {
    _navigation.handleData(message.data);
  }

  /// App terminado: foi aberto a partir de um toque na notificação.
  Future<void> _handleInitialMessage() async {
    try {
      final initial = await FirebaseMessaging.instance.getInitialMessage();
      if (initial != null) {
        _navigation.handleData(initial.data);
      }
    } catch (e) {
      debugPrint('getInitialMessage falhou: $e');
    }
  }
}

/// Top-level handler required by firebase_messaging for background messages.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Background isolate. Inicializa Firebase para processar a mensagem.
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp();
    }
    debugPrint('🔔 Background push recebido: ${message.notification?.title}');
  } catch (e) {
    debugPrint('Background handler error: $e');
  }
}

@riverpod
PushNotificationService pushNotificationService(Ref ref) {
  return PushNotificationService(
    ref.watch(liveDioProvider),
    ref.watch(notificationNavigationServiceProvider),
    ref,
  );
}
