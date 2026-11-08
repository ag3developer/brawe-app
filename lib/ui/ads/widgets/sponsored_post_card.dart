// Brawe Ads — card "Patrocinado" no feed de posts (mesmo visual do post).
// Faixa de ação colada embaixo da mídia (estilo Instagram). Impressão: ≥ 50% visível por 1 s.

import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../../core/network/media_headers.dart';
import '../../../data/repositories/ads_repository.dart';
import '../../../domain/models/ad_models.dart';
import '../../core/themes/brawe_colors.dart';
import '../../core/ui/verified_badge.dart';
import '../../home/view_models/feed_video_mute_provider.dart';
import 'ad_actions.dart';

class SponsoredPostCard extends ConsumerStatefulWidget {
  const SponsoredPostCard({super.key, required this.ad});
  final FeedAd ad;

  @override
  ConsumerState<SponsoredPostCard> createState() => _SponsoredPostCardState();
}

class _SponsoredPostCardState extends ConsumerState<SponsoredPostCard> {
  Timer? _seen;
  bool _impression = false;
  bool _visible = false;
  VideoPlayerController? _ctrl;
  bool _ready = false;
  final Set<String> _quartiles = {};

  FeedAd get ad => widget.ad;

  @override
  void dispose() {
    _seen?.cancel();
    _ctrl?.dispose();
    super.dispose();
  }

  void _onVisibility(VisibilityInfo info) {
    final visible = info.visibleFraction >= 0.5;
    if (visible == _visible) return;
    _visible = visible;
    if (visible) {
      if (!_impression) {
        _seen = Timer(const Duration(seconds: 1), () {
          _impression = true;
          ref.read(adsRepositoryProvider).track(ad.token, 'impression');
        });
      }
      if (ad.isVideo) _playVideo();
    } else {
      _seen?.cancel();
      _ctrl?.pause();
    }
  }

  Future<void> _playVideo() async {
    if (_ctrl == null) {
      final url = ad.playbackUrl;
      if (url == null || url.isEmpty) return;
      final c = VideoPlayerController.networkUrl(
        Uri.parse(url),
        httpHeaders: mediaHeadersFor(url),
        videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
      );
      _ctrl = c;
      try {
        await c.initialize();
        await c.setLooping(true);
        await c.setVolume(ref.read(feedVideoMuteProvider) ? 0 : 1);
        c.addListener(_onTick);
        if (mounted) setState(() => _ready = true);
      } catch (_) {
        return;
      }
    }
    if (_visible) _ctrl?.play();
  }

  void _onTick() {
    final c = _ctrl;
    if (c == null) return;
    final d = c.value.duration.inMilliseconds;
    if (d <= 0) return;
    final p = c.value.position.inMilliseconds / d;
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

  @override
  Widget build(BuildContext context) {
    if (ref.watch(
      hiddenAdsProvider.select(
        (h) => h.contains(ad.adId) || h.contains('owner:${ad.advertiser?.id}'),
      ),
    )) {
      return const SizedBox.shrink();
    }
    final colors = context.colors;
    final adv = ad.advertiser;
    final text = [
      ad.headline,
      ad.text,
    ].whereType<String>().where((s) => s.trim().isNotEmpty).toList();
    final width = MediaQuery.sizeOf(context).width;
    // tablet/landscape: a mídia não passa de 600 px de largura (fica centralizada como o post)
    final mediaMax = width > 680 ? 600.0 : width;

    return VisibilityDetector(
      key: ValueKey('ad-${ad.token}'),
      onVisibilityChanged: _onVisibility,
      child: Container(
        color: colors.surface,
        padding: const EdgeInsets.only(top: 12, bottom: 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // cabeçalho: avatar, nome, "Patrocinado" e ⋯
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => openAdvertiserProfile(context, ref, ad),
                    child: CircleAvatar(
                      radius: 18,
                      backgroundColor: colors.surfaceHighest,
                      backgroundImage: (adv?.avatarUrl ?? '').isNotEmpty
                          ? CachedNetworkImageProvider(
                              adv!.avatarUrl!,
                              headers: mediaHeadersFor(adv.avatarUrl),
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => openAdvertiserProfile(context, ref, ad),
                      behavior: HitTestBehavior.opaque,
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
                                  style: TextStyle(
                                    color: colors.textPrimary,
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              if (adv?.isVerified == true)
                                const VerifiedBadge(size: 13),
                            ],
                          ),
                          SponsoredLabel(color: colors.textSecondary, size: 12),
                        ],
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      LucideIcons.ellipsis,
                      color: colors.textSecondary,
                      size: 20,
                    ),
                    onPressed: () => showAdMenu(context, ref, ad),
                  ),
                ],
              ),
            ),
            if (text.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 6, 14, 10),
                child: Text(
                  text.join('\n'),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontSize: 14.5,
                    height: 1.4,
                  ),
                ),
              ),
            // mídia + faixa de ação colada
            Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: mediaMax),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () => openAdCta(context, ref, ad),
                      child: AspectRatio(
                        aspectRatio: _ready && _ctrl != null
                            ? _ctrl!.value.aspectRatio.clamp(0.8, 1.91)
                            : 4 / 5,
                        child: _media(colors),
                      ),
                    ),
                    Material(
                      color: colors.surfaceHighest,
                      child: InkWell(
                        onTap: () => openAdCta(context, ref, ad),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  adCtaLabel(context, ad),
                                  style: TextStyle(
                                    color: colors.textPrimary,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Icon(
                                LucideIcons.chevronRight,
                                size: 18,
                                color: colors.textPrimary,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 6),
            Divider(height: 0.5, thickness: 0.5, color: colors.divider),
          ],
        ),
      ),
    );
  }

  Widget _media(BraweColors colors) {
    final c = _ctrl;
    if (ad.isVideo && _ready && c != null) {
      return Stack(
        fit: StackFit.expand,
        children: [
          FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: c.value.size.width,
              height: c.value.size.height,
              child: VideoPlayer(c),
            ),
          ),
          Positioned(
            right: 10,
            bottom: 10,
            child: GestureDetector(
              onTap: () => ref.read(feedVideoMuteProvider.notifier).toggle(),
              child: Consumer(
                builder: (_, r, _) {
                  final muted = r.watch(feedVideoMuteProvider);
                  c.setVolume(muted ? 0 : 1);
                  return Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      muted ? LucideIcons.volumeX : LucideIcons.volume2,
                      color: Colors.white,
                      size: 16,
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      );
    }
    final url = ad.isVideo || ad.isLive
        ? (ad.posterUrl ?? ad.mediaUrl)
        : (ad.mediaUrl ?? ad.posterUrl);
    if (url == null || url.isEmpty) {
      return ColoredBox(color: colors.surfaceHighest);
    }
    return Stack(
      fit: StackFit.expand,
      children: [
        CachedNetworkImage(
          imageUrl: url,
          httpHeaders: mediaHeadersFor(url),
          fit: BoxFit.cover,
        ),
        if (ad.isLive)
          Positioned(
            left: 10,
            top: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFE11D48),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'LIVE',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
