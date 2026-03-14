import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/models/failure.dart';
import '../services/credits_service.dart';

part 'credits_repository.g.dart';

@riverpod
CreditsRepository creditsRepository(Ref ref) {
  return CreditsRepository(ref.watch(creditsServiceProvider));
}

class CreditsRepository {
  final CreditsService _creditsService;

  CreditsRepository(this._creditsService);

  Future<double> getBalance() async {
    try {
      final data = await _creditsService.getBalance();
      // Expecting { "balance": 100.0, "currency": "USD", ... }
      final balance = data['balance'];
      if (balance is num) {
        return balance.toDouble();
      }
      return 0.0;
    } on DioException catch (e) {
      throw _mapFailure(e);
    } catch (e) {
      throw const Failure.unknown();
    }
  }

  Failure _mapFailure(DioException exception) {
    final statusCode = exception.response?.statusCode;
    if (statusCode == 401 || statusCode == 403) {
      return const Failure.unauthorized();
    }
    if (statusCode != null && statusCode >= 500) {
      return const Failure.server();
    }
    return const Failure.network();
  }
}
