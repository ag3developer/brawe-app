import 'package:flutter/material.dart';
import 'package:brawe_app/core/services/broadcast_audio_processing.dart';

/// Painel de controle de processamento de áudio para broadcaster.
///
/// Oferece:
/// - Seletor de presets de EQ profissionais
/// - Toggle compressor on/off
/// - Sliders para Master Gain e Limiter
/// - Visualização de status
class AudioProcessorPanel extends StatefulWidget {
  final VoidCallback? onClose;

  const AudioProcessorPanel({this.onClose, super.key});

  @override
  State<AudioProcessorPanel> createState() => _AudioProcessorPanelState();
}

class _AudioProcessorPanelState extends State<AudioProcessorPanel> {
  late AudioEQPreset _selectedPreset;
  late bool _compressorEnabled;
  late double _masterGain;
  late double _limiterThreshold;

  @override
  void initState() {
    super.initState();
    _selectedPreset = BroadcastAudioProcessing.currentPreset;
    _compressorEnabled = BroadcastAudioProcessing.compressorEnabled;
    _masterGain = BroadcastAudioProcessing.masterGain;
    _limiterThreshold = BroadcastAudioProcessing.limiterThreshold;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          border: Border(
            top: BorderSide(color: Colors.pink.shade300, width: 2),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                children: [
                  const Text(
                    '🎙️ Audio Processor',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white70),
                    onPressed: widget.onClose,
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Preset Selector
              Text(
                'EQ Preset',
                style: TextStyle(
                  color: Colors.grey.shade300,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              _buildPresetGrid(),
              const SizedBox(height: 20),

              // Preset Info
              _buildPresetInfo(),
              const SizedBox(height: 20),

              // Compressor
              _buildCompressorSection(),
              const SizedBox(height: 20),

              // Master Gain
              _buildMasterGainSlider(),
              const SizedBox(height: 16),

              // Limiter
              _buildLimiterSlider(),
              const SizedBox(height: 20),

              // Status Display
              _buildStatusCard(),
              const SizedBox(height: 16),

              // Reset Button
              ElevatedButton.icon(
                onPressed: _resetAudio,
                icon: const Icon(Icons.refresh),
                label: const Text('Reset to Defaults'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade700,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPresetGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      children: AudioEQPreset.values.map((preset) {
        final isSelected = preset == _selectedPreset;
        final config = EQPresetConfig.fromPreset(preset);

        return GestureDetector(
          onTap: () => _applyPreset(preset),
          child: Container(
            decoration: BoxDecoration(
              color: isSelected ? Colors.pink.shade600 : Colors.grey.shade800,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? Colors.pink.shade300 : Colors.grey.shade600,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    config.name,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    config.description,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey.shade400, fontSize: 10),
                  ),
                  if (isSelected)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Icon(
                        Icons.check_circle,
                        color: Colors.pink.shade200,
                        size: 16,
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPresetInfo() {
    final config = BroadcastAudioProcessing.currentPresetConfig;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade700),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            config.name,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            config.description,
            style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
          ),
          if (config.bands.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: config.bands.map((band) {
                return Chip(
                  label: Text(
                    '${band.frequency.toStringAsFixed(0)}Hz '
                    '${band.gain > 0 ? '+' : ''}${band.gain.toStringAsFixed(1)}dB',
                    style: const TextStyle(fontSize: 10),
                  ),
                  backgroundColor: band.gain > 0
                      ? Colors.green.shade700
                      : Colors.orange.shade700,
                  labelStyle: const TextStyle(color: Colors.white),
                  visualDensity: VisualDensity.compact,
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCompressorSection() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade700),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '🔧 Compressor',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              Switch(
                value: _compressorEnabled,
                onChanged: _toggleCompressor,
                activeThumbColor: Colors.pink.shade300,
              ),
            ],
          ),
          if (_compressorEnabled) ...[
            const SizedBox(height: 8),
            Text(
              'Configuração: '
              'Threshold ${BroadcastAudioProcessing.compressorConfig.threshold.toStringAsFixed(0)}dB, '
              'Ratio ${BroadcastAudioProcessing.compressorConfig.ratio.toStringAsFixed(1)}:1',
              style: TextStyle(color: Colors.grey.shade400, fontSize: 11),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                _compressorPresetButton('Light', CompressorConfig.light()),
                _compressorPresetButton('Medium', CompressorConfig.medium()),
                _compressorPresetButton(
                  'Aggressive',
                  CompressorConfig.aggressive(),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _compressorPresetButton(String label, CompressorConfig config) {
    final isActive =
        BroadcastAudioProcessing.compressorConfig.ratio == config.ratio;

    return OutlinedButton(
      onPressed: _compressorEnabled ? () => _setCompressor(config) : null,
      style: OutlinedButton.styleFrom(
        backgroundColor: isActive ? Colors.pink.shade600 : Colors.transparent,
        side: BorderSide(
          color: isActive ? Colors.pink.shade300 : Colors.grey.shade600,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isActive ? Colors.white : Colors.grey.shade400,
          fontSize: 11,
        ),
      ),
    );
  }

  Widget _buildMasterGainSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '🔊 Master Gain',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
            Text(
              '${_masterGain > 0 ? '+' : ''}${_masterGain.toStringAsFixed(1)}dB',
              style: TextStyle(
                color: Colors.pink.shade300,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Slider(
          value: _masterGain,
          min: -12,
          max: 12,
          divisions: 48,
          activeColor: Colors.pink.shade300,
          inactiveColor: Colors.grey.shade700,
          onChanged: (value) {
            setState(() => _masterGain = value);
            BroadcastAudioProcessing.setMasterGain(value);
          },
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '-12dB',
                style: TextStyle(color: Colors.grey.shade500, fontSize: 10),
              ),
              Text(
                '0dB',
                style: TextStyle(color: Colors.grey.shade500, fontSize: 10),
              ),
              Text(
                '+12dB',
                style: TextStyle(color: Colors.grey.shade500, fontSize: 10),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLimiterSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '🛡️ Limiter (Peak Protection)',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
            Text(
              '${_limiterThreshold.toStringAsFixed(1)}dB',
              style: TextStyle(
                color: Colors.orange.shade300,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Slider(
          value: _limiterThreshold,
          min: -6,
          max: 0,
          divisions: 12,
          activeColor: Colors.orange.shade300,
          inactiveColor: Colors.grey.shade700,
          onChanged: (value) {
            setState(() => _limiterThreshold = value);
            BroadcastAudioProcessing.setLimiterThreshold(value);
          },
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '-6dB',
                style: TextStyle(color: Colors.grey.shade500, fontSize: 10),
              ),
              Text(
                '0dB',
                style: TextStyle(color: Colors.grey.shade500, fontSize: 10),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusCard() {
    final preset = BroadcastAudioProcessing.currentPresetConfig;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.pink.shade900.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.pink.shade700.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Current Configuration',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          _statusLine('Preset', preset.name),
          _statusLine(
            'Compressor',
            _compressorEnabled
                ? '${BroadcastAudioProcessing.compressorConfig.ratio.toStringAsFixed(1)}:1'
                : 'OFF',
          ),
          _statusLine(
            'Master Gain',
            '${_masterGain > 0 ? '+' : ''}${_masterGain.toStringAsFixed(1)}dB',
          ),
          _statusLine('Limiter', '${_limiterThreshold.toStringAsFixed(1)}dB'),
        ],
      ),
    );
  }

  Widget _statusLine(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.grey.shade400, fontSize: 11),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _applyPreset(AudioEQPreset preset) async {
    setState(() => _selectedPreset = preset);
    await BroadcastAudioProcessing.setPreset(preset);
  }

  Future<void> _toggleCompressor(bool enabled) async {
    setState(() => _compressorEnabled = enabled);
    await BroadcastAudioProcessing.toggleCompressor(enabled);
  }

  Future<void> _setCompressor(CompressorConfig config) async {
    await BroadcastAudioProcessing.setCompressor(config);
  }

  Future<void> _resetAudio() async {
    await BroadcastAudioProcessing.reset();
    setState(() {
      _selectedPreset = AudioEQPreset.voiceEnhancement;
      _compressorEnabled = BroadcastAudioProcessing.compressorEnabled;
      _masterGain = BroadcastAudioProcessing.masterGain;
      _limiterThreshold = BroadcastAudioProcessing.limiterThreshold;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Audio settings reset to defaults'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
}
