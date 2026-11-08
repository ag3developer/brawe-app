import 'package:cached_network_image/cached_network_image.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:video_player/video_player.dart';

import '../../../data/repositories/gallery_repository.dart';
import '../../../domain/models/gallery_media.dart';
import '../../../gen/l10n/app_localizations.dart';
import '../../core/themes/app_colors.dart';
import '../../core/themes/brawe_colors.dart';
import '../view_models/gallery_view_model.dart';
import 'profile_videos_grid.dart' show ProfileEmptyState;
import '../../../core/network/media_headers.dart';
import 'package:brawe_app/ui/core/ui/image_decode.dart';

/// Mini-galeria do perfil (até 6 fotos + 3 vídeos curtos).
/// Paridade com `components/connect/ProfileGallery.tsx` do web.
class ProfileGalleryGrid extends ConsumerStatefulWidget {
  const ProfileGalleryGrid({
    super.key,
    required this.userId,
    required this.isMe,
  });

  final String userId;
  final bool isMe;

  @override
  ConsumerState<ProfileGalleryGrid> createState() => _ProfileGalleryGridState();
}

class _ProfileGalleryGridState extends ConsumerState<ProfileGalleryGrid>
    with SingleTickerProviderStateMixin {
  late final TabController _tab = TabController(length: 2, vsync: this);

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final asyncData = ref.watch(galleryViewModelProvider(widget.userId));

    return RefreshIndicator(
      color: context.colors.accentPrimary,
      onRefresh: () =>
          ref.read(galleryViewModelProvider(widget.userId).notifier).refresh(),
      child: asyncData.when(
        loading: () => Center(
          child: CircularProgressIndicator(color: context.colors.accentPrimary),
        ),
        error: (_, _) => ListView(
          children: [
            const SizedBox(height: 120),
            Center(
              child: Text(
                S.of(context).profileGalleryLoadError,
                style: TextStyle(color: context.colors.textSecondary),
              ),
            ),
          ],
        ),
        data: (data) => Column(
          children: [
            Container(
              color: context.colors.background,
              child: TabBar(
                controller: _tab,
                indicatorColor: context.colors.textPrimary,
                dividerColor: context.colors.divider,
                labelColor: context.colors.textPrimary,
                unselectedLabelColor: context.colors.textSecondary,
                tabs: [
                  Tab(
                    text: S
                        .of(context)
                        .profileGalleryTabPhotos(
                          data.photos.length,
                          data.limits?.maxPhotos ?? 6,
                        ),
                  ),
                  Tab(
                    text: S
                        .of(context)
                        .profileGalleryTabVideos(
                          data.videos.length,
                          data.limits?.maxVideos ?? 3,
                        ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tab,
                children: [
                  _MediaGrid(
                    userId: widget.userId,
                    items: data.photos,
                    isMe: widget.isMe,
                    maxItems: data.limits?.maxPhotos ?? 6,
                    onAdd: _pickPhoto,
                  ),
                  _MediaGrid(
                    userId: widget.userId,
                    items: data.videos,
                    isMe: widget.isMe,
                    maxItems: data.limits?.maxVideos ?? 3,
                    onAdd: _pickVideo,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickPhoto() async {
    final f = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 2048,
    );
    if (f == null || !mounted) return;
    _showProgress();
    final ok = await ref
        .read(galleryViewModelProvider(widget.userId).notifier)
        .uploadPhoto(f.path);
    if (mounted) Navigator.of(context, rootNavigator: true).pop();
    if (!mounted) return;
    final s = S.of(context);
    _toast(ok ? s.profileGalleryPhotoAdded : s.profileGalleryPhotoError);
  }

  Future<void> _pickVideo() async {
    final f = await ImagePicker().pickVideo(
      source: ImageSource.gallery,
      maxDuration: const Duration(seconds: 60),
    );
    if (f == null || !mounted) return;
    _showProgress();
    final ok = await ref
        .read(galleryViewModelProvider(widget.userId).notifier)
        .uploadVideo(f.path);
    if (mounted) Navigator.of(context, rootNavigator: true).pop();
    if (!mounted) return;
    final s = S.of(context);
    _toast(ok ? s.profileGalleryVideoAdded : s.profileGalleryVideoError);
  }

  void _showProgress() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Center(
        child: CircularProgressIndicator(color: ctx.colors.accentPrimary),
      ),
    );
  }

  void _toast(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}

class _MediaGrid extends ConsumerWidget {
  const _MediaGrid({
    required this.userId,
    required this.items,
    required this.isMe,
    required this.maxItems,
    required this.onAdd,
  });

  final String userId;
  final List<GalleryMedia> items;
  final bool isMe;
  final int maxItems;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showAdd = isMe && items.length < maxItems;
    final tileCount = items.length + (showAdd ? 1 : 0);

    if (tileCount == 0) {
      return ProfileEmptyState(
        icon: LucideIcons.images,
        title: S.of(context).profileGalleryEmpty,
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(2),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
      ),
      itemCount: tileCount,
      itemBuilder: (context, index) {
        if (showAdd && index == items.length) {
          return _AddTile(onTap: onAdd);
        }
        final m = items[index];
        return _MediaTile(userId: userId, media: m, isMe: isMe);
      },
    );
  }
}

class _AddTile extends StatelessWidget {
  const _AddTile({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: context.colors.surfaceHighest,
          border: Border.all(color: context.colors.border),
        ),
        child: Center(
          child: Icon(
            LucideIcons.imagePlus,
            color: context.colors.textSecondary,
            size: 32,
          ),
        ),
      ),
    );
  }
}

class _MediaTile extends ConsumerWidget {
  const _MediaTile({
    required this.userId,
    required this.media,
    required this.isMe,
  });
  final String userId;
  final GalleryMedia media;
  final bool isMe;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isVideo = media.mediaType == 'video';
    final thumb = media.thumbnailUrl ?? media.url;

    return GestureDetector(
      onTap: () {
        // Track view (não-crítico)
        ref.read(galleryRepositoryProvider).registerView(media.id);
        Navigator.of(context).push(
          MaterialPageRoute(
            fullscreenDialog: true,
            builder: (_) => _MediaViewer(userId: userId, media: media),
          ),
        );
      },
      onLongPress: isMe ? () => _confirmDelete(context, ref) : null,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CachedNetworkImage(
            memCacheWidth: context.decodeScreenFracPx(1 / 3),
            imageUrl: thumb,
            fit: BoxFit.cover,
            placeholder: (_, _) =>
                Container(color: context.colors.surfaceHighest),
            errorWidget: (_, _, _) => Container(
              color: context.colors.surfaceHighest,
              child: Icon(
                LucideIcons.imageOff,
                color: context.colors.textTertiary,
              ),
            ),
          ),
          if (isVideo)
            const Positioned(
              right: 6,
              top: 6,
              child: Icon(
                LucideIcons.circlePlay,
                color: Colors.white,
                size: 22,
              ),
            ),
          if (media.likesCount > 0)
            Positioned(
              left: 6,
              bottom: 6,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      LucideIcons.heart,
                      color: Colors.white,
                      size: 12,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      media.likesCount.toString(),
                      style: const TextStyle(color: Colors.white, fontSize: 11),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: ctx.colors.surface,
        title: Text(
          S.of(ctx).profileGalleryRemoveTitle,
          style: TextStyle(color: ctx.colors.textPrimary),
        ),
        content: Text(
          S.of(ctx).profileGalleryRemoveBody,
          style: TextStyle(color: ctx.colors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              S.of(ctx).actionCancel,
              style: TextStyle(color: ctx.colors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              S.of(ctx).profileGalleryRemove,
              style: TextStyle(color: ctx.colors.danger),
            ),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await ref
        .read(galleryViewModelProvider(userId).notifier)
        .deleteMedia(media);
  }
}

/// Viewer fullscreen — foto com pinch-to-zoom, vídeo com chewie controls.
class _MediaViewer extends ConsumerStatefulWidget {
  const _MediaViewer({required this.userId, required this.media});
  final String userId;
  final GalleryMedia media;

  @override
  ConsumerState<_MediaViewer> createState() => _MediaViewerState();
}

class _MediaViewerState extends ConsumerState<_MediaViewer> {
  VideoPlayerController? _video;
  ChewieController? _chewie;

  @override
  void initState() {
    super.initState();
    if (widget.media.mediaType == 'video') {
      // Versão leve (HLS do Bunny) quando existe; senão o arquivo original.
      final playUrl = (widget.media.hlsUrl?.isNotEmpty ?? false)
          ? widget.media.hlsUrl!
          : widget.media.url;
      _video = VideoPlayerController.networkUrl(
        Uri.parse(playUrl),
        httpHeaders: mediaHeadersFor(playUrl),
      );
      _video!.initialize().then((_) {
        if (!mounted) return;
        setState(() {
          _chewie = ChewieController(
            // Ao sair da tela cheia volta para RETRATO (o app é travado em
            // retrato; o padrão do Chewie liberava todas as orientações).
            deviceOrientationsAfterFullScreen: const [
              DeviceOrientation.portraitUp,
            ],
            videoPlayerController: _video!,
            autoPlay: true,
            looping: true,
            allowMuting: true,
            materialProgressColors: ChewieProgressColors(
              playedColor: AppColors.braweBlue,
              handleColor: AppColors.braweBlue,
              backgroundColor: Colors.white24,
              bufferedColor: Colors.white38,
            ),
          );
        });
      });
    }
  }

  @override
  void dispose() {
    _chewie?.dispose();
    _video?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final m = widget.media;
    final isVideo = m.mediaType == 'video';

    return Scaffold(
      // Fullscreen media viewer: always dark behind the photo/video.
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      extendBodyBehindAppBar: true,
      body: Center(
        child: isVideo
            ? (_chewie != null
                  ? Chewie(controller: _chewie!)
                  : CircularProgressIndicator(
                      color: context.colors.accentPrimary,
                    ))
            : InteractiveViewer(
                child: CachedNetworkImage(
                  memCacheWidth: context.decodeScreenPx,
                  imageUrl: m.url,
                  fit: BoxFit.contain,
                  placeholder: (_, _) => CircularProgressIndicator(
                    color: context.colors.accentPrimary,
                  ),
                ),
              ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          color: Colors.black54,
          child: Row(
            children: [
              IconButton(
                onPressed: () {
                  ref
                      .read(galleryViewModelProvider(widget.userId).notifier)
                      .toggleLike(m);
                  setState(() {});
                },
                icon: Icon(
                  LucideIcons.heart,
                  color: m.isLiked ? context.colors.danger : Colors.white,
                ),
              ),
              Text(
                '${m.likesCount}',
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(width: 16),
              const Icon(LucideIcons.eye, color: Colors.white54, size: 18),
              const SizedBox(width: 4),
              Text(
                '${m.viewsCount}',
                style: const TextStyle(color: Colors.white54),
              ),
              const Spacer(),
              if (m.caption != null && m.caption!.isNotEmpty)
                Flexible(
                  child: Text(
                    m.caption!,
                    style: const TextStyle(color: Colors.white70),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
