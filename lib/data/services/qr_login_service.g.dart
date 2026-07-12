// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'qr_login_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Serviço de login via QR code (estilo WhatsApp Web/TikTok).
///
/// Fluxo:
/// 1. Um dispositivo NÃO autenticado (ex.: navegador web) chama
///    [createSession] e mostra o `qrToken` retornado como QR code.
/// 2. O app mobile (já logado) escaneia esse QR e chama [approveSession]
///    com o token lido.
/// 3. O dispositivo web faz polling em [getSessionStatus] até receber
///    `status == 'approved'`, com o `access_token` pronto para uso.
///
/// Backend: `app.brawe.io/api/v1/auth/qr/*` (ver
/// `backend/app/api/v1/endpoints/qr_login.py`).

@ProviderFor(qrLoginService)
final qrLoginServiceProvider = QrLoginServiceProvider._();

/// Serviço de login via QR code (estilo WhatsApp Web/TikTok).
///
/// Fluxo:
/// 1. Um dispositivo NÃO autenticado (ex.: navegador web) chama
///    [createSession] e mostra o `qrToken` retornado como QR code.
/// 2. O app mobile (já logado) escaneia esse QR e chama [approveSession]
///    com o token lido.
/// 3. O dispositivo web faz polling em [getSessionStatus] até receber
///    `status == 'approved'`, com o `access_token` pronto para uso.
///
/// Backend: `app.brawe.io/api/v1/auth/qr/*` (ver
/// `backend/app/api/v1/endpoints/qr_login.py`).

final class QrLoginServiceProvider
    extends $FunctionalProvider<QrLoginService, QrLoginService, QrLoginService>
    with $Provider<QrLoginService> {
  /// Serviço de login via QR code (estilo WhatsApp Web/TikTok).
  ///
  /// Fluxo:
  /// 1. Um dispositivo NÃO autenticado (ex.: navegador web) chama
  ///    [createSession] e mostra o `qrToken` retornado como QR code.
  /// 2. O app mobile (já logado) escaneia esse QR e chama [approveSession]
  ///    com o token lido.
  /// 3. O dispositivo web faz polling em [getSessionStatus] até receber
  ///    `status == 'approved'`, com o `access_token` pronto para uso.
  ///
  /// Backend: `app.brawe.io/api/v1/auth/qr/*` (ver
  /// `backend/app/api/v1/endpoints/qr_login.py`).
  QrLoginServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'qrLoginServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$qrLoginServiceHash();

  @$internal
  @override
  $ProviderElement<QrLoginService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  QrLoginService create(Ref ref) {
    return qrLoginService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(QrLoginService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<QrLoginService>(value),
    );
  }
}

String _$qrLoginServiceHash() => r'638243aecb114b1a80e71daf742e139c3a80a451';
