// ============================================================================
// GIFT ICON — Widget reusable: asset local → CDN → fallback genérico
// ----------------------------------------------------------------------------
// Mesma estratégia de `gifts_overlay.dart::_GiftIcon`. Tenta o PNG local em
// `assets/images/gifts/{tier}/{slug}.png`. Se não existir (ex.: gift novo
// ainda não bundlado no app, ou slug/tier com casing diferente), tenta
// variações (kebab-case ↔ snake_case, tier lowercase). Se ainda falhar,
// cai pra `iconUrl` da CDN (resolvendo path relativo contra o connect host).
// Se ambos falharem, mostra um ícone genérico de presente.
// ============================================================================

import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../themes/app_colors.dart';

class GiftIcon extends StatelessWidget {
  final String slug;
  final String tier;
  final String? iconUrl;
  final double size;
  final Color? fallbackColor;

  const GiftIcon({
    super.key,
    required this.slug,
    required this.tier,
    this.iconUrl,
    required this.size,
    this.fallbackColor,
  });

  /// Possíveis caminhos de asset local — backend pode retornar `mini_crown`
  /// enquanto o arquivo é `mini-crown.png` (e vice-versa); tier pode vir como
  /// `PREMIUM` (enum) ou `premium` (folder name).
  /// Tier vazio (ex.: presente que chegou pelo socket sem categoria):
  /// procura a imagem em todas as pastas.
  static const _allTiers = ['basic', 'free', 'premium', 'luxury', 'legendary'];

  List<String> get _assetCandidates {
    final tierLower = tier.toLowerCase();
    final tiers = tierLower.isEmpty ? _allTiers : [tierLower];
    final slugKebab = slug.toLowerCase().replaceAll('_', '-');
    final slugSnake = slug.toLowerCase().replaceAll('-', '_');
    final slugs = {slug.toLowerCase(), slugKebab, slugSnake};
    if (slug.trim().isEmpty) return const [];
    return [
      for (final t in tiers)
        for (final s in slugs) 'assets/images/gifts/$t/$s.png',
    ];
  }

  /// Resolve `iconUrl` — backend devolve caminho relativo (`/gifts/heart.png`)
  /// que precisa ser prefixado com o host do connect API.
  String? get _resolvedIconUrl {
    final url = iconUrl?.trim();
    if (url == null || url.isEmpty) return null;
    if (url.startsWith('http://') || url.startsWith('https://')) return url;
    if (url.startsWith('/')) return '${AppConstants.connectApiBaseUrl}$url';
    return '${AppConstants.connectApiBaseUrl}/$url';
  }

  @override
  Widget build(BuildContext context) {
    // Decodifica no tamanho exibido (o asset 3.0x tem 768px).
    final cachePx = (size * MediaQuery.devicePixelRatioOf(context)).round();
    // Imagem subida no painel (URL absoluta) vence o PNG antigo do app.
    final url = iconUrl?.trim() ?? '';
    if (url.startsWith('http') && !url.contains('/gifts/v1/')) {
      return Image.network(
        url,
        width: size,
        height: size,
        cacheWidth: cachePx,
        fit: BoxFit.contain,
        errorBuilder: (_, _, _) => _buildAssetChain(_assetCandidates, 0, cachePx),
      );
    }
    return _buildAssetChain(_assetCandidates, 0, cachePx);
  }

  Widget _buildAssetChain(List<String> paths, int index, int cachePx) {
    if (index >= paths.length) return _buildNetworkOrFallback(cachePx);
    return Image.asset(
      paths[index],
      width: size,
      height: size,
      cacheWidth: cachePx,
      fit: BoxFit.contain,
      errorBuilder: (_, _, _) => _buildAssetChain(paths, index + 1, cachePx),
    );
  }

  Widget _buildNetworkOrFallback(int cachePx) {
    final url = _resolvedIconUrl;
    if (url == null) return _fallback();
    return Image.network(
      url,
      cacheWidth: cachePx,
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (_, _, _) => _fallback(),
    );
  }

  Widget _fallback() => Icon(
        Icons.card_giftcard,
        size: size * 0.78,
        color: fallbackColor ?? AppColors.braweBlue,
      );
}
