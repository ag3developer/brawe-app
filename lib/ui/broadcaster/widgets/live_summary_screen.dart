// =============================================================================
// 🏁 LIVE SUMMARY SCREEN — Brawe
// =============================================================================
// Tela exibida IMEDIATAMENTE após o streamer encerrar uma live
// (`POST /live/rooms/{id}/end`). Antes desta tela não existir, o app ficava
// com uma tela branca/travada no Android ao encerrar — ver
// BUG_LIVE_END_BLANK_SCREEN.md.
//
// Recebe os dados finais já retornados pelo próprio endpoint de encerramento
// (duração, pico de audiência, espectadores únicos, valor em presentes,
// mystery gifts revelados) — nenhuma chamada de rede extra é necessária.
//
// Sempre navegável via `context.go('/home')` a partir daqui — nunca deixa o
// usuário travado, mesmo se os dados do resumo vierem vazios/incompletos
// (ex.: falha silenciosa do backend ao persistir métricas finais).
// =============================================================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../gen/l10n/app_localizations.dart';
import '../../core/themes/app_colors.dart';
import '../../core/themes/force_dark_theme.dart';

/// Dados do resumo final de uma live — parseados do campo `data` da resposta
/// de `POST /live/rooms/{id}/end`. Todos os campos são opcionais/nullable
/// porque o backend pode falhar silenciosamente ao persistir alguma métrica
/// (ver `app/api/v1/live.py::end_live`, blocos try/except individuais).
class LiveSummaryData {
  const LiveSummaryData({
    this.durationSeconds,
    this.peakViewers,
    this.totalViewers,
    this.totalGiftsValue,
    this.mysteryGiftsRevealed,
  });

  final int? durationSeconds;
  final int? peakViewers;
  final int? totalViewers;
  final double? totalGiftsValue;
  final int? mysteryGiftsRevealed;

  factory LiveSummaryData.fromMap(Map<String, dynamic> map) {
    num? asNum(dynamic v) => v is num ? v : null;
    return LiveSummaryData(
      durationSeconds: asNum(map['duration_seconds'])?.toInt(),
      peakViewers: asNum(map['peak_viewers'])?.toInt(),
      totalViewers: asNum(map['total_viewers'])?.toInt(),
      totalGiftsValue: asNum(map['total_gifts_value'])?.toDouble(),
      mysteryGiftsRevealed: asNum(map['mystery_gifts_revealed'])?.toInt(),
    );
  }

  /// True se não temos NENHUM dado útil — usado para mostrar o estado de
  /// fallback amigável em vez de uma tela de números todos zerados.
  bool get isEmpty =>
      durationSeconds == null &&
      peakViewers == null &&
      totalViewers == null &&
      totalGiftsValue == null &&
      mysteryGiftsRevealed == null;
}

class LiveSummaryScreen extends StatelessWidget {
  const LiveSummaryScreen({super.key, required this.data, this.roomTitle});

  final LiveSummaryData data;
  final String? roomTitle;

  static void show(
    BuildContext context, {
    required LiveSummaryData data,
    String? roomTitle,
  }) {
    context.go('/live/summary', extra: {'data': data, 'roomTitle': roomTitle});
  }

  String _formatDuration(int? seconds) {
    if (seconds == null || seconds <= 0) return '--:--';
    final d = Duration(seconds: seconds);
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    final s = d.inSeconds.remainder(60);
    if (h > 0) {
      return '${h}h ${m.toString().padLeft(2, '0')}m';
    }
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  String _formatGifts(double? value) {
    if (value == null) return '—';
    return value.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return ForceDarkTheme(
      child: Scaffold(
        backgroundColor: AppColors.darkBackground,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const Spacer(),
                Container(
                  width: 84,
                  height: 84,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF4F8B), Color(0xFFB44CF0)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFB44CF0).withValues(alpha: 0.35),
                        blurRadius: 24,
                        spreadRadius: -4,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 44,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  s.liveSummaryTitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (roomTitle != null && roomTitle!.trim().isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    roomTitle!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
                const SizedBox(height: 28),
                if (data.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      s.liveSummaryUnavailable,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                  )
                else
                  _StatsGrid(
                    data: data,
                    s: s,
                    formatDuration: _formatDuration,
                    formatGifts: _formatGifts,
                  ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.electricPurple, AppColors.coolCyan],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.electricPurple.withValues(
                            alpha: 0.4,
                          ),
                          blurRadius: 16,
                          spreadRadius: 0.5,
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        // Sempre navega pra Home — nunca deixa o usuário
                        // travado nesta tela nem em nenhuma tela branca.
                        onTap: () => context.go('/home'),
                        child: Center(
                          child: Text(
                            s.liveSummaryDone,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({
    required this.data,
    required this.s,
    required this.formatDuration,
    required this.formatGifts,
  });

  final LiveSummaryData data;
  final S s;
  final String Function(int?) formatDuration;
  final String Function(double?) formatGifts;

  @override
  Widget build(BuildContext context) {
    final items = <_StatItem>[
      _StatItem(
        icon: Icons.timer_outlined,
        label: s.liveSummaryDuration,
        value: formatDuration(data.durationSeconds),
      ),
      _StatItem(
        icon: Icons.trending_up_rounded,
        label: s.liveSummaryPeakViewers,
        value: '${data.peakViewers ?? 0}',
      ),
      _StatItem(
        icon: Icons.groups_outlined,
        label: s.liveSummaryTotalViewers,
        value: '${data.totalViewers ?? 0}',
      ),
      _StatItem(
        icon: Icons.card_giftcard_rounded,
        label: s.liveSummaryGiftsValue,
        value: '💎 ${formatGifts(data.totalGiftsValue)}',
      ),
      if ((data.mysteryGiftsRevealed ?? 0) > 0)
        _StatItem(
          icon: Icons.auto_awesome_rounded,
          label: s.liveSummaryMysteryGifts,
          value: '${data.mysteryGiftsRevealed}',
        ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.35,
      ),
      itemCount: items.length,
      itemBuilder: (_, i) => _StatCard(item: items[i]),
    );
  }
}

class _StatItem {
  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
  });
  final IconData icon;
  final String label;
  final String value;
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.item});
  final _StatItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(item.icon, color: AppColors.coolCyan, size: 22),
          const SizedBox(height: 8),
          Text(
            item.value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            item.label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 11.5,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
