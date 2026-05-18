import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';

import '../../../data/repositories/post_repository.dart';
import '../../core/themes/brawe_colors.dart';
import '../../home/view_models/for_you_feed_view_model.dart';
import '../view_models/feed_view_model.dart';

/// Bottom sheet de criação de post de **vídeo** (Reels / Shorts).
///
/// Fluxo:
/// 1. Usuário escolhe vídeo da galeria (ou grava — TODO v2)
/// 2. Preview com `video_player`
/// 3. Caption opcional
/// 4. Publicar → upload `/posts/upload-video` + criar post
/// 5. Invalida `forYouFeedViewModelProvider` → aparece imediatamente.
class CreateVideoSheet extends ConsumerStatefulWidget {
  const CreateVideoSheet({super.key});

  @override
  ConsumerState<CreateVideoSheet> createState() => _CreateVideoSheetState();
}

class _CreateVideoSheetState extends ConsumerState<CreateVideoSheet> {
  final TextEditingController _captionCtrl = TextEditingController();
  File? _video;
  VideoPlayerController? _videoCtrl;
  bool _isPublishing = false;
  bool _pickerOpened = false;

  static const int _maxBytes = 100 * 1024 * 1024; // 100 MB
  static const Duration _maxDuration = Duration(minutes: 3);

  @override
  void initState() {
    super.initState();
    // Abre o picker assim que o sheet aparecer.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_pickerOpened) {
        _pickerOpened = true;
        _pickVideo();
      }
    });
  }

  @override
  void dispose() {
    _captionCtrl.dispose();
    _videoCtrl?.dispose();
    super.dispose();
  }

  Future<void> _pickVideo() async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickVideo(
        source: ImageSource.gallery,
        maxDuration: _maxDuration,
      );
      if (picked == null) {
        if (mounted && _video == null) {
          // Usuário cancelou e não tem vídeo ainda → fecha o sheet.
          Navigator.of(context).pop();
        }
        return;
      }
      final file = File(picked.path);
      final size = await file.length();
      if (size > _maxBytes) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vídeo muito grande. Máximo 100 MB.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      final ctrl = VideoPlayerController.file(file);
      await ctrl.initialize();
      await ctrl.setLooping(true);
      await ctrl.play();
      if (!mounted) {
        await ctrl.dispose();
        return;
      }
      setState(() {
        _video = file;
        _videoCtrl?.dispose();
        _videoCtrl = ctrl;
      });
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Não foi possível abrir o vídeo.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _publish() async {
    final video = _video;
    if (video == null) return;
    setState(() => _isPublishing = true);
    try {
      await ref.read(postRepositoryProvider).createVideoPost(
            videoLocalPath: video.path,
            content: _captionCtrl.text.trim(),
          );
      ref.invalidate(forYouFeedViewModelProvider);
      ref.invalidate(feedViewModelProvider);
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Vídeo publicado!'),
          backgroundColor: context.colors.accentPrimary,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _isPublishing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro ao publicar vídeo. Tente novamente.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final hasVideo = _video != null && _videoCtrl?.value.isInitialized == true;
    final canPublish = hasVideo && !_isPublishing;

    return AnimatedPadding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      duration: const Duration(milliseconds: 100),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.92,
        ),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: colors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.close, color: colors.textPrimary),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Novo vídeo',
                    style: TextStyle(
                      color: colors.textPrimary,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: canPublish ? _publish : null,
                    style: TextButton.styleFrom(
                      backgroundColor: canPublish
                          ? colors.accentPrimary
                          : colors.surfaceHighest,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: _isPublishing
                        ? SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              color: colors.textOnAccent,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            'Publicar',
                            style: TextStyle(
                              color: canPublish
                                  ? colors.textOnAccent
                                  : colors.textTertiary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ],
              ),
            ),

            // Body
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Preview area
                    AspectRatio(
                      aspectRatio: 9 / 16,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: hasVideo
                            ? Stack(
                                fit: StackFit.expand,
                                children: [
                                  FittedBox(
                                    fit: BoxFit.cover,
                                    child: SizedBox(
                                      width: _videoCtrl!.value.size.width,
                                      height: _videoCtrl!.value.size.height,
                                      child: VideoPlayer(_videoCtrl!),
                                    ),
                                  ),
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: GestureDetector(
                                      onTap: _pickVideo,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: Colors.black54,
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: const Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.swap_horiz,
                                                color: Colors.white, size: 16),
                                            SizedBox(width: 4),
                                            Text(
                                              'Trocar',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : GestureDetector(
                                onTap: _pickVideo,
                                child: Container(
                                  color: colors.surfaceElevated,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.video_library_outlined,
                                          color: colors.textSecondary,
                                          size: 48),
                                      const SizedBox(height: 12),
                                      Text(
                                        'Selecionar vídeo da galeria',
                                        style: TextStyle(
                                          color: colors.textPrimary,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'MP4/MOV/WebM · até 3 min · 100 MB',
                                        style: TextStyle(
                                          color: colors.textTertiary,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Caption
                    TextField(
                      controller: _captionCtrl,
                      maxLines: 3,
                      maxLength: 300,
                      style: TextStyle(
                        color: colors.textPrimary,
                        fontSize: 15,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Escreva uma legenda (opcional)…',
                        hintStyle: TextStyle(color: colors.textTertiary),
                        filled: true,
                        fillColor: colors.surfaceElevated,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        counterStyle:
                            TextStyle(color: colors.textTertiary, fontSize: 11),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
