import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../domain/models/gif_item.dart';
import '../../../../gen/l10n/app_localizations.dart';
import '../../../core/themes/brawe_colors.dart';

/// GIF em comentário ou mensagem: cantos arredondados, proporção mantida,
/// largura máxima ~220, anima em loop (mudo por natureza) e toque pausa/retoma.
class GifBubble extends StatefulWidget {
  const GifBubble({super.key, required this.gif, this.maxWidth = 220, this.borderRadius = 14});

  final GifAttachment gif;
  final double maxWidth;
  final double borderRadius;

  @override
  State<GifBubble> createState() => _GifBubbleState();
}

class _GifBubbleState extends State<GifBubble> {
  bool? _paused; // null = segue a preferência de "reduzir movimento"

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final paused = _paused ?? MediaQuery.disableAnimationsOf(context);
    return LayoutBuilder(
      builder: (context, box) {
        final avail = box.maxWidth.isFinite ? box.maxWidth : widget.maxWidth;
        var w = widget.maxWidth < avail ? widget.maxWidth : avail;
        if (widget.gif.width < w) w = widget.gif.width.toDouble();
        if (w < 80) w = avail < 80 ? avail : 80;
        var h = w / widget.gif.aspectRatio;
        if (h > 320) {
          h = 320;
          w = h * widget.gif.aspectRatio;
        }
        return Semantics(
          image: true,
          label: S.of(context).gifSemantics,
          hint: paused ? S.of(context).gifTapToPlay : S.of(context).gifTapToPause,
          child: GestureDetector(
            onTap: () => setState(() => _paused = !paused),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              child: SizedBox(
                width: w,
                height: h,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ColoredBox(color: c.shimmerBase),
                    // TickerMode desligado congela o quadro atual do GIF.
                    TickerMode(
                      enabled: !paused,
                      child: Image.network(
                        widget.gif.url,
                        fit: BoxFit.cover,
                        gaplessPlayback: true,
                        excludeFromSemantics: true,
                        errorBuilder: (_, _, _) => Center(child: Icon(LucideIcons.imageOff, size: 22, color: c.textTertiary)),
                      ),
                    ),
                    if (paused)
                      Center(
                        child: DecoratedBox(
                          decoration: BoxDecoration(color: c.overlay, shape: BoxShape.circle),
                          child: const Padding(
                            padding: EdgeInsets.all(8),
                            child: Icon(LucideIcons.play, size: 20, color: Colors.white),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
