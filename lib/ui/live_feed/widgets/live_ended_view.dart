import 'dart:async';
import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../data/repositories/auth_state_provider.dart';
import '../../../data/repositories/live_repository.dart';
import '../../../domain/models/live_room.dart';
import '../../../gen/l10n/app_localizations.dart';
import '../../core/themes/app_colors.dart';
import '../../core/view_models/follow_view_model.dart';
import '../../core/widgets/brawe_avatar.dart';
import 'package:brawe_app/ui/core/ui/image_decode.dart';

/// Tela "Live encerrada" (por cima do player): quem encerrou, quanto durou,
/// botão Seguir (se ainda não segue) e a próxima live no ar com contagem
/// para seguir automaticamente — a galera não fica parada numa sala vazia.
///
/// [late]: a pessoa abriu uma live que já tinha acabado (ex.: notificação
/// antiga de "fulano está ao vivo").
class LiveEndedView extends ConsumerStatefulWidget {
  const LiveEndedView({
    super.key,
    required this.room,
    this.late = false,
    this.durationSeconds,
  });

  final LiveRoom room;
  final bool late;
  final int? durationSeconds;

  @override
  ConsumerState<LiveEndedView> createState() => _LiveEndedViewState();
}

class _LiveEndedViewState extends ConsumerState<LiveEndedView> {
  static const int _autoAdvanceSeconds = 6;

  LiveRoom? _next;
  bool _loadingNext = true;
  int? _countdown;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _loadNext();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadNext() async {
    try {
      final rooms = await ref.read(liveRepositoryProvider).getLiveFeed(limit: 12);
      // Nunca a própria live de quem está vendo (mesma conta em outro aparelho).
      final myId = ref.read(authStateProvider).value?.id;
      final next = rooms
          .where((r) => r.id != widget.room.id && r.status == 'live' && r.streamerId != myId)
          .firstOrNull;
      if (!mounted) return;
      setState(() {
        _next = next;
        _loadingNext = false;
      });
      if (next != null) _startCountdown();
    } catch (_) {
      if (mounted) setState(() => _loadingNext = false);
    }
  }

  void _startCountdown() {
    setState(() => _countdown = _autoAdvanceSeconds);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return t.cancel();
      final left = (_countdown ?? 0) - 1;
      if (left <= 0) {
        t.cancel();
        _goNext();
      } else {
        setState(() => _countdown = left);
      }
    });
  }

  void _stopCountdown() {
    _timer?.cancel();
    if (_countdown != null) setState(() => _countdown = null);
  }

  void _goNext() {
    final next = _next;
    if (next == null || !mounted) return;
    context.pushReplacement('/live/${next.id}', extra: next);
  }

  void _close() {
    _stopCountdown();
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/home');
    }
  }

  String _duration(int seconds) {
    final h = seconds ~/ 3600;
    final m = (seconds % 3600) ~/ 60;
    if (h > 0) return '${h}h ${m.toString().padLeft(2, '0')}min';
    if (m > 0) return '$m min';
    return '${seconds}s';
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final room = widget.room;
    final name = room.streamerName.trim().isEmpty ? 'Streamer' : room.streamerName.trim();
    final me = ref.watch(authStateProvider).value?.id;
    final isMe = me != null && me == room.streamerId;
    final follow = ref.watch(followViewModelProvider(room.streamerId));
    final following = follow.value ?? false;
    final seconds = widget.durationSeconds ?? 0;

    return Material(
      color: Colors.transparent,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Fundo: capa da live desfocada + escurecida.
          if (room.thumbnailUrl != null && room.thumbnailUrl!.isNotEmpty)
            ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
              child: Image.network(
                cacheWidth: context.decodeScreenPx,
                room.thumbnailUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => const SizedBox.shrink(),
              ),
            ),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xE6070B1A), Color(0xF2070B1A), Color(0xFF05070F)],
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    onPressed: _close,
                    icon: const Icon(Icons.close_rounded, color: Colors.white, size: 28),
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(colors: [AppColors.braweBlue, AppColors.braweOrange]),
                  ),
                  child: BraweAvatar(
                    avatarUrl: room.streamerAvatarUrl,
                    displayName: name,
                    size: 96,
                    borderColor: const Color(0xFF070B1A),
                    borderWidth: 3,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  name,
                  style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 18),
                Text(
                  s.liveEndedTitle,
                  style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    widget.late ? s.liveEndedAlready(name) : s.liveEndedByStreamer(name),
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Color(0xFFB5BFD6), fontSize: 15, height: 1.4),
                  ),
                ),
                if (seconds > 0) ...[
                  const SizedBox(height: 6),
                  Text(
                    s.liveEndedLasted(_duration(seconds)),
                    style: const TextStyle(color: Color(0xFF8792AD), fontSize: 13),
                  ),
                ],
                const SizedBox(height: 26),
                if (!isMe) ...[
                  SizedBox(
                    width: 220,
                    height: 48,
                    child: FilledButton.icon(
                      onPressed: following || follow.isLoading
                          ? null
                          : () {
                              _stopCountdown();
                              ref.read(followViewModelProvider(room.streamerId).notifier).toggleFollow();
                            },
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.braweBlue,
                        disabledBackgroundColor: Colors.white.withValues(alpha: 0.12),
                        disabledForegroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      icon: Icon(following ? Icons.check_rounded : Icons.person_add_alt_1_rounded),
                      label: Text(
                        following ? s.liveEndedFollowing : s.liveEndedFollow,
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                      ),
                    ),
                  ),
                  if (!following) ...[
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Text(
                        s.liveEndedFollowHint(name),
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Color(0xFF8792AD), fontSize: 12),
                      ),
                    ),
                  ],
                ],
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: _loadingNext
                      ? const SizedBox(
                          height: 72,
                          child: Center(
                            child: SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white54),
                            ),
                          ),
                        )
                      : _next != null
                          ? _NextLiveCard(
                              room: _next!,
                              countdown: _countdown,
                              onWatch: _goNext,
                              onStay: _stopCountdown,
                            )
                          : Column(
                              children: [
                                Text(
                                  s.liveEndedNoOther,
                                  style: const TextStyle(color: Color(0xFF8792AD), fontSize: 13),
                                ),
                                const SizedBox(height: 10),
                                OutlinedButton(
                                  onPressed: () => context.go('/home'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    side: const BorderSide(color: Colors.white24),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                  child: Text(s.liveEndedBackHome),
                                ),
                              ],
                            ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NextLiveCard extends StatelessWidget {
  const _NextLiveCard({
    required this.room,
    required this.countdown,
    required this.onWatch,
    required this.onStay,
  });

  final LiveRoom room;
  final int? countdown;
  final VoidCallback onWatch;
  final VoidCallback onStay;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            s.liveEndedNextLive.toUpperCase(),
            style: const TextStyle(
              color: AppColors.braweOrange,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 54,
                  height: 72,
                  child: room.thumbnailUrl != null && room.thumbnailUrl!.isNotEmpty
                      ? Image.network(cacheWidth: context.decodePx(54), room.thumbnailUrl!, fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => const ColoredBox(color: Color(0xFF141A2E)))
                      : const ColoredBox(color: Color(0xFF141A2E)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      room.streamerName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 15),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      room.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Color(0xFFB5BFD6), fontSize: 13),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE5254B),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text('LIVE',
                              style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900)),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          s.liveEndedWatching('${room.viewerCount}'),
                          style: const TextStyle(color: Color(0xFF8792AD), fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              FilledButton(
                onPressed: onWatch,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.braweOrange,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(s.liveEndedWatchNow, style: const TextStyle(fontWeight: FontWeight.w800)),
              ),
            ],
          ),
          if (countdown != null) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Text(
                    s.liveEndedGoingIn(countdown!),
                    style: const TextStyle(color: Color(0xFFB5BFD6), fontSize: 12),
                  ),
                ),
                TextButton(
                  onPressed: onStay,
                  style: TextButton.styleFrom(foregroundColor: Colors.white70),
                  child: Text(s.liveEndedStay),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
