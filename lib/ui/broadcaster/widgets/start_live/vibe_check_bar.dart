import 'dart:async';
import 'dart:ui';

import 'package:battery_plus/battery_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

import '../../../core/themes/app_colors.dart';
import '../../../core/ui/app_radius.dart';
import '../../../core/ui/app_spacing.dart';
import '../../../../gen/l10n/app_localizations.dart';

enum VibeStatus { good, warning, bad }

enum NetworkKind { wifi, mobile, ethernet, none }

class VibeSnapshot {
  const VibeSnapshot({
    required this.network,
    required this.battery,
    required this.networkKind,
    required this.batteryLevel,
  });
  final VibeStatus network;
  final VibeStatus battery;
  final NetworkKind networkKind;
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
    networkKind: NetworkKind.wifi,
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
    NetworkKind kind;
    if (results.contains(ConnectivityResult.wifi)) {
      status = VibeStatus.good;
      kind = NetworkKind.wifi;
    } else if (results.contains(ConnectivityResult.mobile)) {
      status = VibeStatus.warning;
      kind = NetworkKind.mobile;
    } else if (results.contains(ConnectivityResult.ethernet)) {
      status = VibeStatus.good;
      kind = NetworkKind.ethernet;
    } else {
      status = VibeStatus.bad;
      kind = NetworkKind.none;
    }
    _emit(VibeSnapshot(
      network: status,
      battery: _snapshot.battery,
      networkKind: kind,
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
        networkKind: _snapshot.networkKind,
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

  String _label(S s) => switch (_snapshot.overall) {
        VibeStatus.good => s.vibeStatusGood,
        VibeStatus.warning => s.vibeStatusWarning,
        VibeStatus.bad => s.vibeStatusBad,
      };

  String _networkLabelText(S s) => switch (_snapshot.networkKind) {
        NetworkKind.wifi => s.vibeNetworkWifi,
        NetworkKind.mobile => s.vibeNetworkMobile,
        NetworkKind.ethernet => s.vibeNetworkEthernet,
        NetworkKind.none => s.vibeNetworkNone,
      };

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final overallColor = _colorFor(_snapshot.overall);

    return GestureDetector(
      onTap: () => setState(() => _expanded = !_expanded),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(50),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeInOut,
            padding: _expanded
                ? const EdgeInsets.symmetric(horizontal: 10, vertical: 6)
                : const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.50),
              border: Border.all(color: overallColor.withValues(alpha: 0.5), width: 1),
              borderRadius: BorderRadius.circular(_expanded ? 14 : 50),
            ),
            child: _expanded ? _ExpandedContent(snapshot: _snapshot, colorFor: _colorFor, networkLabelText: _networkLabelText(s), l10n: s) : _Dot(color: overallColor),
          ),
        ),
      ),
    );
  }
}

// ── Dot (collapsed) ──────────────────────────────────────────────────────────
class _Dot extends StatelessWidget {
  const _Dot({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: color.withValues(alpha: 0.7), blurRadius: 6, spreadRadius: 1)],
      ),
    );
  }
}

// ── Expanded content ─────────────────────────────────────────────────────────
class _ExpandedContent extends StatelessWidget {
  const _ExpandedContent({
    required this.snapshot,
    required this.colorFor,
    required this.networkLabelText,
    required this.l10n,
  });

  final VibeSnapshot snapshot;
  final Color Function(VibeStatus) colorFor;
  final String networkLabelText;
  final S l10n;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Rede
        Icon(Icons.wifi, color: colorFor(snapshot.network), size: 13),
        const SizedBox(width: 4),
        Text(networkLabelText,
            style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w500)),
        const SizedBox(width: 10),
        // Bateria
        Icon(
          snapshot.batteryLevel < 20 ? Icons.battery_alert : Icons.battery_full,
          color: colorFor(snapshot.battery),
          size: 13,
        ),
        const SizedBox(width: 4),
        Text('${snapshot.batteryLevel}%',
            style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w500)),
      ],
    );
  }
}
