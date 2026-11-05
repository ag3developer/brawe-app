import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../../../data/services/gift_effect_cache.dart';
import '../../../data/services/sfx_player.dart';
import '../../../domain/models/battle_assets.dart';

/// Acesso aos arquivos de mídia da batalha já baixados (manifesto §19.2).
/// Só usa o que JÁ está no aparelho: a batalha nunca espera por mídia.
class BattleMedia {
  BattleMedia._();

  static File? file(String? url) => GiftEffectCache.instance.cachedFile(url);

  /// Há Lottie/imagem utilizável (arquivo já baixado)?
  static bool hasVisual(String? lottieUrl, String? imageUrl) =>
      file(lottieUrl) != null || file(imageUrl) != null;

  static bool momentReady(BattleMoment? m) =>
      m != null && hasVisual(m.lottieUrl, m.imageUrl);

  /// Toca o som (se houver e se já estiver baixado/baixável rápido). Reusa o
  /// mesmo motor de SFX dos presentes; nunca lança.
  static void play(String? soundUrl) {
    if (soundUrl == null || soundUrl.isEmpty) return;
    unawaited(SfxPlayer.instance.play(soundUrl));
  }
}

/// Lottie ou imagem (WebP animado/PNG) de um arquivo local. Sem arquivo ou
/// com erro de decodificação não desenha nada.
class BattleMediaView extends StatelessWidget {
  const BattleMediaView({
    super.key,
    this.lottieUrl,
    this.imageUrl,
    this.loop = false,
    this.fit = BoxFit.contain,
  });

  final String? lottieUrl;
  final String? imageUrl;
  final bool loop;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final lf = BattleMedia.file(lottieUrl);
    final imf = BattleMedia.file(imageUrl);
    Widget image(File f) => Image.file(
      f,
      fit: fit,
      gaplessPlayback: true,
      errorBuilder: (_, _, _) => const SizedBox.shrink(),
    );
    if (lf != null) {
      return Lottie.file(
        lf,
        repeat: loop,
        fit: fit,
        errorBuilder: (_, _, _) =>
            imf != null ? image(imf) : const SizedBox.shrink(),
      );
    }
    if (imf != null) return image(imf);
    return const SizedBox.shrink();
  }
}

/// [BattleMediaView] que some sozinho depois de [duration] (rajada curta).
class BattleMediaBurst extends StatefulWidget {
  const BattleMediaBurst({
    super.key,
    required this.moment,
    this.onDone,
    this.defaultDuration = const Duration(milliseconds: 2200),
  });

  final BattleMoment moment;
  final VoidCallback? onDone;
  final Duration defaultDuration;

  @override
  State<BattleMediaBurst> createState() => _BattleMediaBurstState();
}

class _BattleMediaBurstState extends State<BattleMediaBurst> {
  Timer? _t;
  bool _gone = false;

  @override
  void initState() {
    super.initState();
    final ms = widget.moment.durationMs;
    final d = ms != null && ms > 0
        ? Duration(milliseconds: ms)
        : widget.defaultDuration;
    _t = Timer(d, () {
      if (!mounted) return;
      setState(() => _gone = true);
      widget.onDone?.call();
    });
  }

  @override
  void dispose() {
    _t?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_gone) return const SizedBox.shrink();
    return IgnorePointer(
      child: BattleMediaView(
        lottieUrl: widget.moment.lottieUrl,
        imageUrl: widget.moment.imageUrl,
        loop: widget.moment.loop,
      ),
    );
  }
}
