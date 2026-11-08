// Brawe Ads — quadro "Patrocinado" para grades e carrosséis (lista de lives, Explorar).
// Mesmo formato dos cards ao lado; rótulo discreto no canto. Impressão: ≥ 50% visível por 1 s.

import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../../core/network/media_headers.dart';
import '../../../data/repositories/ads_repository.dart';
import '../../../domain/models/ad_models.dart';
import '../../../gen/l10n/app_localizations.dart';
import '../../core/ui/verified_badge.dart';
import 'ad_actions.dart';

class SponsoredTile extends ConsumerStatefulWidget {
  const SponsoredTile({super.key, required this.ad, this.width});
  final FeedAd ad;
  final double? width;

  @override
  ConsumerState<SponsoredTile> createState() => _SponsoredTileState();
}

class _SponsoredTileState extends ConsumerState<SponsoredTile> {
  Timer? _t;
  bool _sent = false;

  @override
  void dispose() {
    _t?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ad = widget.ad;
    final url = ad.isVideo || ad.isLive
        ? (ad.posterUrl ?? ad.mediaUrl)
        : (ad.mediaUrl ?? ad.posterUrl);
    final adv = ad.advertiser;
    return VisibilityDetector(
      key: ValueKey('tile-${ad.token}'),
      onVisibilityChanged: (v) {
        if (_sent) return;
        if (v.visibleFraction >= 0.5) {
          _t ??= Timer(const Duration(seconds: 1), () {
            _sent = true;
            ref.read(adsRepositoryProvider).track(ad.token, 'impression');
          });
        } else {
          _t?.cancel();
          _t = null;
        }
      },
      child: SizedBox(
        width: widget.width,
        child: GestureDetector(
          onTap: () => openAdMedia(context, ref, ad),
          onLongPress: () => showAdMenu(context, ref, ad),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (url != null)
                  CachedNetworkImage(
                    imageUrl: url,
                    httpHeaders: mediaHeadersFor(url),
                    fit: BoxFit.cover,
                  )
                else
                  const ColoredBox(color: Colors.black26),
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
                  top: 6,
                  left: 8,
                  right: 4,
                  child: Row(
                    children: [
                      Expanded(
                        child: SponsoredLabel(color: Colors.white, size: 11),
                      ),
                      GestureDetector(
                        onTap: () => showAdMenu(context, ref, ad),
                        child: const Padding(
                          padding: EdgeInsets.all(4),
                          child: Icon(
                            LucideIcons.ellipsis,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (ad.isVideo || ad.isLive)
                  Center(
                    child: Icon(
                      ad.isLive ? LucideIcons.radio : LucideIcons.play,
                      color: Colors.white.withValues(alpha: 0.9),
                      size: 28,
                    ),
                  ),
                Positioned(
                  left: 8,
                  right: 8,
                  bottom: 8,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
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
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          if (adv?.isVerified == true)
                            const Padding(
                              padding: EdgeInsets.only(left: 3),
                              child: VerifiedBadge(size: 12),
                            ),
                        ],
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
                          adCtaLabel(context, ref, ad),
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
        ),
      ),
    );
  }
}

/// Texto curto "Patrocinado" para leitores de tela (o quadro inteiro é um anúncio).
String sponsoredSemantics(BuildContext context, FeedAd ad) =>
    '${S.of(context).adsSponsored}: ${ad.advertiser?.displayName ?? ''}';
