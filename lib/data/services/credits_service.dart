import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../core/network/live_dio_provider.dart';

part 'credits_service.g.dart';

@riverpod
CreditsService creditsService(Ref ref) {
  return CreditsService(ref.watch(liveDioProvider));
}

class CreditsService {
  final Dio _dio;

  CreditsService(this._dio);

  Future<Map<String, dynamic>> getBalance() async {
    final response = await _dio.get('/credits/balance');
    return response.data['data'] ?? response.data;
  }

  Future<Map<String, dynamic>> getTransactions({int page = 1, int limit = 20}) async {
    final response = await _dio.get(
      '/credits/transactions',
      queryParameters: {'page': page, 'limit': limit},
    );
    return response.data['data'] ?? response.data;
  }
}
