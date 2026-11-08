// Brawe Ads — prévia do post impulsionado em cada espaço do app (Para você, Feed, Stories, Lives e Explorar).
// Desenho estático (sem contar exibição), no mesmo visual dos anúncios reais, dentro de um "celular" em escala.

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/network/media_headers.dart';
import '../../../gen/l10n/app_localizations.dart';
import '../../core/themes/brawe_colors.dart';

/// O que aparece na prévia (vem do post que está sendo impulsionado).
class BoostPreviewData {
  const BoostPreviewData({
    required this.name,
    this.avatarUrl,
    this.imageUrl,
    this.text,
    this.isVideo = false,
    this.verified = false,
  });
  final String name;
  final String? avatarUrl;
  final String? imageUrl; // foto ou capa do vídeo
  final String? text;
  final bool isVideo;
  final bool verified;
}

class BoostPlacementPreview extends StatefulWidget {
  const BoostPlacementPreview({
    super.key,
    required this.data,
    required this.ctaLabel,
    required this.placements,
  });
  final BoostPreviewData data;
  final String ctaLabel;

  /// espaços liberados para impulsionar (config do servidor)
  final List<String> placements;

  @override
  State<BoostPlacementPreview> createState() => _BoostPlacementPreviewState();
}

class _BoostPlacementPreviewState extends State<BoostPlacementPreview> {
  int _page = 0;
  PageController? _pc;
  double? _fraction;

  @override
  void dispose() {
    _pc?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final colors = context.colors;
    final p = widget.placements.toSet();
    final items = <(String, Widget)>[
      if (p.contains('foryou') || p.contains('following'))
        (s.boostPlForYou, _ForYouMock(d: widget.data, cta: widget.ctaLabel)),
      if (p.contains('foryou') || p.contains('following'))
        (s.boostPlFeed, _FeedMock(d: widget.data, cta: widget.ctaLabel)),
      if (p.contains('stories'))
        (s.boostPlStories, _StoryMock(d: widget.data, cta: widget.ctaLabel)),
      if (p.contains('lives') || p.contains('explore'))
        (s.boostPlTiles, _TilesMock(d: widget.data, cta: widget.ctaLabel)),
    ];
    if (items.isEmpty) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, box) {
        // celular de ~190 px de largura no telefone, maior em tablet
        final phoneW = (box.maxWidth * 0.52).clamp(170.0, 240.0);
        final fraction = ((phoneW + 16) / box.maxWidth).clamp(0.3, 0.9);
        if (_fraction != fraction) {
          _pc?.dispose();
          _pc = PageController(viewportFraction: fraction, initialPage: _page);
          _fraction = fraction;
        }
        final phoneH = phoneW * 19.5 / 9;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: phoneH + 34,
              child: PageView.builder(
                controller: _pc,
                padEnds: false,
                itemCount: items.length,
                onPageChanged: (i) => setState(() => _page = i),
                itemBuilder: (_, i) => Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        items[i].$1,
                        style: TextStyle(
                          color: i == _page
                              ? colors.textPrimary
                              : colors.textSecondary,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _Phone(width: phoneW, child: items[i].$2),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < items.length; i++)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: i == _page ? 16 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: i == _page
                          ? colors.accentPrimary
                          : colors.surfaceHighest,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
              ],
            ),
          ],
        );
      },
    );
  }
}

/// Moldura do celular. O conteúdo é desenhado em 360×780 e reduzido para caber.
class _Phone extends StatelessWidget {
  const _Phone({required this.width, required this.child});
  final double width;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      width: width,
      height: width * 19.5 / 9,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(width * 0.13),
        boxShadow: [
          BoxShadow(
            color: colors.overlay.withValues(alpha: 0.18),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(width * 0.11),
        child: FittedBox(
          fit: BoxFit.cover,
          alignment: Alignment.topCenter,
          child: SizedBox(
            width: 360,
            height: 780,
            child: IgnorePointer(child: child),
          ),
        ),
      ),
    );
  }
}

Widget _media(BoostPreviewData d, {BoxFit fit = BoxFit.cover}) {
  final u = d.imageUrl;
  if (u == null || u.isEmpty) return const ColoredBox(color: Color(0xFF2A2A2E));
  return CachedNetworkImage(
    imageUrl: u,
    httpHeaders: mediaHeadersFor(u),
    fit: fit,
    errorWidget: (_, _, _) => const ColoredBox(color: Color(0xFF2A2A2E)),
  );
}

Widget _avatar(BoostPreviewData d, double r, {Color bg = Colors.white24}) =>
    CircleAvatar(
      radius: r,
      backgroundColor: bg,
      backgroundImage: (d.avatarUrl ?? '').isNotEmpty
          ? CachedNetworkImageProvider(
              d.avatarUrl!,
              headers: mediaHeadersFor(d.avatarUrl),
            )
          : null,
    );

// ── Para você (tela cheia) ──────────────────────────────────────────────

class _ForYouMock extends StatelessWidget {
  const _ForYouMock({required this.d, required this.cta});
  final BoostPreviewData d;
  final String cta;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return ColoredBox(
      color: Colors.black,
      child: Stack(
        fit: StackFit.expand,
        children: [
          _media(d),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0x55000000),
                  Colors.transparent,
                  Colors.transparent,
                  Color(0xCC000000),
                ],
                stops: [0, 0.16, 0.55, 1],
              ),
            ),
          ),
          // abas do topo
          Positioned(
            top: 52,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  s.adsRepPlFollowing,
                  style: const TextStyle(
                    color: Colors.white60,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 20),
                Text(
                  s.boostPlForYou,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          // trilho da direita
          Positioned(
            right: 12,
            bottom: 190,
            child: Column(
              children: [
                _avatar(d, 22),
                const SizedBox(height: 22),
                const Icon(LucideIcons.volumeX, color: Colors.white, size: 26),
                const SizedBox(height: 22),
                const Icon(LucideIcons.ellipsis, color: Colors.white, size: 26),
              ],
            ),
          ),
          Positioned(
            left: 16,
            right: 72,
            bottom: 40,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  d.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${s.adsSponsored}${d.isVideo ? ' · 0:12' : ''}',
                  style: const TextStyle(color: Colors.white70, fontSize: 13.5),
                ),
                if ((d.text ?? '').trim().isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    d.text!.trim(),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14.5,
                      height: 1.35,
                    ),
                  ),
                ],
                const SizedBox(height: 14),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2563EB),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    cta,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 22,
            child: Container(
              height: 2.5,
              alignment: Alignment.centerLeft,
              color: Colors.white24,
              child: const FractionallySizedBox(
                widthFactor: 0.35,
                child: ColoredBox(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Feed de posts ───────────────────────────────────────────────────────

class _FeedMock extends StatelessWidget {
  const _FeedMock({required this.d, required this.cta});
  final BoostPreviewData d;
  final String cta;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final c = context.colors;
    return ColoredBox(
      color: c.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 50),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Text(
                  s.boostPlFeed,
                  style: TextStyle(
                    color: c.textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const Spacer(),
                Icon(LucideIcons.search, color: c.textSecondary, size: 22),
              ],
            ),
          ),
          Divider(height: 1, color: c.divider),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              children: [
                _avatar(d, 18, bg: c.surfaceHighest),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        d.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: c.textPrimary,
                          fontSize: 14.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        s.adsSponsored,
                        style: TextStyle(color: c.textSecondary, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Icon(LucideIcons.ellipsis, color: c.textSecondary, size: 20),
              ],
            ),
          ),
          if ((d.text ?? '').trim().isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 8, 14, 10),
              child: Text(
                d.text!.trim(),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: c.textPrimary,
                  fontSize: 14.5,
                  height: 1.4,
                ),
              ),
            )
          else
            const SizedBox(height: 10),
          AspectRatio(aspectRatio: 4 / 5, child: _media(d)),
          Container(
            color: c.surfaceHighest,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    cta,
                    style: TextStyle(
                      color: c.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Icon(LucideIcons.chevronRight, size: 18, color: c.textPrimary),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
            child: Row(
              children: [
                Icon(LucideIcons.heart, size: 22, color: c.textSecondary),
                const SizedBox(width: 18),
                Icon(
                  LucideIcons.messageCircle,
                  size: 22,
                  color: c.textSecondary,
                ),
                const Spacer(),
                Icon(LucideIcons.send, size: 22, color: c.textSecondary),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Stories ─────────────────────────────────────────────────────────────

class _StoryMock extends StatelessWidget {
  const _StoryMock({required this.d, required this.cta});
  final BoostPreviewData d;
  final String cta;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return ColoredBox(
      color: Colors.black,
      child: Stack(
        fit: StackFit.expand,
        children: [
          _media(d),
          const DecoratedBox(
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
          Positioned(
            top: 50,
            left: 10,
            right: 10,
            child: Column(
              children: [
                Container(
                  height: 3,
                  alignment: Alignment.centerLeft,
                  decoration: BoxDecoration(
                    color: Colors.white30,
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: FractionallySizedBox(
                    widthFactor: 0.4,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _avatar(d, 17),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            d.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            s.adsSponsored,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      LucideIcons.ellipsis,
                      color: Colors.white,
                      size: 22,
                    ),
                    const SizedBox(width: 14),
                    const Icon(LucideIcons.x, color: Colors.white, size: 24),
                  ],
                ),
              ],
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 44,
            child: Column(
              children: [
                const Icon(
                  LucideIcons.chevronUp,
                  color: Colors.white70,
                  size: 22,
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    cta,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Lives e Explorar (quadro na grade) ──────────────────────────────────

class _TilesMock extends StatelessWidget {
  const _TilesMock({required this.d, required this.cta});
  final BoostPreviewData d;
  final String cta;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final c = context.colors;
    Widget placeholder() => Container(
      decoration: BoxDecoration(
        color: c.surfaceHighest,
        borderRadius: BorderRadius.circular(12),
      ),
    );
    return ColoredBox(
      color: c.background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 50),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Text(
              s.adsRepPlLives,
              style: TextStyle(
                color: c.textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 0.72,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                placeholder(),
                // o quadro patrocinado, igual ao real
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      _media(d),
                      const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Color(0x66000000),
                              Colors.transparent,
                              Color(0xCC000000),
                            ],
                            stops: [0, 0.35, 1],
                          ),
                        ),
                      ),
                      Positioned(
                        top: 8,
                        left: 9,
                        right: 6,
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                s.adsSponsored,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            const Icon(
                              LucideIcons.ellipsis,
                              color: Colors.white,
                              size: 16,
                            ),
                          ],
                        ),
                      ),
                      if (d.isVideo)
                        const Center(
                          child: Icon(
                            LucideIcons.play,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                      Positioned(
                        left: 9,
                        right: 9,
                        bottom: 9,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              d.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(7),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                cta,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                placeholder(),
                placeholder(),
                placeholder(),
                placeholder(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
