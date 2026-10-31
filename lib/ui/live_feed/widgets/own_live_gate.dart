import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../data/repositories/auth_state_provider.dart';
import '../../../domain/models/live_room.dart';
import '../../../gen/l10n/app_localizations.dart';
import '../../core/widgets/brawe_avatar.dart';
import 'live_player_screen.dart';

/// Porta de entrada do espectador: quem transmite não entra na própria live
/// como espectador (mesma conta em outro aparelho) — isso contaria como
/// viewer, liberaria presente para si mesmo e mostraria a própria câmera.
class LiveViewerGate extends ConsumerWidget {
  const LiveViewerGate({super.key, required this.room});

  final LiveRoom room;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myId = ref.watch(authStateProvider).value?.id;
    if (myId != null && myId == room.streamerId) {
      return _OwnLiveNotice(room: room);
    }
    return LivePlayerScreen(room: room);
  }
}

class _OwnLiveNotice extends StatelessWidget {
  const _OwnLiveNotice({required this.room});

  final LiveRoom room;

  void _back(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFF070B1A),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.bottomCenter,
                children: [
                  BraweAvatar(
                    avatarUrl: room.streamerAvatarUrl,
                    displayName: room.streamerName,
                    size: 88,
                    borderColor: const Color(0xFFFF2D55),
                    borderWidth: 3,
                  ),
                  Positioned(
                    bottom: -8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF2D55),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'LIVE',
                        style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              Text(
                s.liveOwnTitle,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 10),
              Text(
                s.liveOwnBody,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 15, height: 1.4),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => _back(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Text(s.liveOwnBack, style: const TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
