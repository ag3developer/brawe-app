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
      const androidInit = AndroidInitializationSettings(
        '@mipmap/ic_launcher',
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
  // Background isolate. Keep minimal - just ensure Firebase is initialized.
  try {
    await Firebase.initializeApp();
  } catch (_) {}
}

@riverpod
PushNotificationService pushNotificationService(Ref ref) {
  return PushNotificationService(ref.watch(liveDioProvider));
}
