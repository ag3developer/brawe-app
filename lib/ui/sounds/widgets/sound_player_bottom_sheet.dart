import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/themes/app_colors.dart';
import '../../core/themes/brawe_colors.dart';
import '../../../data/repositories/waveform_repository.dart';
import '../../../domain/models/sound.dart';
import '../../../gen/l10n/app_localizations.dart';
import '../view_models/sound_player_view_model.dart';
import '../view_models/sounds_view_model.dart';
import 'waveform_view.dart';

/// Bottom sheet do player de Brawe Sounds.
/// Chamado com:
///   showModalBottomSheet(builder: (_) => SoundPlayerBottomSheet(sound: s))
class SoundPlayerBottomSheet extends ConsumerStatefulWidget {
  const SoundPlayerBottomSheet({super.key, required this.sound});
  final Sound sound;

  @override
  ConsumerState<SoundPlayerBottomSheet> createState() =>
      _SoundPlayerBottomSheetState();
}

class _SoundPlayerBottomSheetState
    extends ConsumerState<SoundPlayerBottomSheet> {
  List<double>? _waveform;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadWaveform());
  }

  Future<void> _loadWaveform() async {
    final samples = await ref
        .read(waveformRepositoryProvider)
        .getWaveform(widget.sound.waveformUrl);
    if (mounted && samples != null) {
      setState(() => _waveform = samples);
    }
  }

  @override
  Widget build(BuildContext context) {
    final sound = widget.sound;
    final s = S.of(context);
    final playerState = ref.watch(soundPlayerViewModelProvider);
    final isCurrent = playerState.sound?.id == sound.id;
    final isPlaying = isCurrent && playerState.isPlaying;
    final isLoading = isCurrent && playerState.isLoading;

    return Container(
      decoration: BoxDecoration(
        color: context.colors.surfaceElevated,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40, height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: context.colors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Cover + info
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            child: Row(
              children: [
                _Cover(url: sound.coverUrl, size: 64),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        sound.title,
                        style: TextStyle(
                          color: context.colors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (sound.artist != null) ...[
                        const SizedBox(height: 3),
                        Text(
                          sound.artist!.artistName,
                          style: TextStyle(
                              color: context.colors.textSecondary, fontSize: 13),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      if (sound.genre != null) ...[
                        const SizedBox(height: 4),
                        _GenrePill(genre: sound.genre!),
                      ],
                    ],
                  ),
                ),
                // Botão salvar
                _SaveButton(sound: sound),
              ],
            ),
          ),

          // Waveform / progress bar — usa amostras REAIS de
          // `sound.waveformUrl` quando dispon\u00edveis (fetch ass\u00edncrono via
          // `WaveformRepository`); cai no padr\u00e3o neutro do `WaveformView`
          // enquanto carrega ou se a faixa n\u00e3o tiver waveform gerado.
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: GestureDetector(
              onHorizontalDragUpdate: (d) => _seekFromLocalDx(
                context,
                d.globalPosition,
                ref,
              ),
              onTapDown: (d) => _seekFromLocalDx(
                context,
                d.globalPosition,
                ref,
              ),
              child: WaveformView(
                samples: _waveform,
                progress: isCurrent ? playerState.progress : 0,
                activeColor: AppColors.mutedRed,
                inactiveColor: context.colors.border,
              ),
            ),
          ),

          // Timestamps
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isCurrent
                      ? _fmt(playerState.position)
                      : _fmt(Duration(milliseconds: sound.trimStartMs)),
                  style: TextStyle(
                      color: context.colors.textTertiary, fontSize: 11),
                ),
                Text(
                  _fmt(isCurrent
                      ? playerState.duration
                      : Duration(milliseconds: sound.durationMs)),
                  style: TextStyle(
                      color: context.colors.textTertiary, fontSize: 11),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Play / Pause + stats
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Stats
              _StatChip(
                icon: LucideIcons.headphones,
                value: _fmtCount(sound.playCount),
              ),
              const SizedBox(width: 24),

              // Play button
              GestureDetector(
                onTap: () =>
                    ref.read(soundPlayerViewModelProvider.notifier).play(sound),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [AppColors.mutedRed, Color(0xFFFF6B6B)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.mutedRed.withValues(alpha: 0.4),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: isLoading
                      ? const Padding(
                          padding: EdgeInsets.all(16),
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2),
                        )
                      : Icon(
                          isPlaying ? LucideIcons.pause : LucideIcons.play,
                          color: Colors.white,
                          size: 26,
                        ),
                ),
              ),

              const SizedBox(width: 24),
              _StatChip(
                icon: LucideIcons.share2,
                value: _fmtCount(sound.usageCount),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Botão "Usar"
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
            child: SizedBox(
              width: double.infinity,
              height: 46,
              child: FilledButton.icon(
                onPressed: () => Navigator.of(context).pop(sound),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.mutedRed,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(LucideIcons.music, size: 18),
                label: Text(s.soundsUse,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w700)),
              ),
            ),
          ),

          SafeArea(top: false, child: const SizedBox(height: 8)),
        ],
      ),
    );
  }

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  String _fmtCount(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return n.toString();
  }

  /// Converte uma posi\u00e7\u00e3o global de toque/arrasto em progresso [0..1]
  /// relativo \u00e0 largura do `WaveformView` e aplica via `seek()`.
  void _seekFromLocalDx(
    BuildContext context,
    Offset globalPosition,
    WidgetRef ref,
  ) {
    final box = context.findRenderObject() as RenderBox?;
    if (box == null) return;
    final local = box.globalToLocal(globalPosition);
    final progress = (local.dx / box.size.width).clamp(0.0, 1.0);
    ref.read(soundPlayerViewModelProvider.notifier).seek(progress);
  }
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _Cover extends StatelessWidget {
  const _Cover({required this.url, required this.size});
  final String? url;
  final double size;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: SizedBox(
        width: size,
        height: size,
        child: url != null
            ? CachedNetworkImage(imageUrl: url!, fit: BoxFit.cover)
            : Container(
                color: context.colors.surfaceHighest,
                child: Icon(LucideIcons.music,
                    color: context.colors.textSecondary, size: size * 0.4),
              ),
      ),
    );
  }
}

class _GenrePill extends StatelessWidget {
  const _GenrePill({required this.genre});
  final String genre;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.mutedRed.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        genre,
        style: const TextStyle(
            color: AppColors.mutedRed,
            fontSize: 11,
            fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.icon, required this.value});
  final IconData icon;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 14, color: context.colors.textTertiary),
      const SizedBox(width: 4),
      Text(value,
          style:
              TextStyle(color: context.colors.textTertiary, fontSize: 12)),
    ]);
  }
}

class _SaveButton extends ConsumerWidget {
  const _SaveButton({required this.sound});
  final Sound sound;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Busca o estado mais atualizado do catálogo para refletir o isSaved
    final catalogState = ref.watch(soundsCatalogViewModelProvider);
    final current = catalogState.items.firstWhere(
      (s) => s.id == sound.id,
      orElse: () => sound,
    );

    return IconButton(
      icon: Icon(
        current.isSaved ? LucideIcons.bookMarked : LucideIcons.bookmark,
        color: current.isSaved ? AppColors.mutedRed : context.colors.textSecondary,
      ),
      onPressed: () =>
          ref.read(soundsCatalogViewModelProvider.notifier).toggleSave(current),
    );
  }
}
