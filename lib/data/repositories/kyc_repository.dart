// Verificação de conta (identidade + empresa) e troca de tipo de conta — API do Connect.
//
// Identidade: CNH Digital do dia (Brasil) ou passaporte + vídeo de prova de vida com o desafio do servidor.
// Empresa: CNPJ (preenchido pela Receita) + dados fiscais + cartão CNPJ. Só depois da identidade aprovada.

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/live_dio_provider.dart';
import '../services/profile_service.dart';

final kycRepositoryProvider = Provider<KycRepository>(
  (ref) => KycRepository(ref.watch(liveDioProvider)),
);

/// Situação da verificação (para Editar perfil e a tela "Verificar minha conta").
final kycStatusProvider = FutureProvider.autoDispose<KycStatus>(
  (ref) => ref.read(kycRepositoryProvider).status(),
);

/// Dados da empresa para a tela "Perfil da empresa" (GET /kyc/business/me).
final businessMeProvider = FutureProvider.autoDispose<BusinessMe>(
  (ref) => ref.read(kycRepositoryProvider).businessMe(),
);

/// Bloco `business` do perfil público (null quando a conta não é empresa verificada).
/// Lê o mesmo GET /profile/{id}; separado do modelo Profile (freezed) por enquanto.
final profileBusinessProvider = FutureProvider.autoDispose
    .family<BusinessPublic?, String>((ref, userId) async {
      try {
        final data = await ref
            .read(profileServiceProvider)
            .getUserProfile(userId);
        final b = data['business'];
        if (b is! Map) return null;
        return BusinessPublic.fromJson(Map<String, dynamic>.from(b));
      } catch (_) {
        return null;
      }
    });

class KycFailure implements Exception {
  const KycFailure(this.message, {this.code, this.field});
  final String message;
  final String? code;
  final String? field;
  @override
  String toString() => message;
}

class KycStatus {
  const KycStatus({
    required this.identity,
    required this.identityReason,
    required this.business,
    required this.businessReason,
    required this.businessName,
    required this.accountType,
  });

  /// none · pending · approved · rejected
  final String identity;
  final String? identityReason;
  final String business;
  final String? businessReason;
  final String? businessName;
  final String accountType;

  bool get verified => identity == 'approved';

  factory KycStatus.fromJson(Map<String, dynamic> j) {
    final i = Map<String, dynamic>.from(j['identity'] as Map? ?? const {});
    final b = Map<String, dynamic>.from(j['business'] as Map? ?? const {});
    return KycStatus(
      identity: '${i['status'] ?? 'none'}',
      identityReason: i['reason'] as String?,
      business: '${b['status'] ?? 'none'}',
      businessReason: b['reason'] as String?,
      businessName: b['trade_name'] as String?,
      accountType: '${j['account_type'] ?? 'consumer'}',
    );
  }
}

class BusinessPublic {
  const BusinessPublic({
    this.name,
    this.category,
    this.email,
    this.whatsapp,
    this.city,
    this.state,
  });
  final String? name;
  final String? category;
  final String? email;
  final String? whatsapp;
  final String? city;
  final String? state;

  static String? _s(dynamic v) {
    final x = v?.toString().trim() ?? '';
    return x.isEmpty ? null : x;
  }

  factory BusinessPublic.fromJson(Map<String, dynamic> j) => BusinessPublic(
    name: _s(j['name']),
    category: _s(j['category']),
    email: _s(j['contact_email']),
    whatsapp: _s(j['whatsapp']),
    city: _s(j['city']),
    state: _s(j['state']),
  );

  /// "Curitiba, PR"
  String? get place {
    final parts = [city, state].whereType<String>().toList();
    return parts.isEmpty ? null : parts.join(', ');
  }

  /// Link do WhatsApp: 10-11 dígitos = número do Brasil sem DDI (acrescenta 55).
  Uri? get whatsappUri {
    final d = (whatsapp ?? '').replaceAll(RegExp(r'\D'), '');
    if (d.isEmpty) return null;
    final full = (d.length == 10 || d.length == 11) ? '55$d' : d;
    return Uri.parse('https://wa.me/$full');
  }

  Uri? get emailUri =>
      email == null ? null : Uri(scheme: 'mailto', path: email);
}

class BusinessVerification {
  const BusinessVerification({
    required this.status,
    this.reason,
    this.cnpj,
    this.legalName,
    this.tradeName,
    this.city,
    this.state,
    this.reviewedAt,
  });
  final String status;
  final String? reason;
  final String? cnpj;
  final String? legalName;
  final String? tradeName;
  final String? city;
  final String? state;
  final DateTime? reviewedAt;

  factory BusinessVerification.fromJson(Map<String, dynamic> j) =>
      BusinessVerification(
        status: '${j['status'] ?? 'pending'}',
        reason: BusinessPublic._s(j['reason']),
        cnpj: BusinessPublic._s(j['cnpj']),
        legalName: BusinessPublic._s(j['legal_name']),
        tradeName: BusinessPublic._s(j['trade_name']),
        city: BusinessPublic._s(j['city']),
        state: BusinessPublic._s(j['state']),
        reviewedAt: DateTime.tryParse('${j['reviewed_at'] ?? ''}'),
      );
}

class BusinessPage {
  const BusinessPage({
    this.category,
    this.email,
    this.whatsapp,
    this.showCity = true,
  });
  final String? category;
  final String? email;
  final String? whatsapp;
  final bool showCity;
}

class BusinessMe {
  const BusinessMe({
    required this.verification,
    required this.page,
    required this.categories,
  });
  final BusinessVerification? verification;
  final BusinessPage page;
  final List<String> categories;

  factory BusinessMe.fromJson(Map<String, dynamic> j) {
    final v = j['verification'];
    final p = j['page'] is Map
        ? Map<String, dynamic>.from(j['page'] as Map)
        : <String, dynamic>{};
    final cats = j['categories'];
    return BusinessMe(
      verification: v is Map
          ? BusinessVerification.fromJson(Map<String, dynamic>.from(v))
          : null,
      page: BusinessPage(
        category: BusinessPublic._s(p['category']),
        email: BusinessPublic._s(p['contact_email']),
        whatsapp: BusinessPublic._s(p['whatsapp']),
        showCity: p['show_city'] != false,
      ),
      categories: cats is List ? cats.map((e) => '$e').toList() : const [],
    );
  }
}

class KycChallenge {
  const KycChallenge({
    required this.token,
    required this.name,
    required this.date,
    required this.time,
    required this.code,
  });
  final String token;
  final String name;
  final String date;
  final String time;
  final String code;
}

class CnpjInfo {
  const CnpjInfo({
    required this.legalName,
    required this.tradeName,
    required this.active,
    required this.situation,
    required this.taxRegime,
    required this.address,
  });
  final String legalName;
  final String tradeName;
  final bool active;
  final String situation;
  final String taxRegime;
  final Map<String, String> address;
}

class KycRepository {
  KycRepository(this._dio);
  final Dio _dio;

  KycFailure _fail(Object e) {
    if (e is DioException) {
      final d = e.response?.data;
      final det = d is Map ? d['detail'] : null;
      if (det is Map && det['message'] != null) {
        return KycFailure(
          det['message'].toString(),
          code: det['code']?.toString(),
          field: det['field']?.toString(),
        );
      }
      if (det is String) return KycFailure(det);
    }
    return const KycFailure('');
  }

  Future<T> _run<T>(Future<T> Function() f) async {
    try {
      return await f();
    } catch (e) {
      throw _fail(e);
    }
  }

  Map<String, dynamic> _map(dynamic d) =>
      d is Map ? Map<String, dynamic>.from(d) : <String, dynamic>{};

  Future<KycStatus> status() => _run(
    () async => KycStatus.fromJson(_map((await _dio.get('/kyc/status')).data)),
  );

  Future<BusinessMe> businessMe() => _run(
    () async =>
        BusinessMe.fromJson(_map((await _dio.get('/kyc/business/me')).data)),
  );

  Future<void> saveBusinessPage({
    required String category,
    required String contactEmail,
    required String whatsapp,
    required bool showCity,
  }) => _run(
    () async => _dio.put(
      '/kyc/business/page',
      data: {
        'category': category,
        'contact_email': contactEmail,
        'whatsapp': whatsapp,
        'show_city': showCity,
      },
    ),
  );

  Future<KycChallenge> challenge() => _run(() async {
    final j = _map((await _dio.get('/kyc/challenge')).data);
    return KycChallenge(
      token: '${j['token']}',
      name: '${j['name']}',
      date: '${j['date']}',
      time: '${j['time']}',
      code: '${j['code']}',
    );
  });

  Future<KycStatus> submitIdentity({
    required String country,
    required String docType,
    required String challengeToken,
    required String documentPath,
    required String videoPath,
    void Function(double progress)? onProgress,
  }) => _run(() async {
    final form = FormData.fromMap({
      'country': country,
      'doc_type': docType,
      'challenge': challengeToken,
      'document': await MultipartFile.fromFile(documentPath),
      'video': await MultipartFile.fromFile(videoPath),
    });
    final r = await _dio.post(
      '/kyc/identity',
      data: form,
      options: Options(
        contentType: 'multipart/form-data',
        sendTimeout: const Duration(minutes: 3),
        receiveTimeout: const Duration(minutes: 2),
      ),
      onSendProgress: (a, b) => onProgress?.call(b > 0 ? a / b : 0),
    );
    return KycStatus.fromJson(_map(r.data));
  });

  Future<KycStatus> submitBusiness(
    Map<String, String> fields,
    String cardPath,
  ) => _run(() async {
    final form = FormData.fromMap({
      ...fields,
      'card': await MultipartFile.fromFile(cardPath),
    });
    final r = await _dio.post(
      '/kyc/business',
      data: form,
      options: Options(
        contentType: 'multipart/form-data',
        sendTimeout: const Duration(minutes: 2),
      ),
    );
    return KycStatus.fromJson(_map(r.data));
  });

  Future<CnpjInfo> lookupCnpj(String cnpj) => _run(() async {
    final j = _map((await _dio.get('/kyc/lookup/cnpj/$cnpj')).data);
    final a = _map(j['address']);
    return CnpjInfo(
      legalName: '${j['legal_name'] ?? ''}',
      tradeName: '${j['trade_name'] ?? ''}',
      active: j['active'] == true,
      situation: '${j['situation'] ?? ''}',
      taxRegime: '${j['tax_regime'] ?? ''}',
      address: a.map((k, v) => MapEntry(k, '${v ?? ''}')),
    );
  });

  Future<Map<String, String>> lookupCep(String cep) => _run(
    () async => _map(
      (await _dio.get('/kyc/lookup/cep/$cep')).data,
    ).map((k, v) => MapEntry(k, '${v ?? ''}')),
  );

  /// Troca o tipo de conta (consumer · creator · musician · business). Empresa exige verificação.
  Future<void> changeAccountType(String type) => _run(
    () async =>
        _dio.post('/profile/me/account-type', data: {'account_type': type}),
  );
}
