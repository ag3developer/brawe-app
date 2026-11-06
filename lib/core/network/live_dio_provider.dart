import 'package:dio/dio.dart';
import 'account_suspension.dart';
import 'device_identity.dart';
import 'session_ended.dart';
import 'safe_log_interceptor.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../constants/app_constants.dart';
import '../../data/services/storage_service.dart';

part 'live_dio_provider.g.dart';

@riverpod
Dio liveDio(Ref ref) {
  final storageService = ref.watch(storageServiceProvider);

  final dio = Dio(
    BaseOptions(
      baseUrl: AppConstants.connectApiV1Url,
      connectTimeout: AppConstants.defaultTimeout,
      sendTimeout: AppConstants.defaultTimeout,
      receiveTimeout: AppConstants.defaultTimeout,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'X-Brawe-Client': 'app',
      },
    ),
  );

  // Conta suspensa pela moderação → tela /suspended.
  dio.interceptors.add(AccountSuspension.interceptor());

  // 401 de sessão revogada → logout + aviso na tela de login.
  dio.interceptors.add(SessionEnded.interceptor(storageService));

  // X-Device-Id / X-Device-Name / X-Device-Platform / X-App-Version.
  dio.interceptors.add(DeviceIdentity.instance.interceptor());

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await storageService.getToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        debugPrint(
          'LiveDio request ${options.method} ${options.path} auth=${token != null ? 'yes' : 'no'}',
        );
        return handler.next(options);
      },
    ),
  );

  // Add logging interceptor for development only — NEVER log headers here:
  // Authorization carries the raw Bearer token and must not be printed to
  // the console (kDebugMode-only guard also keeps this out of release
  // builds entirely).
  if (kDebugMode) {
    dio.interceptors.add(
      SafeLogInterceptor(),
    );
  }

  return dio;
}
