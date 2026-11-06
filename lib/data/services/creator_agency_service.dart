// Brawe Partners — HTTP do criador: /creator/agency/* (Connect API).
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/live_dio_provider.dart';
import '../../domain/models/creator_agency.dart';

final creatorAgencyServiceProvider = Provider<CreatorAgencyService>(
  (ref) => CreatorAgencyService(ref.watch(liveDioProvider)),
);

class CreatorAgencyService {
  CreatorAgencyService(this._dio);
  final Dio _dio;

  static const _base = '/creator/agency';

  Future<AgencyState> getState() async {
    final r = await _dio.get<Map<String, dynamic>>(_base);
    return AgencyState.fromJson(r.data ?? const {});
  }

  Future<AgencyInvite> getInvite(String id) async {
    final r = await _dio.get<Map<String, dynamic>>('$_base/invites/$id');
    return AgencyInvite.fromJson(r.data ?? const {});
  }

  Future<AgencyState> accept(String id, String termsVersion) async {
    final r = await _dio.post<Map<String, dynamic>>(
      '$_base/invites/$id/accept',
      data: {'terms_version': termsVersion},
    );
    return AgencyState.fromJson(r.data ?? const {});
  }

  Future<AgencyState> decline(String id) async {
    final r = await _dio.post<Map<String, dynamic>>('$_base/invites/$id/decline');
    return AgencyState.fromJson(r.data ?? const {});
  }

  Future<AgencyState> leave() async {
    final r = await _dio.post<Map<String, dynamic>>('$_base/leave');
    return AgencyState.fromJson(r.data ?? const {});
  }

  /// kind: early (pedir à agência) | brawe_review (análise da Brawe, só em caso de abuso).
  Future<AgencyState> requestLeave({required String kind, required String reason, String? category}) async {
    final r = await _dio.post<Map<String, dynamic>>('$_base/leave-requests', data: {
      'kind': kind,
      'reason': reason.trim(),
      if (category != null) 'category': category,
    });
    return AgencyState.fromJson(r.data ?? const {});
  }

  Future<AgencyState> cancelLeaveRequest(String id) async {
    final r = await _dio.delete<Map<String, dynamic>>('$_base/leave-requests/$id');
    return AgencyState.fromJson(r.data ?? const {});
  }

  Future<bool> setOpenToAgencies(bool value) async {
    final r = await _dio.patch<Map<String, dynamic>>(
      '$_base/open-to-agencies',
      data: {'value': value},
    );
    return r.data?['open_to_agencies'] == true;
  }

  /// Desempenho em um mês (YYYY-MM); sem [month] = mês corrente.
  Future<AgencyPerformance> getPerformance({String? month}) async {
    final r = await _dio.get<Map<String, dynamic>>(
      '$_base/performance',
      queryParameters: {'month': ?month},
    );
    return AgencyPerformance.fromJson(r.data ?? const {});
  }

  /// Últimos [months] meses, do mais recente para o mais antigo.
  Future<List<AgencyPerformance>> getPerformanceHistory({int months = 6}) async {
    final r = await _dio.get<Map<String, dynamic>>(
      '$_base/performance/history',
      queryParameters: {'months': months},
    );
    return AgencyPerformance.listFromJson(r.data);
  }
}
