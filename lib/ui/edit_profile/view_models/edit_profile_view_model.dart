import 'package:image_picker/image_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../data/repositories/profile_repository.dart';
import '../../../domain/models/profile.dart';

part 'edit_profile_view_model.g.dart';

/// Error codes for the edit profile flow. Widget layer resolves these to
/// localized strings via `S.of(context)`.
enum EditProfileErrorCode {
  saveFailed,
  usernameTooShort,
  usernameCheckFailed,
  usernameInUse,
  usernameSaveFailed,
  avatarUploadFailed,
  bannerUploadFailed,
  avatarRemoveFailed,
  bannerRemoveFailed,
}

class EditProfileState {
  final Profile? profile;
  final bool isSaving;
  final bool isUploadingAvatar;
  final bool isUploadingBanner;
  final EditProfileErrorCode? error;
  final bool savedOnce;
  // Username-specific
  final bool isCheckingUsername;
  /// `null` = OK. When set, the widget should display the corresponding
  /// localized message. `usernameErrorMessage` carries the backend-provided
  /// message when the error is not an `EditProfileErrorCode`.
  final EditProfileErrorCode? usernameError;
  final String? usernameErrorMessage;
  final bool usernameAvailable;

  const EditProfileState({
    this.profile,
    this.isSaving = false,
    this.isUploadingAvatar = false,
    this.isUploadingBanner = false,
    this.error,
    this.savedOnce = false,
    this.isCheckingUsername = false,
    this.usernameError,
    this.usernameErrorMessage,
    this.usernameAvailable = false,
  });

  EditProfileState copyWith({
    Profile? profile,
    bool? isSaving,
    bool? isUploadingAvatar,
    bool? isUploadingBanner,
    EditProfileErrorCode? error,
    bool clearError = false,
    bool? savedOnce,
    bool? isCheckingUsername,
    EditProfileErrorCode? usernameError,
    String? usernameErrorMessage,
    bool clearUsernameError = false,
    bool? usernameAvailable,
  }) {
    return EditProfileState(
      profile: profile ?? this.profile,
      isSaving: isSaving ?? this.isSaving,
      isUploadingAvatar: isUploadingAvatar ?? this.isUploadingAvatar,
      isUploadingBanner: isUploadingBanner ?? this.isUploadingBanner,
      error: clearError ? null : (error ?? this.error),
      savedOnce: savedOnce ?? this.savedOnce,
      isCheckingUsername: isCheckingUsername ?? this.isCheckingUsername,
      usernameError:
          clearUsernameError ? null : (usernameError ?? this.usernameError),
      usernameErrorMessage: clearUsernameError
          ? null
          : (usernameErrorMessage ?? this.usernameErrorMessage),
      usernameAvailable: usernameAvailable ?? this.usernameAvailable,
    );
  }
}

@riverpod
class EditProfileViewModel extends _$EditProfileViewModel {
  @override
  Future<EditProfileState> build() async {
    final repo = ref.read(profileRepositoryProvider);
    final me = await repo.getMyProfile();
    return EditProfileState(profile: me);
  }

  Future<bool> save({
    required String displayName,
    required String bio,
    required Map<String, String> socialLinks,
  }) async {
    final current = state.value;
    if (current == null) return false;

    state = AsyncValue.data(current.copyWith(isSaving: true, clearError: true));
    try {
      final repo = ref.read(profileRepositoryProvider);
      final updated = await repo.updateMyProfile(
        displayName: displayName.trim().isEmpty ? null : displayName.trim(),
        bio: bio,
        socialLinks: socialLinks,
      );
      state = AsyncValue.data(current.copyWith(
        profile: updated,
        isSaving: false,
        savedOnce: true,
      ));
      return true;
    } catch (e) {
      state = AsyncValue.data(current.copyWith(
        isSaving: false,
        error: EditProfileErrorCode.saveFailed,
      ));
      return false;
    }
  }

  /// Verifica disponibilidade do username em tempo real (debounce no widget).
  Future<void> checkUsername(String username) async {
    final current = state.value;
    if (current == null) return;

    final trimmed = username.trim().toLowerCase();

    // Se for igual ao username atual, está sempre disponível
    final currentUsername = current.profile?.username?.toLowerCase() ?? '';
    if (trimmed == currentUsername) {
      state = AsyncValue.data(current.copyWith(
        isCheckingUsername: false,
        clearUsernameError: true,
        usernameAvailable: true,
      ));
      return;
    }

    if (trimmed.length < 3) {
      state = AsyncValue.data(current.copyWith(
        isCheckingUsername: false,
        usernameError: EditProfileErrorCode.usernameTooShort,
        usernameAvailable: false,
      ));
      return;
    }

    state = AsyncValue.data(current.copyWith(
      isCheckingUsername: true,
      clearUsernameError: true,
      usernameAvailable: false,
    ));

    try {
      final repo = ref.read(profileRepositoryProvider);
      final error = await repo.checkUsernameAvailability(trimmed);
      final st = state.value;
      if (st == null) return;
      state = AsyncValue.data(st.copyWith(
        isCheckingUsername: false,
        usernameErrorMessage: error,
        usernameAvailable: error == null,
      ));
    } catch (_) {
      final st = state.value;
      if (st == null) return;
      state = AsyncValue.data(st.copyWith(
        isCheckingUsername: false,
        usernameError: EditProfileErrorCode.usernameCheckFailed,
        usernameAvailable: false,
      ));
    }
  }

  /// Salva apenas o username. Retorna `true` em caso de sucesso.
  Future<bool> saveUsername(String username) async {
    final current = state.value;
    if (current == null) return false;
    final trimmed = username.trim().toLowerCase();
    if (trimmed.isEmpty) return false;

    // Se não mudou, não faz nada
    if (trimmed == (current.profile?.username?.toLowerCase() ?? '')) return true;

    state = AsyncValue.data(current.copyWith(isSaving: true, clearError: true));
    try {
      final repo = ref.read(profileRepositoryProvider);
      final newUsername = await repo.updateUsername(trimmed);
      final updated = current.profile?.copyWith(username: newUsername);
      state = AsyncValue.data(current.copyWith(
        profile: updated,
        isSaving: false,
        savedOnce: true,
        clearUsernameError: true,
        usernameAvailable: false, // reset
      ));
      return true;
    } on Object catch (e) {
      final code = e.toString().contains('unauthorized')
          ? EditProfileErrorCode.usernameInUse
          : EditProfileErrorCode.usernameSaveFailed;
      state = AsyncValue.data(current.copyWith(
        isSaving: false,
        error: code,
      ));
      return false;
    }
  }

  /// Abre a galeria e retorna o `path` do arquivo escolhido, ou `null`.
  /// Não faz upload — usado para pré-posicionamento.
  Future<String?> pickImageFromGallery({
    int imageQuality = 90,
    double? maxWidth,
    double? maxHeight,
  }) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: imageQuality,
      maxWidth: maxWidth,
      maxHeight: maxHeight,
    );
    return picked?.path;
  }

  /// Faz upload de um arquivo de avatar já preparado (recortado).
  Future<void> uploadAvatarFromPath(String path) async {
    final current = state.value;
    if (current == null) return;
    try {
      state = AsyncValue.data(
          current.copyWith(isUploadingAvatar: true, clearError: true));
      final repo = ref.read(profileRepositoryProvider);
      final url = await repo.uploadAvatar(path);
      final updated = current.profile?.copyWith(avatarUrl: url);
      state = AsyncValue.data(current.copyWith(
        profile: updated,
        isUploadingAvatar: false,
      ));
    } catch (e) {
      state = AsyncValue.data(state.value!.copyWith(
        isUploadingAvatar: false,
        error: EditProfileErrorCode.avatarUploadFailed,
      ));
    }
  }

  /// Faz upload de um arquivo de banner já preparado (recortado).
  Future<void> uploadBannerFromPath(String path) async {
    final current = state.value;
    if (current == null) return;
    try {
      state = AsyncValue.data(
          current.copyWith(isUploadingBanner: true, clearError: true));
      final repo = ref.read(profileRepositoryProvider);
      final url = await repo.uploadBanner(path);
      final updated = current.profile?.copyWith(bannerUrl: url);
      state = AsyncValue.data(current.copyWith(
        profile: updated,
        isUploadingBanner: false,
      ));
    } catch (e) {
      state = AsyncValue.data(state.value!.copyWith(
        isUploadingBanner: false,
        error: EditProfileErrorCode.bannerUploadFailed,
      ));
    }
  }

  Future<void> removeAvatar() async {
    final current = state.value;
    if (current == null) return;
    try {
      state = AsyncValue.data(current.copyWith(isUploadingAvatar: true));
      final repo = ref.read(profileRepositoryProvider);
      await repo.deleteAvatar();
      final updated = current.profile?.copyWith(avatarUrl: null);
      state = AsyncValue.data(current.copyWith(
        profile: updated,
        isUploadingAvatar: false,
      ));
    } catch (e) {
      state = AsyncValue.data(state.value!.copyWith(
        isUploadingAvatar: false,
        error: EditProfileErrorCode.avatarRemoveFailed,
      ));
    }
  }

  Future<void> removeBanner() async {
    final current = state.value;
    if (current == null) return;
    try {
      state = AsyncValue.data(current.copyWith(isUploadingBanner: true));
      final repo = ref.read(profileRepositoryProvider);
      await repo.deleteBanner();
      final updated = current.profile?.copyWith(bannerUrl: null);
      state = AsyncValue.data(current.copyWith(
        profile: updated,
        isUploadingBanner: false,
      ));
    } catch (e) {
      state = AsyncValue.data(state.value!.copyWith(
        isUploadingBanner: false,
        error: EditProfileErrorCode.bannerRemoveFailed,
      ));
    }
  }
}
