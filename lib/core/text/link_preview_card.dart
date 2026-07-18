import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

class _LinkPreviewCardContent extends StatelessWidget {
  const _LinkPreviewCardContent({required this.preview, this.compact = false});

  final LinkPreview preview;
  final bool compact;

  @override
  Widget build(BuildContext context) {
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (preview.image != null && preview.image!.isNotEmpty)
                AspectRatio(
                  aspectRatio: 1.91, // proporção padrão og:image (1200x630)
                  child: CachedNetworkImage(
                    imageUrl: preview.image!,
                    fit: BoxFit.cover,
                    // Force www prefix para evitar redirects 308
                    httpHeaders: const {
                      'User-Agent':
                          'Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko)',
                    },
                    cacheKey: _normalizeCacheKey(preview.image!),
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
                        '❌ LinkPreviewCard: Erro ao carregar imagem ${preview.image}',
                      );
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
          ),
        ),
      ),
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

/// Normaliza URL para cache, evitando problemas com redirects 308
/// Exemplo: https://brawe.io/og-image-pt.png → https://www.brawe.io/og-image-pt.png
String _normalizeCacheKey(String url) {
  try {
    final uri = Uri.parse(url);
    // Se é brawe.io sem www, adiciona www para evitar redirect
    if (uri.host == 'brawe.io') {
      return uri.replace(host: 'www.brawe.io').toString();
    }
    return url;
  } catch (e) {
    debugPrint('⚠️ Erro ao normalizar URL: $e');
    return url;
  }
}
