import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:brawe_app/core/services/broadcast_audio_processing.dart';

/// Painel de áudio minimalista — design moderno, glassmorphism, ícones Lucide.
class AudioProcessorPanel extends StatefulWidget {
  final VoidCallback? onClose;
  const AudioProcessorPanel({this.onClose, super.key});

  @override
  State<AudioProcessorPanel> createState() => _AudioProcessorPanelState();
}

class _AudioProcessorPanelState extends State<AudioProcessorPanel>
    with SingleTickerProviderStateMixin {
  late AudioEQPreset _selectedPreset;
  late bool _compressorEnabled;
  late double _masterGain;
  late double _limiterThreshold;
  late String _compressorLabel;
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;

  // Mapa de ícone + label por preset
  static const _presetMeta = {
    AudioEQPreset.flat: (
      icon: LucideIcons.minus,
      label: 'Flat',
      sub: 'Sem efeito',
    ),
    AudioEQPreset.voiceEnhancement: (
      icon: LucideIcons.mic,
      label: 'Voice',
      sub: 'Voz clara',
    ),
    AudioEQPreset.musicBoost: (
      icon: LucideIcons.music,
      label: 'Music',
      sub: 'Bass + Treble',
    ),
    AudioEQPreset.gaming: (
      icon: LucideIcons.gamepad2,
      label: 'Gaming',
      sub: 'Diálogos',
    ),
    AudioEQPreset.podcast: (
      icon: LucideIcons.headphones,
      label: 'Podcast',
      sub: 'Profissional',
    ),
    AudioEQPreset.studio: (
      icon: LucideIcons.sliders,
      label: 'Studio',
      sub: 'Minimalista',
    ),
  };

  @override
  void initState() {
    super.initState();
    _selectedPreset = BroadcastAudioProcessing.currentPreset;
    _compressorEnabled = BroadcastAudioProcessing.compressorEnabled;
    _masterGain = BroadcastAudioProcessing.masterGain;
    _limiterThreshold = BroadcastAudioProcessing.limiterThreshold;
    _compressorLabel = _labelForRatio(
      BroadcastAudioProcessing.compressorConfig.ratio,
    );

    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  String _labelForRatio(double ratio) {
    if (ratio <= 2) return 'Light';
    if (ratio <= 4) return 'Medium';
    return 'Aggressive';
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnim,
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.72),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
              border: Border(
                top: BorderSide(
                  color: Colors.white.withValues(alpha: 0.08),
                  width: 1,
                ),
              ),
            ),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildHandle(),
                    const SizedBox(height: 12),
                    _buildHeader(),
                    const SizedBox(height: 20),
                    _buildPresetRow(),
                    const SizedBox(height: 20),
                    _buildSliderRow(
                      icon: LucideIcons.volume2,
                      label: 'Gain',
                      value: _masterGain,
                      min: -12,
                      max: 12,
                      divisions: 48,
                      color: const Color(0xFFFF3D6E),
                      displayValue:
                          '${_masterGain > 0 ? '+' : ''}${_masterGain.toStringAsFixed(1)}',
                      onChanged: (v) {
                        setState(() => _masterGain = v);
                        BroadcastAudioProcessing.setMasterGain(v);
                      },
                    ),
                    const SizedBox(height: 14),
                    _buildSliderRow(
                      icon: LucideIcons.shieldCheck,
                      label: 'Limiter',
                      value: _limiterThreshold,
                      min: -6,
                      max: 0,
                      divisions: 12,
                      color: const Color(0xFFFFB340),
                      displayValue: '${_limiterThreshold.toStringAsFixed(1)}',
                      onChanged: (v) {
                        setState(() => _limiterThreshold = v);
                        BroadcastAudioProcessing.setLimiterThreshold(v);
                      },
                    ),
                    const SizedBox(height: 20),
                    _buildBottomRow(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Handle ────────────────────────────────────────────────────────────────

  Widget _buildHandle() => Center(
    child: Container(
      width: 36,
      height: 4,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(2),
      ),
    ),
  );

  // ── Header ────────────────────────────────────────────────────────────────

  Widget _buildHeader() => Row(
    children: [
      Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: const Color(0xFFFF3D6E).withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(
          LucideIcons.waves,
          color: Color(0xFFFF3D6E),
          size: 18,
        ),
      ),
      const SizedBox(width: 10),
      const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Audio',
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
            ),
          ),
          Text(
            'EQ · Compressor · Limiter',
            style: TextStyle(
              color: Color(0xFF888888),
              fontSize: 11,
              height: 1.2,
            ),
          ),
        ],
      ),
      const Spacer(),
      GestureDetector(
        onTap: widget.onClose,
        child: Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.07),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(LucideIcons.x, color: Color(0xFF888888), size: 15),
        ),
      ),
    ],
  );

  // ── Preset Row ────────────────────────────────────────────────────────────

  Widget _buildPresetRow() {
    return SizedBox(
      height: 72,
      child: ListView(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        children: AudioEQPreset.values.map((preset) {
          final meta = _presetMeta[preset]!;
          final isSelected = preset == _selectedPreset;

          return GestureDetector(
            onTap: () => _applyPreset(preset),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              margin: const EdgeInsets.only(right: 8),
              width: 68,
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFFFF3D6E).withValues(alpha: 0.18)
                    : Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFFFF3D6E).withValues(alpha: 0.7)
                      : Colors.white.withValues(alpha: 0.07),
                  width: isSelected ? 1.5 : 1,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    meta.icon,
                    size: 20,
                    color: isSelected
                        ? const Color(0xFFFF3D6E)
                        : const Color(0xFF888888),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    meta.label,
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : const Color(0xFF888888),
                      fontSize: 10,
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w400,
                      letterSpacing: 0.1,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── Slider Row ────────────────────────────────────────────────────────────

  Widget _buildSliderRow({
    required IconData icon,
    required String label,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required Color color,
    required String displayValue,
    required ValueChanged<double> onChanged,
  }) {
    return Row(
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF888888),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        Expanded(
          child: SliderTheme(
            data: SliderThemeData(
              trackHeight: 2,
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
              activeTrackColor: color,
              inactiveTrackColor: Colors.white.withValues(alpha: 0.08),
              thumbColor: Colors.white,
              overlayColor: color.withValues(alpha: 0.15),
            ),
            child: Slider(
              value: value,
              min: min,
              max: max,
              divisions: divisions,
              onChanged: onChanged,
            ),
          ),
        ),
        SizedBox(
          width: 44,
          child: Text(
            '$displayValue dB',
            textAlign: TextAlign.right,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  // ── Bottom Row: Compressor + Reset ────────────────────────────────────────

  Widget _buildBottomRow() => Row(
    children: [
      // Compressor toggle
      GestureDetector(
        onTap: () => _toggleCompressor(!_compressorEnabled),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: _compressorEnabled
                ? const Color(0xFF4FC3F7).withValues(alpha: 0.15)
                : Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: _compressorEnabled
                  ? const Color(0xFF4FC3F7).withValues(alpha: 0.5)
                  : Colors.white.withValues(alpha: 0.07),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                LucideIcons.activity,
                size: 14,
                color: _compressorEnabled
                    ? const Color(0xFF4FC3F7)
                    : const Color(0xFF555555),
              ),
              const SizedBox(width: 6),
              Text(
                _compressorEnabled ? _compressorLabel : 'Comp',
                style: TextStyle(
                  color: _compressorEnabled
                      ? const Color(0xFF4FC3F7)
                      : const Color(0xFF555555),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
      const SizedBox(width: 8),
      // Compressor presets (apenas quando ativo)
      if (_compressorEnabled) ...[
        _compChip('L', CompressorConfig.light()),
        const SizedBox(width: 6),
        _compChip('M', CompressorConfig.medium()),
        const SizedBox(width: 6),
        _compChip('A', CompressorConfig.aggressive()),
      ],
      const Spacer(),
      // Reset
      GestureDetector(
        onTap: _resetAudio,
        child: Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
          ),
          child: const Icon(
            LucideIcons.rotateCcw,
            color: Color(0xFF666666),
            size: 15,
          ),
        ),
      ),
    ],
  );

  Widget _compChip(String label, CompressorConfig config) {
    final isActive =
        BroadcastAudioProcessing.compressorConfig.ratio == config.ratio;
    return GestureDetector(
      onTap: () => _setCompressor(config),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: isActive
              ? const Color(0xFF4FC3F7).withValues(alpha: 0.2)
              : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(7),
          border: Border.all(
            color: isActive
                ? const Color(0xFF4FC3F7).withValues(alpha: 0.6)
                : Colors.white.withValues(alpha: 0.07),
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isActive
                  ? const Color(0xFF4FC3F7)
                  : const Color(0xFF555555),
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }

  // ── Actions ───────────────────────────────────────────────────────────────

  Future<void> _applyPreset(AudioEQPreset preset) async {
    setState(() => _selectedPreset = preset);
    await BroadcastAudioProcessing.setPreset(preset);
  }

  Future<void> _toggleCompressor(bool enabled) async {
    setState(() => _compressorEnabled = enabled);
    await BroadcastAudioProcessing.toggleCompressor(enabled);
  }

  Future<void> _setCompressor(CompressorConfig config) async {
    setState(() => _compressorLabel = _labelForRatio(config.ratio));
    await BroadcastAudioProcessing.setCompressor(config);
  }

  Future<void> _resetAudio() async {
    await BroadcastAudioProcessing.reset();
    setState(() {
      _selectedPreset = AudioEQPreset.voiceEnhancement;
      _compressorEnabled = BroadcastAudioProcessing.compressorEnabled;
      _masterGain = BroadcastAudioProcessing.masterGain;
      _limiterThreshold = BroadcastAudioProcessing.limiterThreshold;
      _compressorLabel = 'Medium';
    });
  }
}
