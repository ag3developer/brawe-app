import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../data/repositories/gallery_repository.dart';
import '../../../domain/models/gallery_media.dart';

part 'gallery_view_model.g.dart';

@riverpod
class GalleryViewModel extends _$GalleryViewModel {
  @override
  Future<GalleryData> build(String userId) async {
    return ref.read(galleryRepositoryProvider).getUserGallery(userId);
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref.read(galleryRepositoryProvider).getUserGallery(userId),
    );
  }

  Future<bool> uploadPhoto(String filePath, {String? caption}) async {
    try {
      final media = await ref
          .read(galleryRepositoryProvider)
          .uploadPhoto(filePath, caption: caption);
      final current = state.value;
      if (current != null) {
        state = AsyncValue.data(
          GalleryData(
            photos: [...current.photos, media],
            videos: current.videos,
            limits: current.limits,
          ),
        );
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> uploadVideo(String filePath, {String? caption}) async {
    try {
      final media = await ref
          .read(galleryRepositoryProvider)
          .uploadVideo(filePath, caption: caption);
      final current = state.value;
      if (current != null) {
        state = AsyncValue.data(
          GalleryData(
            photos: current.photos,
            videos: [...current.videos, media],
            limits: current.limits,
          ),
        );
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> deleteMedia(GalleryMedia m) async {
    final current = state.value;
    if (current == null) return;
    state = AsyncValue.data(
      GalleryData(
        photos: current.photos.where((x) => x.id != m.id).toList(),
        videos: current.videos.where((x) => x.id != m.id).toList(),
        limits: current.limits,
      ),
    );
    try {
      await ref.read(galleryRepositoryProvider).deleteMedia(m.id);
    } catch (_) {
      await refresh();
    }
  }

  Future<void> toggleLike(GalleryMedia m) async {
    final current = state.value;
    if (current == null) return;
    GalleryMedia toggle(GalleryMedia x) => x.id == m.id
        ? x.copyWith(
            isLiked: !x.isLiked,
            likesCount: x.likesCount + (x.isLiked ? -1 : 1),
          )
        : x;
    state = AsyncValue.data(
      GalleryData(
        photos: current.photos.map(toggle).toList(),
        videos: current.videos.map(toggle).toList(),
        limits: current.limits,
      ),
    );
    try {
      await ref.read(galleryRepositoryProvider).toggleLike(m.id);
    } catch (_) {
      await refresh();
    }
  }
}
