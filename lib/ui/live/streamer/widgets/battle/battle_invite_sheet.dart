import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../data/repositories/explore_repository.dart';
import '../../../../../data/repositories/live_repository.dart';
import '../../../../../domain/models/live_room.dart';
import '../../../../core/themes/app_colors.dart';

/// Bottom sheet to pick a live creator and invite them for a battle.
///
/// Loads the live feed by default and switches to search results when the
/// user types (with a 450 ms debounce). The [onInvite] callback receives the
/// selected target room id and the chosen battle duration in seconds.
class BattleInviteSheet extends ConsumerStatefulWidget {
  const BattleInviteSheet({
    super.key,
    required this.myRoomId,
    required this.onInvite,
  });

  final String myRoomId;
  final void Function(String targetRoomId, int durationSeconds) onInvite;

  @override
  ConsumerState<BattleInviteSheet> createState() => _BattleInviteSheetState();
}

class _BattleInviteSheetState extends ConsumerState<BattleInviteSheet> {
  final _searchCtrl = TextEditingController();
  Timer? _debounce;
  List<LiveRoom> _rooms = [];
  bool _loading = true;
  String? _error;
  LiveRoom? _selected;
  int _durationSeconds = 300;

  @override
  void initState() {
    super.initState();
    _loadFeed();
    _searchCtrl.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadFeed() async {
    setState(() { _loading = true; _error = null; });
    try {
      final rooms = await ref.read(liveRepositoryProvider).getLiveFeed(limit: 20);
      if (mounted) {
        setState(() {
          _rooms = rooms.where((r) => r.id != widget.myRoomId).toList();
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() { _error = 'Não foi possível carregar criadores ao vivo'; _loading = false; });
    }
  }

  void _onSearchChanged() {
    _debounce?.cancel();
    final q = _searchCtrl.text.trim();
    if (q.isEmpty) {
      _loadFeed();
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 450), () => _search(q));
  }

  Future<void> _search(String q) async {
    setState(() { _loading = true; _error = null; });
    try {
      final results = await ref.read(exploreRepositoryProvider).search(q);
      // Convert live-type results to LiveRoom objects
      final liveRooms = results
          .where((r) => r.type == 'live' && r.id != widget.myRoomId)
          .map((r) => LiveRoom(
                id: r.id,
                slug: r.id,
                title: r.title,
                liveType: 'live',
                isPrivate: false,
                status: 'live',
                streamerId: (r.metadata['streamer_id'] ?? r.id).toString(),
                streamerName: r.subtitle ?? r.title,
                streamerAvatarUrl: r.thumbnail,
                viewerCount: (r.metadata['viewer_count'] as num?)?.toInt() ?? 0,
              ))
          .toList();
      if (mounted) setState(() { _rooms = liveRooms; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = 'Erro na busca'; _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.92,
      expand: false,
      builder: (ctx, scrollCtrl) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFF0E0E14),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Handle
              const SizedBox(height: 12),
              Center(
                child: Container(
                  width: 36, height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.electricPurple.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.sports_kabaddi_rounded,
                          color: AppColors.electricPurple, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Iniciar Batalha',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18)),
                        Text('Escolha um criador ao vivo',
                            style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 13)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Search field
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextField(
                  controller: _searchCtrl,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Buscar criador...',
                    hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.35)),
                    prefixIcon: const Icon(Icons.search_rounded, color: Colors.white54),
                    suffixIcon: _searchCtrl.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, color: Colors.white38, size: 18),
                            onPressed: () { _searchCtrl.clear(); },
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.07),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.electricPurple, width: 1.5),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Duration picker
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Text('Duração:',
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 13)),
                    const SizedBox(width: 10),
                    ...[('3 min', 180), ('5 min', 300), ('10 min', 600)].map((opt) {
                      final selected = _durationSeconds == opt.$2;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: GestureDetector(
                          onTap: () => setState(() => _durationSeconds = opt.$2),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: selected
                                  ? AppColors.electricPurple.withValues(alpha: 0.25)
                                  : Colors.white.withValues(alpha: 0.07),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: selected
                                    ? AppColors.electricPurple.withValues(alpha: 0.7)
                                    : Colors.white.withValues(alpha: 0.1),
                              ),
                            ),
                            child: Text(opt.$1,
                                style: TextStyle(
                                  color: selected ? AppColors.electricPurple : Colors.white60,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                )),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              const Divider(color: Colors.white12, height: 20),
              // Rooms list
              Expanded(
                child: _loading
                    ? const Center(child: CircularProgressIndicator(color: AppColors.electricPurple))
                    : _error != null
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.wifi_off_rounded, color: Colors.white38, size: 36),
                                const SizedBox(height: 8),
                                Text(_error!, style: const TextStyle(color: Colors.white38, fontSize: 13)),
                                const SizedBox(height: 12),
                                TextButton(onPressed: _loadFeed, child: const Text('Tentar novamente',
                                    style: TextStyle(color: AppColors.electricPurple))),
                              ],
                            ),
                          )
                        : _rooms.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.live_tv_rounded, color: Colors.white24, size: 40),
                                    const SizedBox(height: 8),
                                    Text(
                                      _searchCtrl.text.isNotEmpty
                                          ? 'Nenhum criador ao vivo encontrado'
                                          : 'Nenhum criador ao vivo agora',
                                      style: const TextStyle(color: Colors.white38, fontSize: 13),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                controller: scrollCtrl,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                itemCount: _rooms.length,
                                itemBuilder: (_, i) {
                                  final room = _rooms[i];
                                  final isSelected = _selected?.id == room.id;
                                  return GestureDetector(
                                    onTap: () => setState(() =>
                                        _selected = isSelected ? null : room),
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 200),
                                      margin: const EdgeInsets.symmetric(vertical: 4),
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? AppColors.electricPurple.withValues(alpha: 0.15)
                                            : Colors.white.withValues(alpha: 0.04),
                                        borderRadius: BorderRadius.circular(14),
                                        border: Border.all(
                                          color: isSelected
                                              ? AppColors.electricPurple.withValues(alpha: 0.5)
                                              : Colors.white.withValues(alpha: 0.07),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          // Avatar with live badge
                                          Stack(
                                            children: [
                                              CircleAvatar(
                                                radius: 24,
                                                backgroundColor: AppColors.electricPurple.withValues(alpha: 0.3),
                                                backgroundImage: room.streamerAvatarUrl != null
                                                    ? NetworkImage(room.streamerAvatarUrl!)
                                                    : null,
                                                child: room.streamerAvatarUrl == null
                                                    ? Text(
                                                        room.streamerName.isNotEmpty
                                                            ? room.streamerName[0].toUpperCase()
                                                            : '?',
                                                        style: const TextStyle(
                                                            color: Colors.white, fontWeight: FontWeight.w700))
                                                    : null,
                                              ),
                                              Positioned(
                                                bottom: 0, right: 0,
                                                child: Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                                  decoration: BoxDecoration(
                                                    color: Colors.red,
                                                    borderRadius: BorderRadius.circular(6),
                                                    border: Border.all(color: const Color(0xFF0E0E14), width: 1.5),
                                                  ),
                                                  child: const Text('AO VIVO',
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 7,
                                                          fontWeight: FontWeight.w900,
                                                          letterSpacing: 0.3)),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(room.streamerName,
                                                    style: const TextStyle(
                                                        color: Colors.white,
                                                        fontWeight: FontWeight.w700,
                                                        fontSize: 14),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis),
                                                const SizedBox(height: 2),
                                                if (room.title.isNotEmpty)
                                                  Text(room.title,
                                                      style: TextStyle(
                                                          color: Colors.white.withValues(alpha: 0.45),
                                                          fontSize: 12),
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.end,
                                            children: [
                                              Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  const Icon(Icons.remove_red_eye_rounded,
                                                      color: Colors.white38, size: 12),
                                                  const SizedBox(width: 3),
                                                  Text('${room.viewerCount}',
                                                      style: const TextStyle(
                                                          color: Colors.white38,
                                                          fontSize: 12,
                                                          fontWeight: FontWeight.w600)),
                                                ],
                                              ),
                                              if (isSelected)
                                                Padding(
                                                  padding: const EdgeInsets.only(top: 4),
                                                  child: Icon(Icons.check_circle_rounded,
                                                      color: AppColors.electricPurple, size: 18),
                                                ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
              ),
              // Invite button
              Padding(
                padding: EdgeInsets.fromLTRB(20, 8, 20, MediaQuery.of(context).padding.bottom + 16),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: _selected != null
                          ? const LinearGradient(colors: [Color(0xFF7C3AED), AppColors.electricPurple])
                          : null,
                      color: _selected == null ? Colors.white.withValues(alpha: 0.07) : null,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: _selected != null
                          ? [BoxShadow(
                              color: AppColors.electricPurple.withValues(alpha: 0.35),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            )]
                          : null,
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: _selected == null
                            ? null
                            : () => widget.onInvite(_selected!.id, _durationSeconds),
                        child: Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.send_rounded,
                                  color: _selected != null ? Colors.white : Colors.white30, size: 18),
                              const SizedBox(width: 8),
                              Text(
                                _selected != null
                                    ? 'Convidar ${_selected!.streamerName}'
                                    : 'Selecione um criador',
                                style: TextStyle(
                                  color: _selected != null ? Colors.white : Colors.white30,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 15,
                                  letterSpacing: 0.3,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
