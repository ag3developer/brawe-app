import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../core/network/dio_provider.dart';
import 'store_showcase_service.dart';
import 'store_showcase_service_impl.dart';

part 'store_showcase_service_provider.g.dart';

/// Riverpod provider for [StoreShowcaseService].
/// Uses [dioProvider] (main backend) for marketplace endpoints.
@riverpod
StoreShowcaseService storeShowcaseService(Ref ref) {
  final dio = ref.watch(dioProvider);
  return StoreShowcaseServiceImpl(dio);
}
