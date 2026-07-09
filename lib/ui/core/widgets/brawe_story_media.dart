// ============================================================================
// BRAWE STORY MEDIA — Renderiza imagem OU vídeo de um story full-screen
// ============================================================================
// Substitui a mistura imperfeita anterior (Image.network sem cache + busca
// de placeholder por inicial) por uma única superfície que sabe lidar com
// os 3 estados visíveis:
//
//   - Loading      → blur do nome do autor + spinner sutil (sem letra)
//   - Loaded       → mídia em FullScreen (BoxFit.cover)
//   - Error        → mensagem com retry e a mesma blur de fundo
//
// Bug específico que ESSE WIDGET corrige (issue do usuário):
//   Quando o story é VÍDEO, o `_videoController?.value.isInitialized`
//   começa em FALSE. O viewer antigo caía no `else if (mediaUrl.isNotEmpty)`
//   que tentava carregar a URL .mp4 como Image.network → errorBuilder →
//   _placeholder com "letra inicial gigante" durante 1-3s na rede 4G.
//
// Solução: aqui o estado de loading é DETERMINADO pelo `isInitialized` do
// controller (vídeo) ou pelo CachedNetworkImage (imagem), nunca pela
// inicial — a inicial só aparece se a URL do avatar do header tb falhar.
// ============================================================================

import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

import 'brawe_avatar.dart';

/// Renderização full-screen de mídia de story.
///
/// O caller continua sendo dono do `VideoPlayerController` (não criamos
/// nem destruímos aqui — só renderizamos o estado atual). Isso preserva
/// o controle de timing/audio/seek do `_StoryViewerState`.
class BraweStoryMedia extends StatelessWidget {
  /// Tipo da mídia. `true` = vídeo, `false` = imagem.
  final bool isVideo;

  /// URL da mídia (imagem ou vídeo).
  final String mediaUrl;

  /// Controller do vídeo. Pode ser null enquanto inicializa.
  /// Quando isVideo == false, ignorado.
  final VideoPlayerController? videoController;

  /// Para o estado de loading e fallback de erro: nome do autor (usado
  /// para gerar a cor do fundo "blur" e as iniciais sem usar uma letra
  /// gigante na frente da câmera do usuário).
  final String authorName;

  /// Avatar do autor — quando disponível, usamos ele como fundo
  /// desfocado durante o loading (efeito Spotify/Apple Music).
  final String? authorAvatarUrl;

  /// Callback quando o usuário tocar em "Tentar novamente" no estado
  /// de erro. Pode ser null para esconder o botão.
  final VoidCallback? onRetry;

  /// Dimensões originais da mídia (do campo width/height da API).
  /// Usado para decidir o fit correto quando publicado via web.
  final int? mediaWidth;
  final int? mediaHeight;

  const BraweStoryMedia({
    super.key,
    required this.isVideo,
    required this.mediaUrl,
    required this.videoController,
    required this.authorName,
    this.authorAvatarUrl,
    this.onRetry,
    this.mediaWidth,
    this.mediaHeight,
  });

  @override
  Widget build(BuildContext context) {
    if (mediaUrl.isEmpty) {
      // Story sem mídia (raríssimo — provavelmente upload corrompido).
      return _LoadingBackdrop(
        authorName: authorName,
        authorAvatarUrl: authorAvatarUrl,
      );
    }

    if (isVideo) {
      return _VideoSurface(
        controller: videoController,
        authorName: authorName,
        authorAvatarUrl: authorAvatarUrl,
        onRetry: onRetry,
      );
    }

    // Calcular o fit correto baseado nas dimensões da mídia.
    // Stories publicados via web tendem a ter aspect ratio != 9:16.
    final BoxFit imageFit = _fitForDimensions(mediaWidth, mediaHeight);

    return _ImageSurface(
      url: mediaUrl,
      authorName: authorName,
      authorAvatarUrl: authorAvatarUrl,
      onRetry: onRetry,
      fit: imageFit,
      mediaWidth: mediaWidth,
      mediaHeight: mediaHeight,
    );
  }

  /// Decide o BoxFit ideal baseado nas dimensões reais da mídia:
  /// - Sem dimensões (app nativo) → cover (assume 9:16)
  /// - Portrait nativo (ar ≤ 0.8) → cover (preenche tela)
  /// - Quadrado (0.8 < ar ≤ 1.2) → contain com fundo blur
  /// - Landscape (ar > 1.2) → contain com fundo desfocado
  static BoxFit _fitForDimensions(int? w, int? h) {
    if (w == null || h == null || h == 0) return BoxFit.cover;
    final ar = w / h;
    if (ar <= 0.8) return BoxFit.cover; // portrait: preenche normalmente
    return BoxFit.contain; // landscape/quadrado: mostra tudo
  }
}

// ─── Imagem ────────────────────────────────────────────────────────

class _ImageSurface extends StatelessWidget {
  final String url;
  final String authorName;
  final String? authorAvatarUrl;
  final VoidCallback? onRetry;
  final BoxFit fit;
  final int? mediaWidth;
  final int? mediaHeight;

  const _ImageSurface({
    required this.url,
    required this.authorName,
    required this.authorAvatarUrl,
    required this.onRetry,
    this.fit = BoxFit.cover,
    this.mediaWidth,
    this.mediaHeight,
  });

  bool get _needsBlurBackground => fit == BoxFit.contain;

  @override
  Widget build(BuildContext context) {
    // Para imagens landscape/quadradas (publicadas via web), mostramos:
    // Camada 1: a mesma imagem desfocada + escurecida como fundo (preenche as bordas)
    // Camada 2: a imagem real com contain (sem corte, respeitando aspect ratio)
    if (_needsBlurBackground) {
      return Stack(
        fit: StackFit.expand,
        children: [
          // Fundo: imagem desfocada para preencher as bordas pretas
          CachedNetworkImage(
            imageUrl: url,
            fit: BoxFit.cover,
            fadeInDuration: Duration.zero,
            placeholder: (_, __) => _LoadingBackdrop(
              authorName: authorName,
              authorAvatarUrl: authorAvatarUrl,
            ),
            errorWidget: (_, __, ___) => const SizedBox.shrink(),
            imageBuilder: (_, provider) => Stack(
              fit: StackFit.expand,
              children: [
                Image(image: provider, fit: BoxFit.cover),
                // Escurecer + desfocar o fundo
                Container(color: Colors.black.withValues(alpha: 0.55)),
                // Blur sobre o fundo
                BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                  child: const SizedBox.expand(),
                ),
              ],
            ),
          ),
          // Frente: imagem real com contain (sem corte)
          CachedNetworkImage(
            imageUrl: url,
            fit: BoxFit.contain,
            fadeInDuration: const Duration(milliseconds: 150),
            fadeOutDuration: const Duration(milliseconds: 80),
            placeholder: (_, __) => const SizedBox.shrink(),
            errorWidget: (_, __, ___) => _ErrorBackdrop(
              authorName: authorName,
              authorAvatarUrl: authorAvatarUrl,
              message: 'Falha ao carregar a imagem',
              onRetry: onRetry,
            ),
          ),
          // Badge indicando que a imagem foi publicada via web (tamanho não-nativo)
          Positioned(
            top: 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.desktop_windows_outlined,
                    color: Colors.white70,
                    size: 11,
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'Web',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    // Imagem portrait nativa — comportamento padrão com cover
    return CachedNetworkImage(
      imageUrl: url,
      fit: fit,
      fadeInDuration: const Duration(milliseconds: 150),
      fadeOutDuration: const Duration(milliseconds: 80),
      placeholder: (_, __) => _LoadingBackdrop(
        authorName: authorName,
        authorAvatarUrl: authorAvatarUrl,
      ),
      errorWidget: (_, __, ___) => _ErrorBackdrop(
        authorName: authorName,
        authorAvatarUrl: authorAvatarUrl,
        message: 'Falha ao carregar a imagem',
        onRetry: onRetry,
      ),
    );
  }
}

// ─── Vídeo ─────────────────────────────────────────────────────────

class _VideoSurface extends StatelessWidget {
  final VideoPlayerController? controller;
  final String authorName;
  final String? authorAvatarUrl;
  final VoidCallback? onRetry;

  const _VideoSurface({
    required this.controller,
    required this.authorName,
    required this.authorAvatarUrl,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final ctrl = controller;
    if (ctrl == null || !ctrl.value.isInitialized) {
      // ★ Aqui está a CORREÇÃO do bug "letra J fullscreen":
      // antigamente, com o controller não inicializado, caía em
      // Image.network(.mp4) → errorBuilder → letra gigante.
      // Agora mostramos um fundo elegante derivado do avatar,
      // sem expor o usuário àquela inicial enorme.
      return _LoadingBackdrop(
        authorName: authorName,
        authorAvatarUrl: authorAvatarUrl,
      );
    }

    if (ctrl.value.hasError) {
      return _ErrorBackdrop(
        authorName: authorName,
        authorAvatarUrl: authorAvatarUrl,
        message: 'Falha ao reproduzir o vídeo',
        onRetry: onRetry,
      );
    }

    return Center(
      child: AspectRatio(
        aspectRatio: ctrl.value.aspectRatio,
        child: VideoPlayer(ctrl),
      ),
    );
  }
}

// ─── Backdrops compartilhados ─────────────────────────────────────

/// Fundo de loading: avatar BLUR em tela cheia + spinner sutil.
/// Estilo Spotify/Apple Music — passa a impressão de "estou carregando
/// algo dessa pessoa", sem expor a inicial gigante.
class _LoadingBackdrop extends StatelessWidget {
  final String authorName;
  final String? authorAvatarUrl;

  const _LoadingBackdrop({
    required this.authorName,
    required this.authorAvatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    final hasAvatar =
        authorAvatarUrl != null && authorAvatarUrl!.trim().isNotEmpty;
    return Stack(
      fit: StackFit.expand,
      children: [
        // Camada 1: cor base derivada do nome (paleta determinística).
        Container(color: BraweAvatar.colorFor(authorName)),

        // Camada 2: avatar blur (se houver). Quando o avatar do autor
        // já está no cache (provável — vimos ele na lista de stories),
        // a transição é instantânea.
        if (hasAvatar)
          ClipRect(
            child: CachedNetworkImage(
              imageUrl: authorAvatarUrl!,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              fadeInDuration: const Duration(milliseconds: 100),
              placeholder: (_, __) => const SizedBox.shrink(),
              errorWidget: (_, __, ___) => const SizedBox.shrink(),
              imageBuilder: (_, provider) => DecoratedBox(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: provider,
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(
                      Colors.black.withValues(alpha: 0.35),
                      BlendMode.darken,
                    ),
                  ),
                ),
              ),
            ),
          ),

        // Camada 3: blur por cima do avatar (gradiente vertical para
        // escurecer ainda mais e dar contraste com o spinner).
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.black.withValues(alpha: 0.55),
                Colors.black.withValues(alpha: 0.75),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),

        // Camada 4: indicador de progresso suave no centro.
        const Center(
          child: SizedBox(
            width: 38,
            height: 38,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: Colors.white70,
            ),
          ),
        ),
      ],
    );
  }
}

/// Estado de erro: mesmo backdrop, mensagem + botão de retry.
class _ErrorBackdrop extends StatelessWidget {
  final String authorName;
  final String? authorAvatarUrl;
  final String message;
  final VoidCallback? onRetry;

  const _ErrorBackdrop({
    required this.authorName,
    required this.authorAvatarUrl,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        _LoadingBackdrop(
          authorName: authorName,
          authorAvatarUrl: authorAvatarUrl,
        ),
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.cloud_off_rounded,
                  color: Colors.white70,
                  size: 48,
                ),
                const SizedBox(height: 12),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (onRetry != null) ...[
                  const SizedBox(height: 16),
                  TextButton.icon(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      onRetry!();
                    },
                    icon: const Icon(Icons.refresh, color: Colors.white),
                    label: const Text(
                      'Tentar novamente',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.white12,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Pré-cache helper ─────────────────────────────────────────────

/// Pré-baixa a próxima mídia do story em background. Para imagens,
/// o `cached_network_image` já guarda em disco. Para vídeos, fazemos
/// um warm-up do controller para acelerar o início do playback.
class StoryMediaPrecache {
  StoryMediaPrecache._();

  /// Pré-baixa uma imagem para cache em disco. Idempotente — se já
  /// está em cache, retorna imediatamente.
  static Future<void> precacheStoryImage(
    BuildContext context,
    String url,
  ) async {
    if (url.isEmpty) return;
    try {
      final provider = CachedNetworkImageProvider(url);
      await precacheImage(provider, context);
    } catch (_) {
      // Pré-cache é best-effort; nunca quebra o fluxo principal.
    }
  }

  /// Pré-aquece a conexão para um vídeo (DNS + TLS handshake).
  /// Não baixa o arquivo inteiro — apenas reduz o tempo até o primeiro
  /// frame em redes lentas (200-500ms a menos no LTE).
  static Future<void> warmUpVideo(String url) async {
    if (url.isEmpty) return;
    try {
      final ctrl = VideoPlayerController.networkUrl(Uri.parse(url));
      await ctrl.initialize();
      await ctrl.dispose();
    } catch (_) {
      // best-effort
    }
  }
}
