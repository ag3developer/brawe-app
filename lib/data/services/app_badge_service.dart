import 'dart:io' show Platform;

import 'package:app_badge_plus/app_badge_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_badge_service.g.dart';

/// Thin wrapper around the OS app-icon badge (number shown over the launcher
/// icon). Centraliza o tratamento de plataforma e falhas para que o resto do
/// app só precise informar "quantos não lidos existem".
///
/// - iOS: sempre suportado (badge nativo do APNS/SpringBoard).
/// - Android: depende do launcher (Samsung, Xiaomi, Oppo… suportam; o launcher
///   padrão do Pixel mostra apenas o "dot"). Falha graciosamente quando não há
///   suporte.
/// - Web/desktop: no-op.
class AppBadgeService {
  const AppBadgeService();

  /// Define o badge para [count]. `0` (ou negativo) remove o badge.
  /// Best-effort: nunca lança — apenas registra em debug.
  Future<void> setCount(int count) async {
    if (kIsWeb || !(Platform.isAndroid || Platform.isIOS)) return;
    final value = count < 0 ? 0 : count;
    try {
      await AppBadgePlus.updateBadge(value);
    } catch (e) {
      debugPrint('AppBadgeService.setCount($value) failed: $e');
    }
  }

  /// Remove o badge do ícone (equivalente a `setCount(0)`).
  Future<void> clear() => setCount(0);
}

@Riverpod(keepAlive: true)
AppBadgeService appBadgeService(Ref ref) => const AppBadgeService();
