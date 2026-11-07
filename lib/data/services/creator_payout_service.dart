// Monetização — HTTP do criador: /creator/payouts/* (Connect API).
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/live_dio_provider.dart';
import '../../domain/models/creator_payout.dart';

final creatorPayoutServiceProvider = Provider<CreatorPayoutService>(
  (ref) => CreatorPayoutService(ref.watch(liveDioProvider)),
);

class CreatorPayoutService {
  CreatorPayoutService(this._dio);
  final Dio _dio;

  static const _base = '/creator/payouts';

  Future<PayoutOverview> overview() async {
    final r = await _dio.get<Map<String, dynamic>>(_base);
    return PayoutOverview.fromJson(r.data ?? const {});
  }

  Future<PayoutAccount?> saveAccount({
    required String country,
    required String method,
    required String holderName,
    required String holderTaxId,
    required Map<String, String> fields,
    String? taxRegime,
  }) async {
    final r = await _dio.put<Map<String, dynamic>>('$_base/account', data: {
      'country': country,
      'method': method,
      'holder_name': holderName,
      'holder_tax_id': holderTaxId,
      'fields': fields,
      'tax_regime': ?taxRegime,
    });
    return PayoutAccount.fromJson(r.data);
  }

  Future<PayoutQuote> quote(int diamonds) async {
    final r = await _dio.post<Map<String, dynamic>>('$_base/quote', data: {'diamonds': diamonds});
    return PayoutQuote.fromJson(r.data);
  }

  Future<PayoutChallenge> request(int diamonds) async {
    final r = await _dio.post<Map<String, dynamic>>('$_base/request', data: {'diamonds': diamonds});
    return PayoutChallenge.fromJson(r.data ?? const {});
  }

  Future<PayoutChallenge> resend(String challengeId) async {
    final r = await _dio.post<Map<String, dynamic>>('$_base/request/resend', data: {'challenge_id': challengeId});
    return PayoutChallenge.fromJson(r.data ?? const {});
  }

  Future<Payout> confirm(String challengeId, String code) async {
    final r = await _dio.post<Map<String, dynamic>>(
      '$_base/request/confirm',
      data: {'challenge_id': challengeId, 'code': code},
    );
    return Payout.fromJson(r.data);
  }

  Future<Payout> cancel(String id) async {
    final r = await _dio.post<Map<String, dynamic>>('$_base/$id/cancel');
    return Payout.fromJson(r.data);
  }
}
