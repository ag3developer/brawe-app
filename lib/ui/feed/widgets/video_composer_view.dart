import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../gen/l10n/app_localizations.dart';
import '../../core/themes/brawe_colors.dart';

/// Campo de legenda do vídeo — só tokens do tema (claro/escuro), sem cores
/// fixas. Publicar sem legenda é permitido (é conteúdo, não formulário).
class VideoCaptionField extends StatelessWidget {
  const VideoCaptionField({
    super.key,
    required this.controller,
    this.enabled = true,
    this.maxLength = 300,
  });

  final TextEditingController controller;
  final bool enabled;
  final int maxLength;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: c.border),
      ),
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
      child: TextField(
        controller: controller,
        enabled: enabled,
        minLines: 2,
        maxLines: 4,
        maxLength: maxLength,
        textCapitalization: TextCapitalization.sentences,
        keyboardType: TextInputType.multiline,
        style: TextStyle(color: c.textPrimary, fontSize: 15, height: 1.35),
        cursorColor: c.accentPrimary,
        decoration: InputDecoration(
          // O tema global usa `filled` (surfaceHighest); aqui o cartão já
          // tem fundo próprio, então o campo é transparente.
          filled: false,
          fillColor: Colors.transparent,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
          isCollapsed: true,
          contentPadding: const EdgeInsets.only(bottom: 6),
          hintText: S.of(context).videoCaptionHint,
          hintStyle: TextStyle(color: c.textSecondary, fontSize: 15),
        ),
        buildCounter:
            (
              context, {
              required currentLength,
              required isFocused,
              required maxLength,
            }) => Align(
              alignment: Alignment.centerRight,
              child: Text(
                '$currentLength/$maxLength',
                style: TextStyle(
                  color: currentLength >= (maxLength ?? 1) * 0.95
                      ? c.warning
                      : c.textSecondary,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
      ),
    );
  }
}

/// Layout puro (sem player/IO) da tela "Novo vídeo". O estado e os efeitos
/// ficam em `CreateVideoSheet`; aqui só tema, responsividade e teclado.
class VideoComposerView extends StatelessWidget {
  const VideoComposerView({
    super.key,
    required this.hasVideo,
    required this.preview,
    required this.aspectRatio,
    required this.emptyState,
    required this.captionController,
    required this.onClose,
    required this.onSwap,
    required this.onTrim,
    required this.onCover,
    required this.onSound,
    required this.onPublish,
    required this.onTogglePlay,
    this.playing = true,
    this.durationChip,
    this.soundRow,
    this.cover,
    this.onClearCover,
    this.soundActive = false,
    this.publishing = false,
    this.publishLabel,
    this.progress,
    this.banner,
  });

  final bool hasVideo;
  final Widget preview;
  final double aspectRatio;
  final Widget emptyState;
  final TextEditingController captionController;
  final VoidCallback onClose;
  final VoidCallback onSwap;
  final VoidCallback? onTrim;
  final VoidCallback? onCover;
  final VoidCallback? onSound;
  final VoidCallback? onPublish;
  final VoidCallback onTogglePlay;
  final bool playing;
  final Widget? durationChip;
  final Widget? soundRow;
  final File? cover;
  final VoidCallback? onClearCover;
  final bool soundActive;
  final bool publishing;
  final String? publishLabel;
  final double? progress;

  /// Aviso inline (ex.: vídeo grande demais) logo abaixo do cabeçalho.
  final Widget? banner;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final s = S.of(context);
    return LayoutBuilder(
      builder: (context, box) {
        // Reserva cabeçalho + botão (escalam com o texto); o bloco de
        // ferramentas/legenda rola no que sobrar — o preview encolhe antes.
        final scale = MediaQuery.textScalerOf(context).scale(1);
        final headerH = math.max(40.0, 24 * scale) + 22;
        final buttonH =
            math.max(54.0, 21 * scale + 28) +
            24 +
            MediaQuery.of(context).padding.bottom;
        final maxBlock = math.max(
          0.0,
          math.min(box.maxHeight * 0.62, box.maxHeight - headerH - buttonH),
        );
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
              child: Row(
                children: [
                  _RoundBtn(
                    icon: LucideIcons.x,
                    tooltip: MaterialLocalizations.of(
                      context,
                    ).closeButtonTooltip,
                    onTap: onClose,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      s.videoSheetTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: c.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ),
                  if (hasVideo)
                    _RoundBtn(
                      icon: LucideIcons.refreshCw,
                      tooltip: s.videoSwapTooltip,
                      onTap: onSwap,
                    ),
                ],
              ),
            ),
            if (banner != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: banner!,
              ),
            Expanded(
              child: hasVideo
                  ? LayoutBuilder(
                      builder: (context, b) {
                        final ar = aspectRatio.clamp(0.4, 2.4);
                        final w = math.min(b.maxWidth - 32, b.maxHeight * ar);
                        final h = w / ar;
                        if (h < 72 || w <= 0) return const SizedBox.shrink();
                        return Center(
                          child: SizedBox(
                            width: w,
                            height: h,
                            child: _PreviewCard(
                              preview: preview,
                              playing: playing,
                              onTap: onTogglePlay,
                              chip: durationChip,
                            ),
                          ),
                        );
                      },
                    )
                  : emptyState,
            ),
            if (hasVideo)
              ConstrainedBox(
                constraints: BoxConstraints(maxHeight: maxBlock),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _ToolChip(
                            icon: LucideIcons.scissors,
                            label: s.videoPubTrim,
                            onTap: onTrim,
                          ),
                          _ToolChip(
                            icon: LucideIcons.image,
                            label: cover != null
                                ? s.videoPubCoverCustom
                                : s.videoPubCoverAuto,
                            thumb: cover,
                            onTap: onCover,
                            onClear: onClearCover,
                          ),
                          _ToolChip(
                            icon: LucideIcons.music,
                            label: s.videoPubSound,
                            active: soundActive,
                            onTap: onSound,
                          ),
                        ],
                      ),
                      if (soundRow != null) ...[
                        const SizedBox(height: 10),
                        soundRow!,
                      ],
                      const SizedBox(height: 12),
                      VideoCaptionField(
                        controller: captionController,
                        enabled: !publishing,
                      ),
                    ],
                  ),
                ),
              ),
            if (hasVideo)
              Padding(
                padding: EdgeInsets.fromLTRB(
                  16,
                  12,
                  16,
                  12 + MediaQuery.of(context).padding.bottom,
                ),
                child: _PublishButton(
                  label: s.videoPublishButton,
                  busyLabel: publishLabel,
                  busy: publishing,
                  progress: progress,
                  onTap: onPublish,
                ),
              ),
          ],
        );
      },
    );
  }
}

class _PreviewCard extends StatelessWidget {
  const _PreviewCard({
    required this.preview,
    required this.playing,
    required this.onTap,
    this.chip,
  });

  final Widget preview;
  final bool playing;
  final VoidCallback onTap;
  final Widget? chip;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: c.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(23),
        child: GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: Stack(
            fit: StackFit.expand,
            children: [
              const ColoredBox(color: Colors.black),
              preview,
              if (!playing)
                Center(
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black.withValues(alpha: 0.45),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.7),
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      LucideIcons.play,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ),
              if (chip != null) Positioned(left: 10, bottom: 10, child: chip!),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoundBtn extends StatelessWidget {
  const _RoundBtn({required this.icon, required this.onTap, this.tooltip});
  final IconData icon;
  final VoidCallback onTap;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Tooltip(
      message: tooltip ?? '',
      child: Material(
        color: c.surfaceHighest,
        shape: CircleBorder(side: BorderSide(color: c.border)),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: SizedBox(
            width: 40,
            height: 40,
            child: Icon(icon, color: c.textPrimary, size: 20),
          ),
        ),
      ),
    );
  }
}

class _ToolChip extends StatelessWidget {
  const _ToolChip({
    required this.icon,
    required this.label,
    required this.onTap,
    this.thumb,
    this.onClear,
    this.active = false,
  });

  final IconData icon;
  final String label;
  final File? thumb;
  final VoidCallback? onTap;
  final VoidCallback? onClear;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final fg = active ? c.accentPrimary : c.textPrimary;
    return Opacity(
      opacity: onTap == null ? 0.5 : 1,
      child: Material(
        color: active
            ? c.accentPrimary.withValues(alpha: 0.12)
            : c.surfaceHighest,
        shape: StadiumBorder(
          side: BorderSide(color: active ? c.accentPrimary : c.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            InkWell(
              customBorder: const StadiumBorder(),
              onTap: onTap,
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  thumb != null ? 5 : 12,
                  7,
                  onClear != null ? 6 : 14,
                  7,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (thumb != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Image.file(
                          thumb!,
                          width: 26,
                          height: 26,
                          fit: BoxFit.cover,
                          cacheWidth: 104,
                          errorBuilder: (_, _, _) =>
                              Icon(icon, color: fg, size: 18),
                        ),
                      )
                    else
                      Icon(icon, color: fg, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      label,
                      style: TextStyle(
                        color: fg,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (onClear != null)
              InkWell(
                customBorder: const CircleBorder(),
                onTap: onClear,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(2, 7, 10, 7),
                  child: Icon(LucideIcons.x, color: c.textSecondary, size: 14),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _PublishButton extends StatelessWidget {
  const _PublishButton({
    required this.label,
    required this.busy,
    required this.onTap,
    this.busyLabel,
    this.progress,
  });

  final String label;
  final String? busyLabel;
  final bool busy;
  final double? progress;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final enabled = onTap != null && !busy;
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: (enabled || busy) ? 1 : 0.55,
      child: Container(
        constraints: const BoxConstraints(minHeight: 54),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [c.accentPrimary, c.accentSecondary],
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: enabled
              ? [
                  BoxShadow(
                    color: c.accentPrimary.withValues(alpha: 0.35),
                    blurRadius: 20,
                    spreadRadius: -4,
                    offset: const Offset(0, 8),
                  ),
                ]
              : const [],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: enabled ? onTap : null,
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    child: Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (busy)
                            const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                          else
                            const Icon(
                              LucideIcons.send,
                              color: Colors.white,
                              size: 18,
                            ),
                          const SizedBox(width: 10),
                          Flexible(
                            child: Text(
                              busy ? (busyLabel ?? label) : label,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (busy && progress != null)
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 3,
                        backgroundColor: Colors.white.withValues(alpha: 0.2),
                        valueColor: const AlwaysStoppedAnimation(Colors.white),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
