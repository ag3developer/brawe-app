import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Log de requisições SÓ para desenvolvimento, sem vazar segredos.
///
/// Substitui o `LogInterceptor` do Dio, que imprimia o corpo inteiro — inclusive
/// a senha no login. Aqui campos sensíveis viram `***` e respostas longas são
/// cortadas. Nunca registra cabeçalhos (o Authorization tem o token).
class SafeLogInterceptor extends Interceptor {
  static const _sensitive = {
    'password',
    'new_password',
    'current_password',
    'old_password',
    'password_confirmation',
    'token',
    'access_token',
    'refresh_token',
    'id_token',
    'code',
    'otp',
    'secret',
    'card_number',
    'cvv',
  };
  static const _maxBody = 800;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final body = options.data == null ? '' : '  ${_short(_redact(options.data))}';
    debugPrint('→ ${options.method} ${options.uri}$body');
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    debugPrint(
      '← ${response.statusCode} ${response.requestOptions.uri}  '
      '${_short(_redact(response.data))}',
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final res = err.response;
    debugPrint(
      '✖ ${res?.statusCode ?? err.type.name} ${err.requestOptions.uri}  '
      '${res != null ? _short(_redact(res.data)) : err.message ?? ''}',
    );
    handler.next(err);
  }

  static dynamic _redact(dynamic data) {
    if (data is Map) {
      return data.map((k, v) => MapEntry(
            k,
            _sensitive.contains(k.toString().toLowerCase()) ? '***' : _redact(v),
          ));
    }
    if (data is List) return data.map(_redact).toList();
    if (data is FormData) {
      return {
        for (final f in data.fields)
          f.key: _sensitive.contains(f.key.toLowerCase()) ? '***' : f.value,
        for (final f in data.files) f.key: '<arquivo>',
      };
    }
    return data;
  }

  static String _short(dynamic data) {
    String text;
    try {
      text = data is String ? data : jsonEncode(data);
    } catch (_) {
      text = data.toString();
    }
    return text.length > _maxBody ? '${text.substring(0, _maxBody)}…' : text;
  }
}
