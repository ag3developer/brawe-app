import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../data/model/create_live_room_request_dto.dart';
import '../../../data/repositories/auth_state_provider.dart';
import '../../../data/repositories/live_repository.dart';
import '../../../domain/models/failure.dart';
import '../../../domain/models/live_room.dart';
import '../../../domain/models/user.dart';
import '../../../gen/l10n/app_localizations.dart';

part 'start_live_view_model.g.dart';

/// Códigos de erro de validação client-side para o fluxo de Start Live.
/// O widget resolve para a string localizada via `S.of(context)`.
enum StartLiveValidation { titleTooShort, categoryRequired }

class StartLiveState {
  const StartLiveState({
    this.title = '',
    this.description = '',
    this.category = '',
    this.visibility = LiveVisibility.public,
    this.notifyFollowers = true,
    this.battleModeEnabled = true,
    this.giftsEnabled = true,
    this.thumbnailUrl,
    this.status = const AsyncValue<LiveRoom?>.data(null),
  });

  final String title;
  final String description;
  final String category;
  final LiveVisibility visibility;
  final bool notifyFollowers;
  final bool battleModeEnabled;
  final bool giftsEnabled;
  final String? thumbnailUrl;
  final AsyncValue<LiveRoom?> status;

  bool get canSubmit =>
      title.trim().length >= 3 && category.isNotEmpty && !status.isLoading;

  String? get errorMessage => status.whenOrNull(
    error: (error, _) => (error as Failure).toDisplayMessage(),
  );

  /// Resolve a mensagem de erro localizada. Para erros de validação
  /// client-side, mapeia `StartLiveValidation.<name>` → string i18n.
  /// Para outras falhas, usa `Failure.toDisplayMessage()`.
  String? displayError(S s) => status.whenOrNull(
    error: (error, _) {
      if (error is Failure) {
        return error.maybeWhen(
          validation: (message) {
            switch (message) {
              case 'titleTooShort':
                return s.startLiveErrorTitleTooShort;
              case 'categoryRequired':
                return s.startLiveErrorCategoryRequired;
              default:
                return message ?? error.toDisplayMessage();
            }
          },
          orElse: () => error.toDisplayMessage(),
        );
      }
      return error.toString();
    },
  );

  StartLiveState copyWith({
    String? title,
    String? description,
    String? category,
    LiveVisibility? visibility,
    bool? notifyFollowers,
    bool? battleModeEnabled,
    bool? giftsEnabled,
    String? thumbnailUrl,
    bool clearThumbnail = false,
    AsyncValue<LiveRoom?>? status,
  }) {
    return StartLiveState(
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      visibility: visibility ?? this.visibility,
      notifyFollowers: notifyFollowers ?? this.notifyFollowers,
      battleModeEnabled: battleModeEnabled ?? this.battleModeEnabled,
      giftsEnabled: giftsEnabled ?? this.giftsEnabled,
      thumbnailUrl: clearThumbnail ? null : (thumbnailUrl ?? this.thumbnailUrl),
      status: status ?? this.status,
    );
  }
}

@riverpod
class StartLiveViewModel extends _$StartLiveViewModel {
  @override
  StartLiveState build() => const StartLiveState();

  void updateTitle(String value) {
    state = state.copyWith(title: value, status: const AsyncValue.data(null));
  }

  void updateDescription(String value) {
    state = state.copyWith(
      description: value,
      status: const AsyncValue.data(null),
    );
  }

  void updateCategory(String value) {
    state = state.copyWith(
      category: value,
      status: const AsyncValue.data(null),
    );
  }

  void updateVisibility(LiveVisibility value) {
    state = state.copyWith(
      visibility: value,
      status: const AsyncValue.data(null),
    );
  }

  void toggleBattleMode(bool value) {
    state = state.copyWith(
      battleModeEnabled: value,
      status: const AsyncValue.data(null),
    );
  }

  void toggleGifts(bool value) {
    state = state.copyWith(
      giftsEnabled: value,
      status: const AsyncValue.data(null),
    );
  }

  void toggleNotifyFollowers(bool value) {
    state = state.copyWith(
      notifyFollowers: value,
      status: const AsyncValue.data(null),
    );
  }

  void setThumbnail(String? url) {
    state = state.copyWith(
      thumbnailUrl: url,
      clearThumbnail: url == null,
      status: const AsyncValue.data(null),
    );
  }

  Future<bool> submit() async {
    if (state.status.isLoading) {
      return false;
    }

    if (state.title.trim().length < 3) {
      _setError(StartLiveValidation.titleTooShort);
      return false;
    }

    if (state.category.isEmpty) {
      _setError(StartLiveValidation.categoryRequired);
      return false;
    }

    state = state.copyWith(status: const AsyncValue.loading());

    // 🆕 Identidade do streamer: o backend prioriza esses campos para evitar
    // salas com nome "Streamer" quando o wallet_bridge falha entre microserviços.
    final authState = ref.read(authStateProvider);
    final currentUser = authState is AsyncData<User?> ? authState.value : null;
    final streamerName = _resolveStreamerName(currentUser);

    final request = CreateLiveRoomRequestDto(
      title: state.title.trim(),
      description: _normalizeText(state.description),
      category: _normalizeText(state.category),
      visibility: state.visibility,
      notifyFollowers: state.notifyFollowers,
      thumbnailUrl: state.thumbnailUrl,
      streamerName: streamerName,
      streamerAvatarUrl: currentUser?.avatarUrl,
    );

    try {
      // ignore: avoid_print
      print(
        '[StartLive] Sending POST /rooms — title="${request.title}" category="${request.category}"',
      );
      final room = await ref.read(liveRepositoryProvider).initiateLive(request);
      // ignore: avoid_print
      print(
        '[StartLive] ✅ Room created — id=${room.id} streamKey=${room.streamKey != null ? "<set>" : "<null>"} rtmp=${room.rtmpUrl != null ? "<set>" : "<null>"}',
      );
      state = state.copyWith(status: AsyncValue.data(room));
      return true;
    } on Failure catch (error, stackTrace) {
      // ignore: avoid_print
      print('[StartLive] ❌ Failure: $error');
      state = state.copyWith(status: AsyncValue.error(error, stackTrace));
      return false;
    } catch (error, stackTrace) {
      // ignore: avoid_print
      print('[StartLive] ❌ Unknown error: $error');
      state = state.copyWith(
        status: AsyncValue.error(const Failure.unknown(), stackTrace),
      );
      return false;
    }
  }

  String? _normalizeText(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return null;
    }
    return trimmed;
  }

  /// Resolve o nome a ser enviado ao backend como `streamer_name`.
  /// Prioriza `user.name`; cai para a parte local do email; nunca retorna
  /// "Streamer" — se nada for resolvível, retorna `null` para o backend
  /// usar o wallet_bridge / self-heal.
  String? _resolveStreamerName(User? user) {
    if (user == null) return null;
    final name = user.name.trim();
    if (name.isNotEmpty) return name;
    final email = user.email.trim();
    if (email.isNotEmpty) {
      final local = email.split('@').first.trim();
      if (local.isNotEmpty) return local;
    }
    return null;
  }

  void _setError(StartLiveValidation code) {
    state = state.copyWith(
      status: AsyncValue.error(
        Failure.validation(code.name),
        StackTrace.current,
      ),
    );
  }
}
