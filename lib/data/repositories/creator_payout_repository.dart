// Monetização — repositório do criador. Converte DioException em
// [PayoutException] (código estável do backend) para a UI traduzir.
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/creator_payout.dart';
import '../services/creator_payout_service.dart';

final creatorPayoutRepositoryProvider = Provider<CreatorPayoutRepository>(
  (ref) => CreatorPayoutRepository(ref.watch(creatorPayoutServiceProvider)),
);

/// Converte o erro HTTP em [PayoutException]. Público para teste.
PayoutException mapPayoutError(Object e) {
  if (e is PayoutException) return e;
  if (e is DioException) {
    final status = e.response?.statusCode;
    final data = e.response?.data;
    final detail = data is Map ? data['detail'] : null;
    if (detail is Map) {
      final code = detail['code']?.toString();
      if (code != null && code.isNotEmpty) {
        return PayoutException(code, extra: Map<String, dynamic>.from(detail), statusCode: status);
      }
    }
    if (status == 429) return PayoutException('too_many_requests', statusCode: status);
    if (status == 401 || status == 403) return PayoutException('unauthorized', statusCode: status);
    if (status != null && status >= 500) return PayoutException('server', statusCode: status);
    if (status == null) return const PayoutException('network');
    return PayoutException('generic', statusCode: status);
  }
  return const PayoutException('generic');
}

class CreatorPayoutRepository {
  CreatorPayoutRepository(this._service);
  final CreatorPayoutService _service;

  Future<T> _guard<T>(Future<T> Function() f) async {
    try {
      return await f();
    } catch (e) {
      throw mapPayoutError(e);
    }
  }

  Future<PayoutOverview> overview() => _guard(_service.overview);
  Future<PayoutAccount?> saveAccount({
    required String country,
    required String method,
    required String holderName,
    required String holderTaxId,
    required Map<String, String> fields,
    String? taxRegime,
  }) =>
      _guard(() => _service.saveAccount(
            country: country,
            method: method,
            holderName: holderName,
            holderTaxId: holderTaxId,
            fields: fields,
            taxRegime: taxRegime,
          ));
  Future<PayoutQuote> quote(int diamonds) => _guard(() => _service.quote(diamonds));
  Future<PayoutChallenge> request(int diamonds) => _guard(() => _service.request(diamonds));
  Future<PayoutChallenge> resend(String challengeId) => _guard(() => _service.resend(challengeId));
  Future<Payout> confirm(String challengeId, String code) => _guard(() => _service.confirm(challengeId, code));
  Future<Payout> cancel(String id) => _guard(() => _service.cancel(id));
}
