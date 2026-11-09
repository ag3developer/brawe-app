import 'package:flutter/material.dart';

import '../../../gen/l10n/app_localizations.dart';
import '../../core/themes/app_colors.dart';
import '../../core/themes/brawe_colors.dart';

/// Bottom sheet com dois sliders — volume da música do Brawe Sounds e
/// volume do áudio ORIGINAL do vídeo — usado no editor de Stories e no
/// composer de vídeo/Reels quando há uma faixa anexada (Fase D do
/// relatório de áudio: antes esses controles não existiam na UI, apesar
/// dos modelos/backend já suportarem `sound_volume`/`original_audio_volume`).
///
/// Alterações são aplicadas em tempo real via [onMusicVolumeChanged] e
/// [onOriginalVolumeChanged] — o chamador é responsável por atualizar o
/// player de música e o `VideoPlayerController` imediatamente, para que o
/// usuário ouça o resultado enquanto arrasta (preview em tempo real).
///
/// Não hardcoda cores nem textos: usa [S.of(context)] para strings (PT/EN/ES)
/// e `context.colors`/[AppColors] para cores compatíveis com tema claro/escuro.
class VolumeMixerSheet extends StatefulWidget {
  const VolumeMixerSheet({
    super.key,
    required this.initialMusicVolume,
    required this.initialOriginalVolume,
    required this.onMusicVolumeChanged,
    required this.onOriginalVolumeChanged,
    this.musicTitle,
  });

  final double initialMusicVolume;
  final double initialOriginalVolume;
  final ValueChanged<double> onMusicVolumeChanged;
  final ValueChanged<double> onOriginalVolumeChanged;

  /// Título da faixa anexada (opcional) — exibido como subtítulo do
  /// slider de música para o usuário confirmar qual faixa está ajustando.
  final String? musicTitle;

  /// Abre o sheet e retorna os volumes finais escolhidos (ou os valores
  /// iniciais se o usuário fechar sem alterar — o sheet não tem botão de
  /// "cancelar": os callbacks já aplicam em tempo real, e fechar apenas
  /// confirma o que já está em preview).
  static Future<(double musicVolume, double originalVolume)?> show(
    BuildContext context, {
    required double initialMusicVolume,
    required double initialOriginalVolume,
    required ValueChanged<double> onMusicVolumeChanged,
    required ValueChanged<double> onOriginalVolumeChanged,
    String? musicTitle,
  }) {
    return showModalBottomSheet<(double, double)>(
      useRootNavigator: true,
      useSafeArea: true,
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => VolumeMixerSheet(
        initialMusicVolume: initialMusicVolume,
        initialOriginalVolume: initialOriginalVolume,
        onMusicVolumeChanged: onMusicVolumeChanged,
        onOriginalVolumeChanged: onOriginalVolumeChanged,
        musicTitle: musicTitle,
      ),
    );
  }

  @override
  State<VolumeMixerSheet> createState() => _VolumeMixerSheetState();
}

class _VolumeMixerSheetState extends State<VolumeMixerSheet> {
  late double _musicVolume = widget.initialMusicVolume;
  late double _originalVolume = widget.initialOriginalVolume;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final colors = context.colors;
    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: colors.border),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: colors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text(
              s.volumeMixerTitle,
              style: TextStyle(
                color: colors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              s.volumeMixerSubtitle,
              style: TextStyle(color: colors.textSecondary, fontSize: 12),
            ),
            const SizedBox(height: 20),
            _VolumeRow(
              icon: Icons.music_note_rounded,
              label: widget.musicTitle ?? s.volumeMixerMusicLabel,
              value: _musicVolume,
              accentColor: AppColors.braweOrange,
              onChanged: (v) {
                setState(() => _musicVolume = v);
                widget.onMusicVolumeChanged(v);
              },
            ),
            const SizedBox(height: 18),
            _VolumeRow(
              icon: Icons.videocam_rounded,
              label: s.volumeMixerOriginalLabel,
              value: _originalVolume,
              accentColor: AppColors.braweSky,
              onChanged: (v) {
                setState(() => _originalVolume = v);
                widget.onOriginalVolumeChanged(v);
              },
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () =>
                    Navigator.of(context).pop((_musicVolume, _originalVolume)),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.braweBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(s.volumeMixerDone),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VolumeRow extends StatelessWidget {
  const _VolumeRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.accentColor,
    required this.onChanged,
  });

  final IconData icon;
  final String label;
  final double value;
  final Color accentColor;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: colors.textSecondary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: colors.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Text(
              '${(value * 100).round()}%',
              style: TextStyle(
                color: colors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: accentColor,
            inactiveTrackColor: colors.border,
            thumbColor: accentColor,
            overlayColor: accentColor.withValues(alpha: 0.15),
            trackHeight: 3,
          ),
          child: Slider(value: value.clamp(0.0, 1.0), onChanged: onChanged),
        ),
      ],
    );
  }
}
