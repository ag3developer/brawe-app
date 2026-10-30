import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

import '../../ui/core/themes/brawe_colors.dart';
import '../../data/services/link_preview_service.dart';
import 'in_app_link_webview_screen.dart';
import 'link_preview_provider.dart';

/// Card de preview de link (imagem + título + domínio), no estilo
/// Twitter/Instagram/WhatsApp, exibido abaixo do texto de um post quando
/// o conteúdo contém uma URL.
///
/// Busca os metadados via `linkPreviewProvider` (que chama
/// `GET /posts/unfurl`) e não renderiza nada se:
/// - a URL não tiver preview disponível (`hasContent == false`);
/// - ainda estiver carregando (evita "pulo" de layout — mostra um
///   skeleton discreto em vez de um espaço vazio piscando);
/// - a busca falhar (falha aberta — o link continua clicável no texto).
class LinkPreviewCard extends ConsumerWidget {
  const LinkPreviewCard({super.key, required this.url, this.compact = false});

  final String url;

  /// Quando `true`, remove o padding externo de 16px (usado dentro de
  /// bolhas de chat, que já têm seu próprio padding — evita respiro duplo).
  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final previewAsync = ref.watch(linkPreviewProvider(url));

    return previewAsync.when(
      data: (preview) {
        if (preview == null || !preview.hasContent) {
          debugPrint(
            '⚠️ LinkPreviewCard: Preview null ou sem conteúdo para $url',
          );
          return const SizedBox.shrink();
        }
        debugPrint(
          '✅ LinkPreviewCard: Preview carregado - image=${preview.image}',
        );
        return _LinkPreviewCardContent(preview: preview, compact: compact);
      },
      loading: () {
        debugPrint('⏳ LinkPreviewCard: Carregando preview para $url');
        return _LinkPreviewSkeleton(compact: compact);
      },
      error: (err, _) {
        debugPrint('❌ LinkPreviewCard: Erro ao carregar preview: $err');
        return const SizedBox.shrink();
      },
    );
  }
}

class _LinkPreviewCardContent extends StatefulWidget {
  const _LinkPreviewCardContent({required this.preview, this.compact = false});

  final LinkPreview preview;
  final bool compact;

  @override
  State<_LinkPreviewCardContent> createState() =>
      _LinkPreviewCardContentState();
}

class _LinkPreviewCardContentState extends State<_LinkPreviewCardContent> {
  /// A imagem do site falhou (404, bloqueio, formato inválido) → o card vira
  /// a versão compacta. Antes ficava um quadro grande com ícone quebrado.
  bool _imageFailed = false;

  void _onImageError() {
    if (_imageFailed) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _imageFailed = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final preview = widget.preview;
    final compact = widget.compact;
    final hasImage =
        !_imageFailed && preview.image != null && preview.image!.isNotEmpty;
    return Padding(
      padding: compact
          ? EdgeInsets.zero
          : const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: GestureDetector(
        onTap: () => InAppLinkWebViewScreen.open(
          context,
          preview.url,
          title: preview.siteName,
        ),
        child: Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: context.colors.border),
            color: context.colors.surface,
          ),
          child: hasImage
              ? _buildLarge(context, preview)
              : _buildCompact(context, preview),
        ),
      ),
    );
  }

  /// Sem imagem: linha compacta (ícone · site · título), padrão WhatsApp/
  /// iMessage para links sem prévia visual.
  Widget _buildCompact(BuildContext context, LinkPreview preview) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: colors.surfaceHighest,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.link_rounded, color: colors.textSecondary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (preview.title != null && preview.title!.isNotEmpty)
                  Text(
                    preview.title!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: colors.textPrimary,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      height: 1.3,
                    ),
                  ),
                const SizedBox(height: 2),
                Text(
                  preview.siteName ?? preview.domain,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: colors.textSecondary, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLarge(BuildContext context, LinkPreview preview) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AspectRatio(
          aspectRatio: 1.91, // proporção padrão og:image (1200x630)
          child: _LinkPreviewImageLoader(
            imageUrl: preview.image!,
            colors: context.colors,
            onError: _onImageError,
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                (preview.siteName ?? preview.domain).toUpperCase(),
                style: TextStyle(
                  color: context.colors.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.4,
                ),
              ),
              if (preview.title != null && preview.title!.isNotEmpty) ...[
                const SizedBox(height: 3),
                Text(
                  preview.title!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: context.colors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    height: 1.3,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _LinkPreviewSkeleton extends StatelessWidget {
  const _LinkPreviewSkeleton({this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: compact
          ? EdgeInsets.zero
          : const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Container(
        height: 54,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: context.colors.border),
          color: context.colors.surface.withValues(alpha: 0.5),
        ),
      ),
    );
  }
}

/// Widget especial para carregar imagens de preview com tratamento de cache
/// melhorado para URLs de brawe.io que podem ter problemas de redirect 308
class _LinkPreviewImageLoader extends StatefulWidget {
  const _LinkPreviewImageLoader({
    required this.imageUrl,
    required this.colors,
    this.onError,
  });

  final String imageUrl;
  final BraweColors colors;

  /// Chamado quando a imagem não carrega (o card troca para o compacto).
  final VoidCallback? onError;

  @override
  State<_LinkPreviewImageLoader> createState() =>
      _LinkPreviewImageLoaderState();
}

class _LinkPreviewImageLoaderState extends State<_LinkPreviewImageLoader> {
  /// Uma instância só (antes era recriada a cada build do card).
  static final CacheManager _cacheManager = CacheManager(
    Config(
      'brawe_link_preview_images',
      stalePeriod: const Duration(days: 7),
      maxNrOfCacheObjects: 100,
    ),
  );

  @override
  void initState() {
    super.initState();
    // Se for brawe.io, limpa cache antigo do domínio sem www
    if (widget.imageUrl.contains('brawe.io')) {
      _clearOldBraweImageCache();
    }
  }

  Future<void> _clearOldBraweImageCache() async {
    try {
      // Remove cache da URL antiga (sem www)
      final oldUrl = widget.imageUrl.replaceFirst(
        'https://www.brawe.io',
        'https://brawe.io',
      );
      if (oldUrl != widget.imageUrl) {
        await DefaultCacheManager().removeFile(oldUrl);
        debugPrint('🗑️ LinkPreviewCard: Limpou cache antigo de $oldUrl');
      }

      // Também limpa URLs sem https se necessário
      final unsecureUrl = widget.imageUrl.replaceFirst('https://', 'http://');
      if (unsecureUrl != widget.imageUrl) {
        try {
          await DefaultCacheManager().removeFile(unsecureUrl);
          debugPrint('🗑️ LinkPreviewCard: Limpou cache http de $unsecureUrl');
        } catch (_) {
          // Ignora se não existir
        }
      }
    } catch (e) {
      debugPrint('⚠️ Erro ao limpar cache: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: widget.imageUrl,
      fit: BoxFit.cover,
      httpHeaders: _buildHeaders(widget.imageUrl),
      cacheKey: _normalizeCacheKey(widget.imageUrl),
      cacheManager: _cacheManager,
      placeholder: (_, __) => Container(
        color: context.colors.surface.withValues(alpha: 0.5),
        child: const Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      ),
      errorWidget: (_, __, ___) {
        debugPrint(
          '❌ LinkPreviewCard: Erro ao carregar imagem ${widget.imageUrl}',
        );
        widget.onError?.call();
        return Container(
          color: context.colors.surface.withValues(alpha: 0.3),
          child: Center(
            child: Icon(
              Icons.image_not_supported_outlined,
              color: context.colors.textSecondary,
              size: 32,
            ),
          ),
        );
      },
    );
  }

  /// Headers HTTP customizados por domínio para contornar restrições
  Map<String, String> _buildHeaders(String url) {
    final baseHeaders = {
      'User-Agent':
          'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
      'Accept': 'image/webp,image/apng,image/*,*/*;q=0.8',
      'Accept-Encoding': 'gzip, deflate',
      'Accept-Language': 'pt-BR,pt;q=0.9,en;q=0.8',
    };

    // Netflix requer Referer e headers de navegador desktop
    if (url.contains('netflix.com')) {
      baseHeaders['Referer'] = 'https://www.netflix.com/';
      baseHeaders['Sec-Fetch-Dest'] = 'image';
      baseHeaders['Sec-Fetch-Mode'] = 'no-cors';
    }

    // Instagram requer headers específicos
    if (url.contains('instagram.com') || url.contains('cdninstagram')) {
      baseHeaders['Referer'] = 'https://www.instagram.com/';
    }

    // Twitter/X requer headers de navegador
    if (url.contains('twitter.com') ||
        url.contains('x.com') ||
        url.contains('pbs.twimg.com')) {
      baseHeaders['Referer'] = 'https://twitter.com/';
    }

    return baseHeaders;
  }
}

/// Normaliza URL para cache, evitando problemas com redirects 308
/// Estratégias:
/// 1. Se brawe.io sem www, adiciona www (nosso caso específico)
/// 2. Se domínio sem www mas site comum redireciona, tenta com www
/// Exemplo: https://brawe.io/og-image-pt.png → https://www.brawe.io/og-image-pt.png
String _normalizeCacheKey(String url) {
  try {
    final uri = Uri.parse(url);
    final host = uri.host;

    // Se já tem www ou é subdomínio específico, retorna como está
    if (host.startsWith('www.') ||
        host.contains('cdn') ||
        host.contains('img') ||
        host.contains('image') ||
        host.startsWith('s.') ||
        host.startsWith('i.')) {
      return url;
    }

    // Sites conhecidos que se beneficiam de normalização para www
    const sitesComWWW = {
      'brawe.io',
      'netflix.com',
      'instagram.com',
      'twitter.com',
      'facebook.com',
      'youtube.com',
      'github.com',
      'reddit.com',
      'medium.com',
      'linkedin.com',
    };

    // Se é um site conhecido sem www, tenta adicionar
    if (sitesComWWW.contains(host)) {
      final normalizedHost = 'www.$host';
      return uri.replace(host: normalizedHost).toString();
    }

    return url;
  } catch (e) {
    debugPrint('⚠️ Erro ao normalizar URL: $e');
    return url;
  }
}
