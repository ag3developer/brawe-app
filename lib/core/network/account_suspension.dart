import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Dados da suspensão vindos do backend (403 `account_suspended`).
@immutable
class AccountSuspensionInfo {
  const AccountSuspensionInfo({
    required this.reason,
    this.until,
    this.category,
  });

  /// Motivo escrito pela equipe de moderação.
  final String reason;

  /// Fim da suspensão; `null` = permanente.
  final DateTime? until;

  /// child_safety | harassment | spam | inappropriate | impersonation | other
  final String? category;

  bool get isPermanent => until == null;

  /// Lê o `detail` de uma resposta de erro. Devolve `null` se não for
  /// suspensão de conta.
  static AccountSuspensionInfo? fromResponseData(dynamic data) {
    if (data is! Map) return null;
    final detail = data['detail'];
    if (detail is! Map || detail['code'] != 'account_suspended') return null;
    final untilRaw = detail['until'];
    return AccountSuspensionInfo(
      reason: (detail['reason'] as String?)?.trim().isNotEmpty == true
          ? (detail['reason'] as String).trim()
          : '',
      until: untilRaw is String ? DateTime.tryParse(untilRaw)?.toLocal() : null,
      category: detail['category'] as String?,
    );
  }
}

/// Estado global "conta suspensa". O interceptor do Dio liga quando o
/// backend responde 403 `account_suspended`; o roteador escuta e leva o
/// usuário para `/suspended`.
class AccountSuspension extends ValueNotifier<AccountSuspensionInfo?> {
  AccountSuspension._() : super(null);

  static final AccountSuspension instance = AccountSuspension._();

  void clear() => value = null;

  /// Interceptor para os clientes Dio autenticados.
  static Interceptor interceptor() => InterceptorsWrapper(
        onError: (err, handler) {
          final res = err.response;
          if (res?.statusCode == 403) {
            final info = AccountSuspensionInfo.fromResponseData(res?.data);
            if (info != null) instance.value = info;
          }
          handler.next(err);
        },
      );
}
