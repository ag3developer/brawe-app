// Brawe Partners — repositório do criador. Converte DioException em
// [AgencyException] (código estável do backend) para a UI traduzir.
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/creator_agency.dart';
import '../services/creator_agency_service.dart';

final creatorAgencyRepositoryProvider = Provider<CreatorAgencyRepository>(
  (ref) => CreatorAgencyRepository(ref.watch(creatorAgencyServiceProvider)),
);

/// Converte o erro HTTP em [AgencyException]. Público para teste.
AgencyException mapAgencyError(Object e) {
  if (e is AgencyException) return e;
  if (e is DioException) {
    final status = e.response?.statusCode;
    final data = e.response?.data;
    var detail = data is Map ? data['detail'] : null;
    if (detail is Map) {
      final code = detail['code']?.toString();
      if (code != null && code.isNotEmpty) {
        return AgencyException(
          code,
          canLeaveAt: detail['can_leave_at'] is String
              ? DateTime.tryParse(detail['can_leave_at'] as String)?.toLocal()
              : null,
          retryAt: detail['retry_at'] is String ? DateTime.tryParse(detail['retry_at'] as String)?.toLocal() : null,
          currentVersion: detail['current_version']?.toString(),
          statusCode: status,
        );
      }
    }
    if (status == 401 || status == 403) return AgencyException('unauthorized', statusCode: status);
    if (status == 404) return AgencyException('not_found', statusCode: status);
    if (status == 422) return AgencyException('validation', statusCode: status);
    if (status != null && status >= 500) return AgencyException('server', statusCode: status);
    return const AgencyException('network');
  }
  return const AgencyException('unknown');
}

class CreatorAgencyRepository {
  CreatorAgencyRepository(this._service);
  final CreatorAgencyService _service;

  Future<T> _guard<T>(Future<T> Function() f) async {
    try {
      return await f();
    } catch (e) {
      throw mapAgencyError(e);
    }
  }

  Future<AgencyState> getState() => _guard(_service.getState);
  Future<AgencyInvite> getInvite(String id) => _guard(() => _service.getInvite(id));
  Future<AgencyState> accept(String id, String termsVersion) =>
      _guard(() => _service.accept(id, termsVersion));
  Future<AgencyState> decline(String id) => _guard(() => _service.decline(id));
  Future<AgencyState> leave() => _guard(_service.leave);
  Future<AgencyState> requestLeave({required String kind, required String reason, String? category}) =>
      _guard(() => _service.requestLeave(kind: kind, reason: reason, category: category));
  Future<AgencyState> cancelLeaveRequest(String id) => _guard(() => _service.cancelLeaveRequest(id));
  Future<bool> setOpenToAgencies(bool v) => _guard(() => _service.setOpenToAgencies(v));
  Future<AgencyPerformance> getPerformance({String? month}) => _guard(() => _service.getPerformance(month: month));
  Future<List<AgencyPerformance>> getPerformanceHistory({int months = 6}) =>
      _guard(() => _service.getPerformanceHistory(months: months));
}
