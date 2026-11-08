// Brawe Ads — anúncio nos Stories (tela cheia, entre grupos de stories).
//
// - Barra de progresso no topo (igual aos stories). Imagem: 5 s. Vídeo: até 15 s.
// - Toque em qualquer lugar à direita ou deslizar para baixo → pula na hora. Segurar → pausa.
// - Cabeçalho: anunciante + "Patrocinado" + ⋯ + fechar. Botão de ação em pílula na base.

import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:video_player/video_player.dart';

import '../../../core/network/media_headers.dart';
import '../../../data/repositories/ads_repository.dart';
import '../../../domain/models/ad_models.dart';
import '../../core/ui/verified_badge.dart';
import 'ad_actions.dart';

/// Quantos grupos de stories a pessoa viu nesta sessão (a cada N entra 1 anúncio).
class _StorySession {
  static int groupsSeen = 0;
  static final List<String> shown = [];
}

/// Chame depois de fechar um grupo de stories. Mostra 1 anúncio a cada N grupos (N vem do servidor).
Future<void> maybeShowStoryAd(BuildContext context, WidgetRef ref) async {
  final seen = ++_StorySession.groupsSeen;
  if (seen < 2) return; // nunca antes do primeiro grupo terminar
  final repo = ref.read(adsRepositoryProvider);
  final res = await repo.serve(
    AdPlacement.stories,
    exclude: _StorySession.shown,
  );
  if (res.items.isEmpty || seen % (res.every <= 0 ? 4 : res.every) != 0) return;
  final ad = res.items.first;
  if (ref.read(hiddenAdsProvider.notifier).isHidden(ad) || !context.mounted) {
    return;
  }
  _StorySession.shown.add(ad.adId);
  await Navigator.of(context, rootNavigator: true).push(
    PageRouteBuilder(
      opaque: false,
      fullscreenDialog: true,
      pageBuilder: (_, _, _) => SponsoredStoryScreen(ad: ad),
      transitionsBuilder: (_, a, _, child) =>
          FadeTransition(opacity: a, child: child),
      transitionDuration: const Duration(milliseconds: 180),
    ),
  );
}

class SponsoredStoryScreen extends ConsumerStatefulWidget {
  const SponsoredStoryScreen({super.key, required this.ad});
  final FeedAd ad;

  @override
  ConsumerState<SponsoredStoryScreen> createState() =>
      _SponsoredStoryScreenState();
}

class _SponsoredStoryScreenState extends ConsumerState<SponsoredStoryScreen>
    with SingleTickerProviderStateMixin {
  static const _imageDuration = Duration(seconds: 5);
  static const _maxVideo = Duration(seconds: 15);

  late final AnimationController _progress = AnimationController(
    vsync: this,
    duration: _imageDuration,
  );
  VideoPlayerController? _ctrl;
  Timer? _impression;
  final Set<String> _quartiles = {};

  FeedAd get ad => widget.ad;

  @override
  void initState() {
    super.initState();
    _progress.addStatusListener((s) {
      if (s == AnimationStatus.completed) _close();
    });
    _impression = Timer(
      const Duration(seconds: 1),
      () => ref.read(adsRepositoryProvider).track(ad.token, 'impression'),
    );
    if (ad.isVideo && (ad.playbackUrl ?? '').isNotEmpty) {
      _initVideo();
    } else {
      _progress.forward();
    }
  }

  Future<void> _initVideo() async {
    final url = ad.playbackUrl!;
    final c = VideoPlayerController.networkUrl(
      Uri.parse(url),
      httpHeaders: mediaHeadersFor(url),
    );
    _ctrl = c;
    try {
      await c.initialize();
      final d = c.value.duration;
      _progress.duration = d > _maxVideo || d == Duration.zero ? _maxVideo : d;
      c.addListener(_onTick);
      await c.play();
      if (mounted) setState(() {});
      _progress.forward();
    } catch (_) {
      _progress.forward();
    }
  }

  void _onTick() {
    final c = _ctrl;
    if (c == null) return;
    final total = _progress.duration!.inMilliseconds;
    final p = c.value.position.inMilliseconds / total;
    for (final (mark, ev) in [
      (0.25, 'view_25'),
      (0.5, 'view_50'),
      (0.97, 'view_100'),
    ]) {
      if (p >= mark && _quartiles.add(ev)) {
        ref
            .read(adsRepositoryProvider)
            .track(ad.token, ev, valueMs: c.value.position.inMilliseconds);
      }
    }
  }

  void _close() {
    if (mounted && Navigator.of(context).canPop()) Navigator.of(context).pop();
  }

  void _pause() {
    _progress.stop();
    _ctrl?.pause();
  }

  void _resume() {
    _progress.forward();
    _ctrl?.play();
  }

  @override
  void dispose() {
    _impression?.cancel();
    _progress.dispose();
    _ctrl?.removeListener(_onTick);
    _ctrl?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final adv = ad.advertiser;
    final pad = MediaQuery.paddingOf(context);
    final text = ad.headline ?? ad.text;
    final c = _ctrl;
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTapUp: (d) {
          // esquerda: recomeça; direita: pula
          if (d.localPosition.dx < MediaQuery.sizeOf(context).width * 0.3) {
            _progress.forward(from: 0);
            _ctrl?.seekTo(Duration.zero);
          } else {
            _close();
          }
        },
        onLongPressStart: (_) => _pause(),
        onLongPressEnd: (_) => _resume(),
        onVerticalDragEnd: (d) {
          if ((d.primaryVelocity ?? 0) > 300) _close();
          if ((d.primaryVelocity ?? 0) < -300) openAdCta(context, ref, ad);
        },
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (c != null && c.value.isInitialized)
              FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: c.value.size.width,
                  height: c.value.size.height,
                  child: VideoPlayer(c),
                ),
              )
            else if ((ad.mediaUrl ?? ad.posterUrl) != null)
              CachedNetworkImage(
                imageUrl:
                    (ad.isVideo ? ad.posterUrl : ad.mediaUrl) ?? ad.mediaUrl!,
                httpHeaders: mediaHeadersFor(ad.mediaUrl),
                fit: BoxFit.cover,
              ),
            const IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0x80000000),
                      Colors.transparent,
                      Colors.transparent,
                      Color(0x99000000),
                    ],
                    stops: [0, 0.18, 0.6, 1],
                  ),
                ),
              ),
            ),
            // progresso + cabeçalho
            Positioned(
              top: pad.top + 8,
              left: 10,
              right: 10,
              child: Column(
                children: [
                  AnimatedBuilder(
                    animation: _progress,
                    builder: (_, _) => ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: LinearProgressIndicator(
                        value: _progress.value,
                        minHeight: 2.5,
                        color: Colors.white,
                        backgroundColor: Colors.white.withValues(alpha: 0.3),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: Colors.white24,
                        backgroundImage: (adv?.avatarUrl ?? '').isNotEmpty
                            ? CachedNetworkImageProvider(
                                adv!.avatarUrl!,
                                headers: mediaHeadersFor(adv.avatarUrl),
                              )
                            : null,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    adv?.displayName ?? '',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                if (adv?.isVerified == true)
                                  const VerifiedBadge(size: 12),
                              ],
                            ),
                            const SponsoredLabel(size: 11.5),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          LucideIcons.ellipsis,
                          color: Colors.white,
                          size: 22,
                        ),
                        onPressed: () async {
                          _pause();
                          await showAdMenu(context, ref, ad, onHidden: _close);
                          if (mounted) _resume();
                        },
                      ),
                      IconButton(
                        icon: const Icon(
                          LucideIcons.x,
                          color: Colors.white,
                          size: 24,
                        ),
                        onPressed: _close,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // texto + botão de ação
            Positioned(
              left: 16,
              right: 16,
              bottom: pad.bottom + 18,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (text != null && text.trim().isNotEmpty) ...[
                    Text(
                      text,
                      textAlign: TextAlign.center,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        height: 1.35,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],
                  const Icon(
                    LucideIcons.chevronUp,
                    color: Colors.white70,
                    size: 20,
                  ),
                  const SizedBox(height: 4),
                  GestureDetector(
                    onTap: () => openAdCta(context, ref, ad),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 22,
                        vertical: 11,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        adCtaLabel(context, ad),
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
