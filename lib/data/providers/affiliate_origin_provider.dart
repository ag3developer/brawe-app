import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Gerencia a origem do afiliado que referiu o usuário
///
/// Captura de múltiplas fontes (em ordem de prioridade):
/// 1. URL parameter: ?affiliate_code=ABC123 ou ?ref=affiliate-123
/// 2. Deep link path: /shop/product/123?ref=creator-456
/// 3. localStorage: afiliadoSalvo (persistido de compras anteriores)
/// 4. null: comprador direto (sem referência)
class AffiliateOriginManager {
  static const String _affiliateCodeKey = 'affiliate_code';
  static const String _affiliateIdKey = 'affiliate_id';
  static const String _affiliateSourceKey =
      'affiliate_source'; // "url", "deeplink", "saved"

  late final SharedPreferences _prefs;

  AffiliateOriginManager(this._prefs);

  static Future<AffiliateOriginManager> create() async {
    final prefs = await SharedPreferences.getInstance();
    return AffiliateOriginManager(prefs);
  }

  /// Captura affiliate origin de URL ou parâmetros
  ///
  /// Sintaxes suportadas:
  /// - ?affiliate_code=ABC123 (backend generates this)
  /// - ?ref=affiliate-123 (short format)
  /// - ?ref=creator-456 (live creator reference)
  Future<String?> captureFromUrl(String? queryString) async {
    if (queryString == null || queryString.isEmpty) {
      return getStoredAffiliateId();
    }

    String? affiliateId;

    // Tentar extrair affiliate_code
    if (queryString.contains('affiliate_code=')) {
      final match = RegExp(r'affiliate_code=([^&]+)').firstMatch(queryString);
      if (match != null) {
        affiliateId = match.group(1);
        if (affiliateId != null) {
          await _saveAffiliateId(affiliateId, 'url');
          return affiliateId;
        }
      }
    }

    // Tentar extrair ref (pode ser affiliate-123 ou creator-456)
    if (queryString.contains('ref=')) {
      final match = RegExp(r'ref=([^&]+)').firstMatch(queryString);
      if (match != null) {
        affiliateId = match.group(1);
        if (affiliateId != null) {
          // Determinar tipo de origem
          final source = affiliateId.startsWith('creator-')
              ? 'live'
              : 'affiliate';
          await _saveAffiliateId(affiliateId, source);
          return affiliateId;
        }
      }
    }

    // Nenhum parâmetro encontrado, usar armazenado
    return getStoredAffiliateId();
  }

  /// Salva affiliate ID em localStorage
  Future<void> _saveAffiliateId(String affiliateId, String source) async {
    await _prefs.setString(_affiliateIdKey, affiliateId);
    await _prefs.setString(_affiliateCodeKey, affiliateId);
    await _prefs.setString(_affiliateSourceKey, source);
  }

  /// Obtém affiliate ID armazenado
  String? getStoredAffiliateId() {
    return _prefs.getString(_affiliateIdKey);
  }

  /// Obtém source do affiliate armazenado (url, deeplink, saved, live)
  String? getStoredAffiliateSource() {
    return _prefs.getString(_affiliateSourceKey);
  }

  /// Obtém código de afiliado formatado para enviar ao backend
  ///
  /// Retorna formato esperado pelo backend:
  /// - "affiliate_code" ou "ref" (conforme backend aceita)
  String? getAffiliateCodeForBackend() {
    final affiliateId = getStoredAffiliateId();
    return affiliateId; // Backend deve interpretar o valor
  }

  /// Limpa o affiliate armazenado (logout)
  Future<void> clearAffiliate() async {
    await _prefs.remove(_affiliateIdKey);
    await _prefs.remove(_affiliateCodeKey);
    await _prefs.remove(_affiliateSourceKey);
  }

  /// Força um novo affiliate (útil para testes)
  Future<void> setAffiliate(
    String affiliateId, {
    String source = 'manual',
  }) async {
    await _saveAffiliateId(affiliateId, source);
  }
}

// ============================================================================
// PROVIDERS
// ============================================================================

/// Provider para AffiliateOriginManager
final affiliateOriginManagerProvider = FutureProvider<AffiliateOriginManager>((
  ref,
) async {
  return AffiliateOriginManager.create();
});

/// Provider que captura affiliate origin da URL atual
///
/// Uso:
/// ```dart
/// final affiliateId = ref.watch(currentAffiliateOriginProvider);
/// affiliateId.whenData((id) {
///   debugPrint('Affiliate ID: $id');
/// });
/// ```
final currentAffiliateOriginProvider = FutureProvider<String?>((ref) async {
  final manager = await ref.watch(affiliateOriginManagerProvider.future);

  // TODO: Integrar com GoRouter para capturar queryString da rota atual
  // Por enquanto, retorna o armazenado
  return manager.getStoredAffiliateId();
});

/// Provider que retorna affiliate ID para usar no carrinho
///
/// Valores:
/// - String: affiliate ID (ex: "affiliate-123", "creator-456")
/// - null: sem afiliado (comprador direto)
final affiliateIdForCartProvider = FutureProvider<String?>((ref) async {
  final manager = await ref.watch(affiliateOriginManagerProvider.future);
  return manager.getAffiliateCodeForBackend();
});

/// Provider que retorna a source do affiliate (url, deeplink, saved, live)
final affiliateSourceProvider = FutureProvider<String?>((ref) async {
  final manager = await ref.watch(affiliateOriginManagerProvider.future);
  return manager.getStoredAffiliateSource();
});
