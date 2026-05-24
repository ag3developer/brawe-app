import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';

import '../../../../../data/repositories/live_repository.dart';
import '../../../../../data/repositories/profile_repository.dart';
import '../../../../../domain/models/live_comment.dart';
import '../../../../../domain/models/profile.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../../live_feed/view_models/live_room_comments_view_model.dart';
import '../../../../../gen/l10n/app_localizations.dart';

/// 👤 Provider que busca o perfil completo de um streamer pelo id,
/// usado para garantir que avatar + nome real sempre apareçam no card de
/// live no For You (mesmo quando o endpoint /lives não devolve avatar).
final streamerProfileProvider =
    FutureProvider.family<Profile?, String>((ref, userId) async {
  if (userId.isEmpty) return null;
  try {
    return await ref.read(profileRepositoryProvider).getUserProfile(userId);
  } catch (_) {
    return null;
  }
});

/// 🔴 Live Peek — fundo "vivo" do card de live no For You.
///
/// Diferenciais vs TikTok:
/// - Autoplay mudo do `streamUrl` (HLS) com fallback de thumbnail.
/// - Pausa o player quando não é a página ativa (poupa banda/CPU).
/// - Tap em qualquer lugar → entra na live com som.
/// - Após 5s de preview, sinaliza "interesse" pro ranking.
class LivePeekBackground extends ConsumerStatefulWidget {
  const LivePeekBackground({
    super.key,
    required this.roomId,
    required this.thumbnailUrl,
    this.streamUrl,
    this.isActive = true,
  });

  final String roomId;
  final String thumbnailUrl;
  final String? streamUrl;
  final bool isActive;

  @override
  ConsumerState<LivePeekBackground> createState() => _LivePeekBackgroundState();
}

class _LivePeekBackgroundState extends ConsumerState<LivePeekBackground> {
  VideoPlayerController? _ctrl;
  bool _ready = false;
  Timer? _interestTimer;

  @override
  void initState() {
    super.initState();
    if (widget.isActive) _bootPlayer();
    _scheduleInterest();
  }

  @override
  void didUpdateWidget(covariant LivePeekBackground oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _bootPlayer();
      _ctrl?.play();
      _scheduleInterest();
    } else if (!widget.isActive && oldWidget.isActive) {
      _ctrl?.pause();
      _interestTimer?.cancel();
    }
  }

  Future<void> _bootPlayer() async {
    final url = widget.streamUrl;
    if (_ctrl != null || url == null || url.isEmpty) return;
    final ctrl = VideoPlayerController.networkUrl(
      Uri.parse(url),
      videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
    );
    try {
      await ctrl.initialize();
      if (!mounted) {
        await ctrl.dispose();
        return;
      }
      await ctrl.setVolume(0); // preview SEM som
      await ctrl.setLooping(true);
      await ctrl.play();
      setState(() {
        _ctrl = ctrl;
        _ready = true;
      });
    } catch (_) {
      await ctrl.dispose();
    }
  }

  void _scheduleInterest() {
    _interestTimer?.cancel();
    _interestTimer = Timer(const Duration(seconds: 5), () {
      if (!mounted || !widget.isActive) return;
      ref
          .read(liveRepositoryProvider)
          .signalPreviewInterest(widget.roomId)
          .catchError((_) {});
    });
  }

  @override
  void dispose() {
    _interestTimer?.cancel();
    _ctrl?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        if (_ready && _ctrl != null)
          FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: _ctrl!.value.size.width,
              height: _ctrl!.value.size.height,
              child: VideoPlayer(_ctrl!),
            ),
          )
        else if (widget.thumbnailUrl.isNotEmpty)
          Image.network(
            widget.thumbnailUrl,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => Container(color: AppColors.slate),
          )
        else
          Container(color: AppColors.slate),
        // Gradiente para legibilidade
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0x55000000),
                Color(0x00000000),
                Color(0xCC000000),
              ],
              stops: [0.0, 0.4, 1.0],
            ),
          ),
        ),
      ],
    );
  }
}

/// 🔴 Pílula compacta "● AO VIVO" pulsante (sem viewer count — fica em outro
/// lugar pra não poluir e não brigar com a topbar Seguindo/Para Você).
class LiveDotPulse extends StatefulWidget {
  const LiveDotPulse({super.key, this.label});
  final String? label;

  @override
  State<LiveDotPulse> createState() => _LiveDotPulseState();
}

class _LiveDotPulseState extends State<LiveDotPulse>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (_, _) {
        final glow = 0.4 + 0.5 * _c.value;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.mutedRed.withValues(alpha: glow * 0.5),
                blurRadius: 10,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  color: AppColors.mutedRed,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.mutedRed.withValues(alpha: glow),
                      blurRadius: 6,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Text(
                widget.label ?? S.of(context).liveBadgeLive,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.7,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// 💬 Chip de viewer count discreto.
class ViewerCountChip extends StatelessWidget {
  const ViewerCountChip({super.key, required this.count});
  final int count;

  String _fmt(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return '$n';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.remove_red_eye_outlined,
              color: Colors.white70, size: 12),
          const SizedBox(width: 4),
          Text(
            _fmt(count),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

/// 💬 Ticker de comentários **reais** — escuta o mesmo WebSocket que o
/// player usa (via `liveRoomCommentsViewModelProvider`). Mostra os 4
/// últimos comentários com fade no topo.
///
/// Se o usuário não está com a live ativa, nada é renderizado e o
/// provider sequer é instanciado (evita conexões fantasma).
class RealCommentsTicker extends ConsumerWidget {
  const RealCommentsTicker({
    super.key,
    required this.roomId,
    required this.isActive,
    this.maxLines = 4,
  });

  final String roomId;
  final bool isActive;
  final int maxLines;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!isActive) return const SizedBox.shrink();
    final comments = ref
        .watch(liveRoomCommentsViewModelProvider(roomId))
        .comments;
    if (comments.isEmpty) return const SizedBox.shrink();

    final latest = comments.length > maxLines
        ? comments.sublist(comments.length - maxLines)
        : comments;

    return ShaderMask(
      shaderCallback: (rect) {
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.transparent, Colors.black, Colors.black],
          stops: [0.0, 0.35, 1.0],
        ).createShader(rect);
      },
      blendMode: BlendMode.dstIn,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final c in latest)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: _CommentBubble(comment: c),
            ),
        ],
      ),
    );
  }
}

class _CommentBubble extends StatelessWidget {
  const _CommentBubble({required this.comment});
  final LiveComment comment;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 240),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(14),
      ),
      child: RichText(
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        text: TextSpan(
          children: [
            TextSpan(
              text: '${comment.userName}  ',
              style: const TextStyle(
                color: Color(0xFFB6A6FF),
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
            TextSpan(
              text: comment.message,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 🎟️ CTA compacto "Assistir live ao vivo" — pílula menor, ícone live
/// pulsando, gradiente Brawe. Pensado pra entrar discreto na composição
/// junto da caption.
/// 🎵 Botão "Assistir ao Vivo" com ondas sonoras animadas (equalizer Brawe).
/// Cada barra tem fase diferente para efeito orgânico — diferente do TTK.
class WatchLiveButton extends StatefulWidget {
  const WatchLiveButton({super.key, required this.onTap});
  final VoidCallback onTap;

  @override
  State<WatchLiveButton> createState() => _WatchLiveButtonState();
}

class _WatchLiveButtonState extends State<WatchLiveButton>
    with TickerProviderStateMixin {
  // 5 barras, cada uma com AnimationController independente
  static const _barCount = 5;
  static const _phases = [0.0, 0.3, 0.6, 0.15, 0.45];
  static const _durations = [700, 500, 600, 550, 650]; // ms
  late final List<AnimationController> _ctrls;

  @override
  void initState() {
    super.initState();
    _ctrls = List.generate(_barCount, (i) {
      final c = AnimationController(
        vsync: this,
        duration: Duration(milliseconds: _durations[i]),
      );
      // Atraso de fase por barra
      Future.delayed(
        Duration(milliseconds: (_phases[i] * _durations[i]).round()),
        () { if (mounted) c.repeat(reverse: true); },
      );
      return c;
    });
  }

  @override
  void dispose() {
    for (final c in _ctrls) { c.dispose(); }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF7B2FFF), Color(0xFFBF3DFF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF7B2FFF).withValues(alpha: 0.55),
              blurRadius: 18,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Ondas sonoras: 5 barras animadas ──
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_barCount, (i) {
                return Padding(
                  padding: EdgeInsets.only(right: i < _barCount - 1 ? 3 : 0),
                  child: AnimatedBuilder(
                    animation: _ctrls[i],
                    builder: (_, _) {
                      final h = 6 + _ctrls[i].value * 14;
                      return Container(
                        width: 3,
                        height: h,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.85 + _ctrls[i].value * 0.15),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      );
                    },
                  ),
                );
              }),
            ),
            const SizedBox(width: 10),
            Text(
              S.of(context).livePeekWatchLive,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 13,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 👤 Bloco de identidade do streamer: avatar + nome + @username + selo.
/// Para o For You — clicar abre o perfil; o restante da área entra na live.
///
/// Recebe os dados que vêm do feed e, em paralelo, dispara uma busca real
/// ao endpoint /profile/{userId} via [streamerProfileProvider] para
/// preencher qualquer campo ausente (especialmente o avatar — o endpoint
/// /lives nem sempre devolve `streamer_avatar`).
class StreamerIdentity extends ConsumerWidget {
  const StreamerIdentity({
    super.key,
    required this.userId,
    required this.name,
    required this.username,
    this.avatarUrl,
    this.isVerified = false,
    this.onTap,
  });

  final String userId;
  final String name;
  final String username;
  final String? avatarUrl;
  final bool isVerified;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Busca o perfil real apenas se faltar avatar no feed.
    final needsFetch = avatarUrl == null || avatarUrl!.isEmpty;
    final asyncProfile = needsFetch
        ? ref.watch(streamerProfileProvider(userId))
        : const AsyncValue<Profile?>.data(null);

    final fetched = asyncProfile.maybeWhen(
      data: (p) => p,
      orElse: () => null,
    );

    final effectiveAvatar = (avatarUrl != null && avatarUrl!.isNotEmpty)
        ? avatarUrl!
        : (fetched?.avatarUrl ?? '');
    final effectiveName = name.isNotEmpty
        ? name
        : (fetched?.displayName ?? fetched?.username ?? '');
    final effectiveUsername =
        username.isNotEmpty ? username : (fetched?.username ?? '');
    final effectiveVerified = isVerified || (fetched?.isVerified ?? false);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.electricPurple, width: 2),
            ),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.slate,
              backgroundImage: effectiveAvatar.isNotEmpty
                  ? NetworkImage(effectiveAvatar)
                  : null,
              child: effectiveAvatar.isEmpty
                  ? const Icon(Icons.person, color: Colors.white, size: 18)
                  : null,
            ),
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        effectiveName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                          shadows: [
                            Shadow(color: Colors.black54, blurRadius: 6)
                          ],
                        ),
                      ),
                    ),
                    if (effectiveVerified) ...[
                      const SizedBox(width: 4),
                      const Icon(Icons.verified,
                          color: Color(0xFFB6A6FF), size: 15),
                    ],
                  ],
                ),
                if (effectiveUsername.isNotEmpty)
                  Text(
                    '@$effectiveUsername',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.75),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      shadows: const [
                        Shadow(color: Colors.black54, blurRadius: 4)
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

/// Helper de navegação para a live (extraído pra consistência).
void openLiveRoom(BuildContext context, String roomId) {
  if (roomId.isEmpty || roomId == 'missing_id') {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Live indisponível')),
    );
    return;
  }
  context.push('/live/$roomId');
}
