import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../data/repositories/auth_state_provider.dart';
import '../../../data/services/social_actions_service.dart';
import '../../feed/view_models/feed_view_model.dart';
import '../../feed/view_models/stories_view_model.dart';
import '../../home/view_models/for_you_feed_view_model.dart';
import '../../live_feed/view_models/live_feed_view_model.dart';

part 'hidden_users_view_model.g.dart';

/// Quem o usuário logado não deve ver.
/// - [blocked]: bloqueio é recíproco (eu bloqueei ou fui bloqueado).
/// - [muted]: "Ocultar publicações" — só some dos feeds.
class HiddenUsersState {
  const HiddenUsersState({this.blocked = const {}, this.blockedByMe = const {}, this.muted = const {}});

  final Set<String> blocked;

  /// Bloqueados por mim (posso desbloquear). Os demais de [blocked] me bloquearam.
  final Set<String> blockedByMe;
  final Set<String> muted;

  /// Some dos feeds (publicações, stories, lives).
  bool hidesContentOf(String userId) => blocked.contains(userId) || muted.contains(userId);

  /// Some também do que chega em tempo real (chat da live, presentes).
  bool isBlocked(String userId) => blocked.contains(userId);

  HiddenUsersState copyWith({Set<String>? blocked, Set<String>? blockedByMe, Set<String>? muted}) =>
      HiddenUsersState(
        blocked: blocked ?? this.blocked,
        blockedByMe: blockedByMe ?? this.blockedByMe,
        muted: muted ?? this.muted,
      );
}

/// Listas de bloqueados/ocultados. O servidor já filtra os feeds; isto serve
/// para o que chega por socket e para esconder na hora, sem esperar recarga.
@Riverpod(keepAlive: true)
class HiddenUsers extends _$HiddenUsers {
  @override
  Future<HiddenUsersState> build() async {
    // Recarrega ao trocar de conta (login/logout).
    final userId = ref.watch(authStateProvider.select((a) => a.value?.id));
    if (userId == null) return const HiddenUsersState();
    try {
      final r = await ref.read(socialActionsServiceProvider).hiddenUsers();
      return HiddenUsersState(blocked: r.blocked, blockedByMe: r.blockedByMe, muted: r.muted);
    } catch (_) {
      return const HiddenUsersState();
    }
  }

  HiddenUsersState get _current => state.value ?? const HiddenUsersState();

  /// Bloqueia (slug = @usuário ou id) e já esconde o [userId] em todo o app.
  Future<void> block({required String slug, required String userId}) async {
    await ref.read(socialActionsServiceProvider).blockUser(slug);
    state = AsyncData(_current.copyWith(
      blocked: {..._current.blocked, userId},
      blockedByMe: {..._current.blockedByMe, userId},
    ));
    refreshFeeds();
  }

  Future<void> unblock({required String slug, required String userId}) async {
    await ref.read(socialActionsServiceProvider).unblockUser(slug);
    state = AsyncData(_current.copyWith(
      blocked: {..._current.blocked}..remove(userId),
      blockedByMe: {..._current.blockedByMe}..remove(userId),
    ));
    refreshFeeds();
  }

  Future<void> mute(String userId) async {
    await ref.read(socialActionsServiceProvider).muteUser(userId);
    state = AsyncData(_current.copyWith(muted: {..._current.muted, userId}));
    refreshFeeds();
  }

  Future<void> unmute(String userId) async {
    await ref.read(socialActionsServiceProvider).unmuteUser(userId);
    state = AsyncData(_current.copyWith(muted: {..._current.muted}..remove(userId)));
    refreshFeeds();
  }

  /// Recarrega todos os feeds (o servidor devolve já sem a pessoa).
  void refreshFeeds() {
    ref.invalidate(feedViewModelProvider);
    ref.invalidate(followingFeedViewModelProvider);
    ref.invalidate(forYouFeedViewModelProvider);
    ref.invalidate(storiesViewModelProvider);
    ref.invalidate(liveFeedViewModelProvider);
  }
}
