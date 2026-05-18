import 'package:image_picker/image_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../data/repositories/profile_repository.dart';
import '../../../domain/models/profile.dart';

part 'edit_profile_view_model.g.dart';

class EditProfileState {
  final Profile? profile;
  final bool isSaving;
  final bool isUploadingAvatar;
  final bool isUploadingBanner;
  final String? error;
  final bool savedOnce;

  const EditProfileState({
    this.profile,
    this.isSaving = false,
    this.isUploadingAvatar = false,
    this.isUploadingBanner = false,
    this.error,
    this.savedOnce = false,
  });

  EditProfileState copyWith({
    Profile? profile,
    bool? isSaving,
    bool? isUploadingAvatar,
    bool? isUploadingBanner,
    String? error,
    bool clearError = false,
    bool? savedOnce,
  }) {
    return EditProfileState(
      profile: profile ?? this.profile,
      isSaving: isSaving ?? this.isSaving,
      isUploadingAvatar: isUploadingAvatar ?? this.isUploadingAvatar,
      isUploadingBanner: isUploadingBanner ?? this.isUploadingBanner,
      error: clearError ? null : (error ?? this.error),
      savedOnce: savedOnce ?? this.savedOnce,
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
        error: 'Não foi possível salvar. Tente de novo.',
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
        error: 'Falha ao enviar avatar.',
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
        error: 'Falha ao enviar banner.',
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
        error: 'Falha ao remover avatar.',
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
        error: 'Falha ao remover banner.',
      ));
    }
  }
}
