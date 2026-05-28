import 'package:flutter/services.dart' show rootBundle;
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'legal_assets_service.g.dart';

/// Carrega arquivos markdown de `assets/legal/`.
///
/// Convenção: `creator_terms_<lang>.md` com fallback para `en`.
@riverpod
LegalAssetsService legalAssetsService(Ref ref) => const LegalAssetsService();

class LegalAssetsService {
  const LegalAssetsService();

  static const _supported = {'pt', 'en', 'es'};

  Future<String> loadCreatorTerms(String languageCode) async {
    final lang = _supported.contains(languageCode) ? languageCode : 'en';
    try {
      return await rootBundle.loadString('assets/legal/creator_terms_$lang.md');
    } catch (_) {
      return rootBundle.loadString('assets/legal/creator_terms_en.md');
    }
  }
}
