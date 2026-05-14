import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/models/failure.dart';
import '../../domain/models/wallet.dart';
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
      final balance = data['balance'];
      if (balance is num) return balance.toDouble();
      return 0.0;
    } on DioException catch (e) {
      throw _mapFailure(e);
    } catch (e) {
      throw const Failure.unknown();
    }
  }

  Future<Wallet> getWallet() async {
    try {
      final data = await _creditsService.getBalance();
      return Wallet.fromJson(data);
    } on DioException catch (e) {
      throw _mapFailure(e);
    } catch (_) {
      throw const Failure.unknown();
    }
  }

  Future<List<WalletTransaction>> getTransactions({int page = 1, int limit = 20}) async {
    try {
      final data = await _creditsService.getTransactions(page: page, limit: limit);
      final items = (data['items'] as List? ?? const [])
          .map((e) => WalletTransaction.fromJson(e as Map<String, dynamic>))
          .toList();
      return items;
    } on DioException catch (e) {
      throw _mapFailure(e);
    } catch (_) {
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
