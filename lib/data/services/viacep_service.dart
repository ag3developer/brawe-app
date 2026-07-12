import 'package:dio/dio.dart';

/// Exceção para CEP inválido
class InvalidCepException implements Exception {
  final String message;
  InvalidCepException(this.message);

  @override
  String toString() => message;
}

/// Dados retornados pela API ViaCEP
class ViaCepAddress {
  final String street; // logradouro
  final String neighborhood; // bairro
  final String city; // localidade
  final String state; // uf
  final String postalCode; // cep

  ViaCepAddress({
    required this.street,
    required this.neighborhood,
    required this.city,
    required this.state,
    required this.postalCode,
  });

  factory ViaCepAddress.fromJson(Map<String, dynamic> json) {
    return ViaCepAddress(
      street: json['logradouro'] ?? '',
      neighborhood: json['bairro'] ?? '',
      city: json['localidade'] ?? '',
      state: json['uf'] ?? '',
      postalCode: json['cep'] ?? '',
    );
  }
}

/// Serviço para consultar endereços por CEP via ViaCEP
///
/// API: https://viacep.com.br/ws/{cep}/json
///
/// Exemplo:
/// ```dart
/// final service = ViaCepService();
/// final address = await service.searchCep('01310100');
/// print(address.street); // Avenida Paulista
/// ```
class ViaCepService {
  static const String _baseUrl = 'https://viacep.com.br/ws';

  final Dio _dio;

  ViaCepService({Dio? dio}) : _dio = dio ?? Dio();

  /// Busca um endereço pelo CEP
  ///
  /// [cep] deve ser 8 dígitos (com ou sem hífen)
  ///
  /// Lança [InvalidCepException] se:
  /// - CEP tem formato inválido
  /// - API retorna erro (CEP não existe)
  ///
  /// Exemplo:
  /// ```dart
  /// try {
  ///   final address = await service.searchCep('01310-100');
  ///   print(address.street); // Avenida Paulista
  /// } on InvalidCepException catch (e) {
  ///   print('CEP inválido: ${e.message}');
  /// }
  /// ```
  Future<ViaCepAddress> searchCep(String cep) async {
    // Limpar CEP (remover hífen se existir)
    final cleanCep = cep.replaceAll('-', '').trim();

    // Validar formato
    if (cleanCep.length != 8 || !RegExp(r'^\d{8}$').hasMatch(cleanCep)) {
      throw InvalidCepException(
        'CEP deve conter exatamente 8 dígitos (formato: 12345678)',
      );
    }

    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '$_baseUrl/$cleanCep/json',
        options: Options(
          contentType: Headers.jsonContentType,
          receiveTimeout: const Duration(seconds: 10),
        ),
      );

      final data = response.data;

      // ViaCEP retorna {"erro": true} se CEP não existe
      if (data?['erro'] == true) {
        throw InvalidCepException('CEP $cleanCep não encontrado');
      }

      // Verificar se tem pelo menos logradouro (não retorna para CEP genérico)
      if (data?['logradouro'] == null ||
          (data?['logradouro'] as String).isEmpty) {
        throw InvalidCepException(
          'CEP $cleanCep não possui endereço específico (pode ser genérico)',
        );
      }

      return ViaCepAddress.fromJson(data!);
    } on DioException catch (e) {
      throw InvalidCepException('Erro ao consultar CEP: ${e.message}');
    } on InvalidCepException {
      rethrow;
    } catch (e) {
      throw InvalidCepException('Erro inesperado ao buscar CEP: $e');
    }
  }

  /// Formata um CEP para o padrão brasileiro (XXXXX-XXX)
  static String formatCep(String cep) {
    final clean = cep.replaceAll(RegExp(r'\D'), '');
    if (clean.length != 8) return clean;
    return '${clean.substring(0, 5)}-${clean.substring(5)}';
  }

  /// Verifica se um CEP tem formato válido (8 dígitos)
  static bool isValidCepFormat(String cep) {
    final clean = cep.replaceAll('-', '').trim();
    return clean.length == 8 && RegExp(r'^\d{8}$').hasMatch(clean);
  }
}
