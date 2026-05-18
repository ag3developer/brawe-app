import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';
import '../../core/themes/app_colors.dart';
import '../view_models/stories_view_model.dart';

class CreateStorySheet extends ConsumerStatefulWidget {
  /// Se [initialRemoteUrl] for fornecido, a sheet abre já com essa imagem
  /// pré-carregada (baixada para um arquivo temporário). Usado pelo
  /// "Compartilhar como Story" no feed.
  const CreateStorySheet({super.key, this.initialRemoteUrl});

  final String? initialRemoteUrl;

  @override
  ConsumerState<CreateStorySheet> createState() => _CreateStorySheetState();
}

class _CreateStorySheetState extends ConsumerState<CreateStorySheet> {
  final TextEditingController _captionController = TextEditingController();
  File? _selectedFile;
  String _mediaType = 'image';
  bool _isPublishing = false;
  bool _isPrefetching = false;
  VideoPlayerController? _videoPreviewController;

  @override
  void initState() {
    super.initState();
    final url = widget.initialRemoteUrl;
    if (url != null && url.isNotEmpty) {
      _prefetchRemote(url);
    }
  }

  Future<void> _prefetchRemote(String url) async {
    setState(() => _isPrefetching = true);
    try {
      final dir = await getTemporaryDirectory();
      final isVideo = url.endsWith('.mp4') ||
          url.endsWith('.mov') ||
          url.endsWith('.webm');
      final ext = isVideo ? 'mp4' : 'jpg';
      final tmpPath =
          '${dir.path}/story_share_${DateTime.now().millisecondsSinceEpoch}.$ext';
      final dio = Dio();
      await dio.download(url, tmpPath);
      if (!mounted) return;
      await _setSelected(XFile(tmpPath), isVideo: isVideo);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Falha ao carregar imagem do post.')),
      );
    } finally {
      if (mounted) setState(() => _isPrefetching = false);
    }
  }

  @override
  void dispose() {
    _captionController.dispose();
    _videoPreviewController?.dispose();
    super.dispose();
  }

  Future<void> _setSelected(XFile picked, {required bool isVideo}) async {
    await _videoPreviewController?.dispose();
    _videoPreviewController = null;

    final file = File(picked.path);
    if (isVideo) {
      final ctrl = VideoPlayerController.file(file);
      try {
        await ctrl.initialize();
        ctrl
          ..setLooping(true)
          ..setVolume(0)
          ..play();
        _videoPreviewController = ctrl;
      } catch (_) {
        // ignore — fallback: vai mostrar spinner
      }
    }
    if (!mounted) return;
    setState(() {
      _selectedFile = file;
      _mediaType = isVideo ? 'video' : 'image';
    });
  }

  Future<void> _pickFromGallery({required bool isVideo}) async {
    final picker = ImagePicker();
    final XFile? picked = isVideo
        ? await picker.pickVideo(
            source: ImageSource.gallery,
            maxDuration: const Duration(seconds: 60),
          )
        : await picker.pickImage(
            source: ImageSource.gallery, imageQuality: 85);
    if (picked != null) {
      await _setSelected(picked, isVideo: isVideo);
    }
  }

  Future<void> _pickFromCamera({required bool isVideo}) async {
    final picker = ImagePicker();
    final XFile? picked = isVideo
        ? await picker.pickVideo(
            source: ImageSource.camera,
            maxDuration: const Duration(seconds: 60),
          )
        : await picker.pickImage(
            source: ImageSource.camera, imageQuality: 85);
    if (picked != null) {
      await _setSelected(picked, isVideo: isVideo);
    }
  }

  Future<void> _resetSelection() async {
    await _videoPreviewController?.dispose();
    _videoPreviewController = null;
    if (!mounted) return;
    setState(() => _selectedFile = null);
  }

  Future<void> _publish() async {
    if (_selectedFile == null) return;
    setState(() => _isPublishing = true);
    try {
      await ref.read(storiesViewModelProvider.notifier).createStory(
            localFilePath: _selectedFile!.path,
            mediaType: _mediaType,
            caption: _captionController.text.trim().isEmpty
                ? null
                : _captionController.text.trim(),
          );
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Story publicado!'),
          backgroundColor: AppColors.electricPurple,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _isPublishing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro ao publicar story. Tente novamente.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedPadding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      duration: const Duration(milliseconds: 100),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.92,
        ),
        decoration: const BoxDecoration(
          color: Color(0xFF141824),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white24,
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
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: _isPublishing
                        ? null
                        : () => Navigator.of(context).pop(),
                  ),
                  const Expanded(
                    child: Text(
                      'Novo story',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: (_selectedFile != null && !_isPublishing)
                        ? _publish
                        : null,
                    child: _isPublishing
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.electricPurple,
                            ),
                          )
                        : const Text(
                            'Publicar',
                            style: TextStyle(
                              color: AppColors.electricPurple,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ],
              ),
            ),

            // Preview / picker
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: AspectRatio(
                aspectRatio: 9 / 16,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white12),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: _isPrefetching
                      ? const Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircularProgressIndicator(
                                color: AppColors.electricPurple,
                              ),
                              SizedBox(height: 12),
                              Text(
                                'Carregando imagem do post...',
                                style: TextStyle(color: Colors.white70),
                              ),
                            ],
                          ),
                        )
                      : _selectedFile == null
                      ? _PickerPlaceholder(
                          onGalleryImage: () =>
                              _pickFromGallery(isVideo: false),
                          onGalleryVideo: () =>
                              _pickFromGallery(isVideo: true),
                          onCameraImage: () =>
                              _pickFromCamera(isVideo: false),
                          onCameraVideo: () =>
                              _pickFromCamera(isVideo: true),
                        )
                      : _mediaType == 'image'
                          ? Image.file(_selectedFile!, fit: BoxFit.cover)
                          : (_videoPreviewController != null &&
                                  _videoPreviewController!
                                      .value.isInitialized)
                              ? FittedBox(
                                  fit: BoxFit.cover,
                                  child: SizedBox(
                                    width: _videoPreviewController!
                                        .value.size.width,
                                    height: _videoPreviewController!
                                        .value.size.height,
                                    child: VideoPlayer(
                                        _videoPreviewController!),
                                  ),
                                )
                              : Container(
                                  color: Colors.black54,
                                  alignment: Alignment.center,
                                  child: const CircularProgressIndicator(
                                    color: AppColors.electricPurple,
                                  ),
                                ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Caption
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: TextField(
                controller: _captionController,
                style: const TextStyle(color: Colors.white),
                maxLength: 200,
                decoration: InputDecoration(
                  hintText: 'Escreva uma legenda (opcional)…',
                  hintStyle: const TextStyle(color: Colors.white38),
                  filled: true,
                  fillColor: const Color(0xFF1F2433),
                  counterStyle: const TextStyle(color: Colors.white38),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            if (_selectedFile != null && !_isPublishing)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Row(
                  children: [
                    TextButton.icon(
                      onPressed: _resetSelection,
                      icon: const Icon(Icons.refresh, color: Colors.white70),
                      label: const Text(
                        'Trocar mídia',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _PickerPlaceholder extends StatelessWidget {
  const _PickerPlaceholder({
    required this.onGalleryImage,
    required this.onGalleryVideo,
    required this.onCameraImage,
    required this.onCameraVideo,
  });

  final VoidCallback onGalleryImage;
  final VoidCallback onGalleryVideo;
  final VoidCallback onCameraImage;
  final VoidCallback onCameraVideo;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF0F1320),
      alignment: Alignment.center,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.add_a_photo_outlined,
                color: Colors.white54, size: 56),
            const SizedBox(height: 12),
            const Text(
              'Selecione ou grave uma mídia',
              style: TextStyle(color: Colors.white70, fontSize: 15),
            ),
            const SizedBox(height: 6),
            const Text(
              'Foto ou vídeo (até 60s)',
              style: TextStyle(color: Colors.white38, fontSize: 12),
            ),
            const SizedBox(height: 20),
            const _SectionLabel(label: 'Galeria'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              alignment: WrapAlignment.center,
              children: [
                _PickerChip(
                    icon: Icons.photo_library,
                    label: 'Foto',
                    onTap: onGalleryImage),
                _PickerChip(
                    icon: Icons.video_library,
                    label: 'Vídeo',
                    onTap: onGalleryVideo),
              ],
            ),
            const SizedBox(height: 18),
            const _SectionLabel(label: 'Câmera'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              alignment: WrapAlignment.center,
              children: [
                _PickerChip(
                    icon: Icons.photo_camera,
                    label: 'Foto',
                    onTap: onCameraImage),
                _PickerChip(
                    icon: Icons.videocam,
                    label: 'Gravar vídeo',
                    onTap: onCameraVideo),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});
  final String label;
  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: const TextStyle(
        color: Colors.white54,
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.2,
      ),
    );
  }
}

class _PickerChip extends StatelessWidget {
  const _PickerChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF1F2433),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 6),
            Text(label, style: const TextStyle(color: Colors.white)),
          ],
        ),
      ),
    );
  }
}
