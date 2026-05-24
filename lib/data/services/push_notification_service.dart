import 'dart:io' show Platform;
import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/network/live_dio_provider.dart';

part 'push_notification_service.g.dart';

/// Service responsible for FCM token registration, permission handling,
/// foreground message display via flutter_local_notifications, and
/// reporting the token to brawe-connect backend (`POST /devices/register`).
///
/// Designed to fail gracefully when Firebase config files are missing.
class PushNotificationService {
  final Dio _dio;
  PushNotificationService(this._dio);

  static const _androidChannel = AndroidNotificationChannel(
    'brawe_high_importance',
    'Brawe Notifications',
    description: 'Notificações gerais do Brawe',
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
      const androidInit = AndroidInitializationSettings(
        'ic_stat_notification',
      );
      const iosInit = DarwinInitializationSettings();
      await _local.initialize(
        settings: const InitializationSettings(android: androidInit, iOS: iosInit),
      );
      await _local
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(_androidChannel);

      // Foreground message handler.
      FirebaseMessaging.onMessage.listen(_onForegroundMessage);

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
        data: {
          'token': token,
          'platform': Platform.isIOS ? 'ios' : 'android',
        },
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
    final notification = message.notification;
    if (notification == null) return;
    await _local.show(
      id: notification.hashCode,
      title: notification.title,
      body: notification.body,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          _androidChannel.id,
          _androidChannel.name,
          channelDescription: _androidChannel.description,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      payload: message.data.isEmpty ? null : message.data.toString(),
    );
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
  return PushNotificationService(ref.watch(liveDioProvider));
}
