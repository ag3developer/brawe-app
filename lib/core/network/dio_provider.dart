import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../constants/app_constants.dart';
import '../../data/services/storage_service.dart';

part 'dio_provider.g.dart';

@riverpod
Dio dio(Ref ref) {
  final storageService = ref.watch(storageServiceProvider);

  final dio = Dio(
    BaseOptions(
      baseUrl: AppConstants.appApiV1Url,
      connectTimeout: AppConstants.defaultTimeout,
      receiveTimeout: AppConstants.defaultTimeout,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await storageService.getToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        debugPrint(
          'AppDio request ${options.method} ${options.path} auth=${token != null ? 'yes' : 'no'}',
        );
        return handler.next(options);
      },
    ),
  );

  // Add logging interceptor for development
  dio.interceptors.add(LogInterceptor(requestBody: true, responseBody: true));

  return dio;
}
