import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../data/model/create_live_room_request_dto.dart';
import '../../../data/repositories/live_repository.dart';
import '../../../domain/models/failure.dart';
import '../../../domain/models/live_room.dart';

part 'start_live_view_model.g.dart';

class StartLiveState {
  const StartLiveState({
    this.title = '',
    this.description = '',
    this.category = '',
    this.isPrivate = false,
    this.status = const AsyncValue<LiveRoom?>.data(null),
  });

  final String title;
  final String description;
  final String category;
  final bool isPrivate;
  final AsyncValue<LiveRoom?> status;

  bool get canSubmit =>
      title.trim().length >= 3 &&
      category.isNotEmpty &&
      !status.isLoading;

  String? get errorMessage => status.whenOrNull(
    error: (error, _) => (error as Failure).toDisplayMessage(),
  );

  StartLiveState copyWith({
    String? title,
    String? description,
    String? category,
    bool? isPrivate,
    AsyncValue<LiveRoom?>? status,
  }) {
    return StartLiveState(
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      isPrivate: isPrivate ?? this.isPrivate,
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

  void togglePrivacy(bool value) {
    state = state.copyWith(
      isPrivate: value,
      status: const AsyncValue.data(null),
    );
  }

  Future<bool> submit() async {
    if (state.status.isLoading) {
      return false;
    }

    if (state.title.trim().length < 3) {
      _setError('Live title must be at least 3 characters.');
      return false;
    }

    if (state.category.isEmpty) {
      _setError('Please select a category for your live.');
      return false;
    }

    state = state.copyWith(status: const AsyncValue.loading());

    final request = CreateLiveRoomRequestDto(
      title: state.title.trim(),
      description: _normalizeText(state.description),
      category: _normalizeText(state.category),
      isPrivate: state.isPrivate,
    );

    try {
      final room = await ref.read(liveRepositoryProvider).initiateLive(request);
      state = state.copyWith(status: AsyncValue.data(room));
      return true;
    } on Failure catch (error, stackTrace) {
      state = state.copyWith(status: AsyncValue.error(error, stackTrace));
      return false;
    } catch (error, stackTrace) {
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

  void _setError(String message) {
    state = state.copyWith(
      status: AsyncValue.error(Failure.validation(message), StackTrace.current),
    );
  }
}
