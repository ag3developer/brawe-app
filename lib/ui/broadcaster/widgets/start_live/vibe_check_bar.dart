import 'dart:async';
import 'dart:ui';

import 'package:battery_plus/battery_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

import '../../../core/themes/app_colors.dart';
import '../../../core/ui/app_radius.dart';
import '../../../core/ui/app_spacing.dart';

enum VibeStatus { good, warning, bad }

class VibeSnapshot {
  const VibeSnapshot({
    required this.network,
    required this.battery,
    required this.networkLabel,
    required this.batteryLevel,
  });
  final VibeStatus network;
  final VibeStatus battery;
  final String networkLabel;
  final int batteryLevel;

  VibeStatus get overall {
    if (network == VibeStatus.bad || battery == VibeStatus.bad) return VibeStatus.bad;
    if (network == VibeStatus.warning || battery == VibeStatus.warning) return VibeStatus.warning;
    return VibeStatus.good;
  }
}

class VibeCheckBar extends StatefulWidget {
  const VibeCheckBar({super.key, this.onStatusChanged});
  final ValueChanged<VibeSnapshot>? onStatusChanged;
  @override
  State<VibeCheckBar> createState() => _VibeCheckBarState();
}

class _VibeCheckBarState extends State<VibeCheckBar> {
  final Connectivity _connectivity = Connectivity();
  final Battery _battery = Battery();
  StreamSubscription<List<ConnectivityResult>>? _connSub;
  Timer? _batteryTimer;
  bool _expanded = false;

  VibeSnapshot _snapshot = const VibeSnapshot(
    network: VibeStatus.good,
    battery: VibeStatus.good,
    networkLabel: 'Wi-Fi',
    batteryLevel: 100,
  );

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final results = await _connectivity.checkConnectivity();
    _updateNetwork(results);
    _connSub = _connectivity.onConnectivityChanged.listen(_updateNetwork);
    await _refreshBattery();
    _batteryTimer = Timer.periodic(const Duration(seconds: 30), (_) => _refreshBattery());
  }

  void _updateNetwork(List<ConnectivityResult> results) {
    VibeStatus status;
    String label;
    if (results.contains(ConnectivityResult.wifi)) {
      status = VibeStatus.good;
      label = 'Wi-Fi';
    } else if (results.contains(ConnectivityResult.mobile)) {
      status = VibeStatus.warning;
      label = '4G/5G';
    } else if (results.contains(ConnectivityResult.ethernet)) {
      status = VibeStatus.good;
      label = 'Ethernet';
    } else {
      status = VibeStatus.bad;
      label = 'Sem rede';
    }
    _emit(VibeSnapshot(
      network: status,
      battery: _snapshot.battery,
      networkLabel: label,
      batteryLevel: _snapshot.batteryLevel,
    ));
  }

  Future<void> _refreshBattery() async {
    try {
      final level = await _battery.batteryLevel;
      final status = level >= 40
          ? VibeStatus.good
          : (level >= 20 ? VibeStatus.warning : VibeStatus.bad);
      _emit(VibeSnapshot(
        network: _snapshot.network,
        battery: status,
        networkLabel: _snapshot.networkLabel,
        batteryLevel: level,
      ));
    } catch (_) {}
  }

  void _emit(VibeSnapshot snap) {
    if (!mounted) return;
    setState(() => _snapshot = snap);
    widget.onStatusChanged?.call(snap);
  }

  @override
  void dispose() {
    _connSub?.cancel();
    _batteryTimer?.cancel();
    super.dispose();
  }

  Color _colorFor(VibeStatus s) => switch (s) {
        VibeStatus.good => const Color(0xFF34D399),
        VibeStatus.warning => const Color(0xFFFBBF24),
        VibeStatus.bad => AppColors.mutedRed,
      };

  String _label() => switch (_snapshot.overall) {
        VibeStatus.good => 'Tudo certo para entrar ao vivo',
        VibeStatus.warning => 'Funciona, mas pode oscilar',
        VibeStatus.bad => 'Atenção antes de começar',
      };

  @override
  Widget build(BuildContext context) {
    final overallColor = _colorFor(_snapshot.overall);
    return GestureDetector(
      onTap: () => setState(() => _expanded = !_expanded),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: _expanded ? AppSpacing.sm : 6,
            ),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.45),
              border: Border.all(color: overallColor.withValues(alpha: 0.55), width: 1),
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: overallColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: overallColor.withValues(alpha: 0.6), blurRadius: 6, spreadRadius: 1),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(_label(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12)),
                    const SizedBox(width: 6),
                    Icon(_expanded ? Icons.expand_less : Icons.expand_more, color: Colors.white, size: 16),
                  ],
                ),
                if (_expanded) ...[
                  const SizedBox(height: 6),
                  Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.wifi, color: _colorFor(_snapshot.network), size: 14),
                    const SizedBox(width: 6),
                    Text('Rede: ${_snapshot.networkLabel}', style: const TextStyle(color: Colors.white, fontSize: 11)),
                  ]),
                  const SizedBox(height: 2),
                  Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(_snapshot.batteryLevel < 20 ? Icons.battery_alert : Icons.battery_full,
                        color: _colorFor(_snapshot.battery), size: 14),
                    const SizedBox(width: 6),
                    Text('Bateria: ${_snapshot.batteryLevel}%', style: const TextStyle(color: Colors.white, fontSize: 11)),
                  ]),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
