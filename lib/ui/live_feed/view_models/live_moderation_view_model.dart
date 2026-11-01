import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/repositories/auth_state_provider.dart';
import '../../../data/repositories/live_repository.dart';
import '../../../data/services/live_moderation_service.dart';
import '../../../domain/models/live_moderation.dart';
import '../../../domain/models/live_room_event.dart';

/// Moderação do chat de UMA sala: mensagem fixada, modo lento, último erro de
/// envio e se EU sou moderador.
///
/// Fica separado do view model de comentários de propósito: o chat é o
/// caminho quente (uma emissão por mensagem) e nada daqui deve reconstruir a
/// árvore grande — os widgets assinam só o pedaço que usam, com `select`.
final liveModerationProvider = NotifierProvider.autoDispose
    .family<LiveModerationViewModel, LiveModerationState, String>(
      LiveModerationViewModel.new,
    );

class LiveModerationViewModel extends Notifier<LiveModerationState> {
  LiveModerationViewModel(this.roomId);

  final String roomId;

  /// Quanto tempo o aviso de erro fica na tela.
  static const errorLifetime = Duration(seconds: 4);

  Timer? _errorTimer;

  @override
  LiveModerationState build() {
    final repo = ref.read(liveRepositoryProvider);
    final subs = <StreamSubscription<dynamic>>[
      repo.watchRoomEvents(roomId).listen(_onRoomEvent),
      repo.watchComments(roomId).listen((c) {
        if (c.isModerator && c.userId == _myId) _setModerator();
      }),
      repo.watchViewerEvents(roomId).listen((e) {
        if (e.joined && e.isModerator && e.userId == _myId) _setModerator();
      }),
      // Socket voltou: pode ter perdido pin/modo lento.
      repo.watchReconnects().listen((_) => _loadInitial()),
    ];
    ref.onDispose(() {
      _errorTimer?.cancel();
      for (final s in subs) {
        s.cancel();
      }
    });
    _loadInitial();
    return const LiveModerationState();
  }

  String? get _myId => ref.read(authStateProvider).value?.id;

  void _setModerator() {
    if (!state.isModerator) state = state.copyWith(isModerator: true);
  }

  Future<void> _loadInitial() async {
    final s = await ref.read(liveModerationServiceProvider).getRoomState(roomId);
    if (!ref.mounted || s == null) return;
    state = state.copyWith(
      pin: s.pin,
      clearPin: s.pin == null,
      slowModeS: s.slowModeS,
    );
  }

  void _onRoomEvent(LiveRoomEvent e) {
    switch (e.type) {
      case LiveRoomEvent.chatError:
        final err = ChatError.tryParse(e.data);
        if (err == null) return;
        _showError(err);
      case LiveRoomEvent.slowMode:
        final s = parseSlowModeInterval(e.data);
        if (s != null && s != state.slowModeS) {
          state = state.copyWith(slowModeS: s);
        }
      case LiveRoomEvent.chatPinned:
        if (!e.data.containsKey('pin')) return;
        final pin = ChatPin.tryParse(e.data['pin']);
        if (pin == state.pin) return;
        state = pin == null
            ? state.copyWith(clearPin: true)
            : state.copyWith(pin: pin);
      case LiveRoomEvent.chatMuted:
        final n = ChatMuteNotice.tryParse(e.data);
        if (n == null) return;
        state = n.muted
            ? state.copyWith(muted: true, mutedUntil: n.until, clearMutedUntil: n.until == null)
            : state.copyWith(muted: false, clearMutedUntil: true);
    }
  }

  void _showError(ChatError err) {
    if (err.kind == ChatErrorKind.muted) {
      state = state.copyWith(
        error: err,
        muted: true,
        mutedUntil: err.until,
        clearMutedUntil: err.until == null,
      );
    } else {
      state = state.copyWith(error: err);
    }
    _errorTimer?.cancel();
    _errorTimer = Timer(errorLifetime, () {
      if (ref.mounted) state = state.copyWith(clearError: true);
    });
  }

  void dismissError() {
    _errorTimer?.cancel();
    if (state.error != null) state = state.copyWith(clearError: true);
  }

  // ── Ações (criador / moderador) ───────────────────────────────────────

  LiveModerationService get _api => ref.read(liveModerationServiceProvider);

  Future<ModerationResult> mute(String userId, {int? minutes}) =>
      _api.mute(roomId, userId, minutes: minutes);

  Future<ModerationResult> unmute(String userId) => _api.unmute(roomId, userId);

  Future<ModerationResult> pinMessage({
    required String text,
    String? messageId,
    String? authorName,
    String? authorId,
  }) => _api.pin(
    roomId,
    text: text,
    messageId: messageId,
    authorName: authorName,
    authorId: authorId,
  );

  Future<ModerationResult> unpin() => _api.unpin(roomId);
}
