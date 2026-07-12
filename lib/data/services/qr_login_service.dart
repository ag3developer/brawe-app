import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/network/dio_provider.dart';

part 'qr_login_service.g.dart';

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
@riverpod
QrLoginService qrLoginService(Ref ref) {
  return QrLoginService(ref.watch(dioProvider));
}

class QrLoginResult {
  final String status;
  final String? accessToken;
  final Map<String, dynamic>? user;

  const QrLoginResult({required this.status, this.accessToken, this.user});

  factory QrLoginResult.fromJson(Map<String, dynamic> json) {
    return QrLoginResult(
      status: json['status'] as String? ?? 'pending',
      accessToken: json['access_token'] as String?,
      user: json['user'] as Map<String, dynamic>?,
    );
  }
}

class QrLoginService {
  final Dio _dio;

  QrLoginService(this._dio);

  /// Aprova uma sessão de QR login escaneada pelo app (já autenticado).
  /// [qrToken] é o conteúdo lido do QR code exibido no outro dispositivo.
  Future<void> approveSession(String qrToken) async {
    await _dio.post('/auth/qr/approve', data: {'qr_token': qrToken});
  }

  /// Usado apenas pelo lado que EXIBE o QR (não usado pelo app mobile
  /// hoje, mas mantido aqui para simetria/testes e uso futuro caso o app
  /// também precise gerar QR de login para outro dispositivo).
  Future<Map<String, dynamic>> createSession() async {
    final response = await _dio.post('/auth/qr/create');
    return response.data as Map<String, dynamic>;
  }

  Future<QrLoginResult> getSessionStatus(String qrToken) async {
    final response = await _dio.get('/auth/qr/status/$qrToken');
    return QrLoginResult.fromJson(response.data as Map<String, dynamic>);
  }
}
