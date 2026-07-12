import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../core/network/dio_provider.dart';
import '../../core/network/live_dio_provider.dart';
import 'store_showcase_service.dart';
import 'store_showcase_service_impl.dart';

part 'store_showcase_service_provider.g.dart';

/// Riverpod provider for [StoreShowcaseService].
/// Injects both Dio instances for different backends:
/// - dioProvider (app.brawe.io) for /marketplace/* (requires auth)
/// - liveDioProvider (connect.brawe.io) for /shopping/* (public)
@riverpod
StoreShowcaseService storeShowcaseService(Ref ref) {
  final appDio = ref.watch(dioProvider);
  final connectDio = ref.watch(liveDioProvider);
  return StoreShowcaseServiceImpl(appDio, connectDio);
}
