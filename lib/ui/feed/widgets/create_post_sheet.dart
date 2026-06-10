import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../data/repositories/post_repository.dart';
import '../../../domain/models/sound.dart';
import '../../../gen/l10n/app_localizations.dart';
import '../../core/themes/app_colors.dart';
import '../../core/themes/brawe_colors.dart';
import '../../feed/view_models/feed_view_model.dart';
import '../../home/view_models/for_you_feed_view_model.dart';
import '../../sounds/view_models/sound_player_view_model.dart';
import '../../sounds/widgets/sounds_catalog_screen.dart';

class CreatePostSheet extends ConsumerStatefulWidget {
  const CreatePostSheet({super.key});

  @override
  ConsumerState<CreatePostSheet> createState() => _CreatePostSheetState();
}

class _CreatePostSheetState extends ConsumerState<CreatePostSheet> {
  final TextEditingController _textController = TextEditingController();
  File? _selectedImage;
  Sound? _selectedSound;
  bool _isPosting = false;
  String _audience = 'Todos';

  int get _charCount => _textController.text.length;
  static const _maxChars = 500;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _post() async {
    if (_textController.text.trim().isEmpty) return;
    setState(() => _isPosting = true);
    try {
      await ref.read(postRepositoryProvider).createPost(
            content: _textController.text.trim(),
            imageLocalPath: _selectedImage?.path,
            audience: _audience,
          );
      // Refresh feeds para o post novo aparecer imediatamente.
      ref.invalidate(feedViewModelProvider);
      ref.invalidate(forYouFeedViewModelProvider);
      if (!mounted) return;
      final s = S.of(context);
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(s.postPublishedSuccess),
          backgroundColor: AppColors.electricPurple,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _isPosting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(S.of(context).postPublishError),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (picked != null) {
      setState(() => _selectedImage = File(picked.path));
    }
  }

  Future<void> _pickSound() async {
    // Para o player atual antes de abrir o catálogo
    ref.read(soundPlayerViewModelProvider.notifier).stop();

    final sound = await Navigator.of(context).push<Sound>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => const SoundsCatalogScreen(),
      ),
    );
    if (sound != null && mounted) {
      setState(() => _selectedSound = sound);
      // Inicia preview do som selecionado
      ref.read(soundPlayerViewModelProvider.notifier).play(sound);
    }
  }

  void _removeSound() {
    ref.read(soundPlayerViewModelProvider.notifier).stop();
    setState(() => _selectedSound = null);
  }

  String _audienceLabel(S s, String value) => switch (value) {
        'Seguidores' => s.audienceFollowers,
        'Apenas eu' => s.audienceOnlyMe,
        _ => s.audienceAll,
      };

  @override
  Widget build(BuildContext context) {
    final canPost =
        _textController.text.trim().isNotEmpty && _charCount <= _maxChars;
    final s = S.of(context);

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
          color: context.colors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: context.colors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Top bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Row(
                children: [
                   CircleAvatar(
                    radius: 18,
                    backgroundColor: context.colors.surfaceElevated,
                    child: Icon(Icons.person,
                        color: context.colors.textSecondary, size: 18),
                  ),
                  const SizedBox(width: 12),
                  // Audience selector
                  GestureDetector(
                    onTap: _showAudiencePicker,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: AppColors.electricPurple.withValues(alpha: 0.5),
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _audienceLabel(s, _audience),
                            style: const TextStyle(
                              color: AppColors.electricPurple,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.keyboard_arrow_down,
                              color: AppColors.electricPurple, size: 14),
                        ],
                      ),
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: canPost && !_isPosting ? _post : null,
                    style: TextButton.styleFrom(
                      backgroundColor: canPost && !_isPosting
                          ? AppColors.electricPurple
                          : context.colors.surfaceElevated,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: _isPosting
                        ? SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              color: context.colors.textPrimary,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            s.postPublish,
                            style: TextStyle(
                              color: context.colors.textPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ],
              ),
            ),

            // Text input
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _textController,
                      autofocus: true,
                      style: TextStyle(
                        color: context.colors.textPrimary,
                        fontSize: 16,
                        height: 1.5,
                      ),
                      decoration:  InputDecoration(
                        hintText: s.postHintWhatsHappening,
                        hintStyle: TextStyle(
                          color: context.colors.textSecondary,
                          fontSize: 16,
                        ),
                        border: InputBorder.none,
                      ),
                      maxLines: null,
                      onChanged: (_) => setState(() {}),
                    ),

                    // Preview selected image
                    if (_selectedImage != null)
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              _selectedImage!,
                              height: 180,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: GestureDetector(
                              onTap: () =>
                                  setState(() => _selectedImage = null),
                              child: Container(
                                width: 28,
                                height: 28,
                                decoration: const BoxDecoration(
                                  color: Colors.black54,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(Icons.close,
                                    color: context.colors.textPrimary, size: 16),
                              ),
                            ),
                          ),
                        ],
                      ),

                    // Chip do som selecionado
                    if (_selectedSound != null) ...[
                      const SizedBox(height: 10),
                      _SelectedSoundChip(
                        sound: _selectedSound!,
                        onRemove: _removeSound,
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // Bottom toolbar
            Container(
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: context.colors.border)),
              ),
              padding: const EdgeInsets.fromLTRB(8, 8, 16, 12),
              child: Row(
                children: [
                  _ToolbarBtn(
                    icon: Icons.image_outlined,
                    onTap: _pickImage,
                  ),
                  _ToolbarBtn(
                    icon: Icons.gif_outlined,
                    onTap: () {},
                  ),
                  _ToolbarBtn(
                    icon: Icons.poll_outlined,
                    onTap: () {},
                  ),
                  _ToolbarBtn(
                    icon: Icons.tag,
                    onTap: () {},
                  ),
                  _ToolbarBtn(
                    icon: Icons.location_on_outlined,
                    onTap: () {},
                  ),
                  _ToolbarBtn(
                    icon: LucideIcons.music,
                    onTap: _pickSound,
                    active: _selectedSound != null,
                    activeColor: const Color(0xFFE11D48),
                  ),
                  const Spacer(),
                  // Char counter
                  if (_charCount > 0)
                    SizedBox(
                      width: 32,
                      height: 32,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CircularProgressIndicator(
                            value: _charCount / _maxChars,
                            strokeWidth: 2.5,
                            backgroundColor: context.colors.border,
                            color: _charCount > _maxChars * 0.9
                                ? Colors.orange
                                : AppColors.electricPurple,
                          ),
                          if (_charCount > _maxChars * 0.8)
                            Text(
                              '${_maxChars - _charCount}',
                              style: TextStyle(
                                color: _charCount > _maxChars
                                    ? Colors.red
                                    : context.colors.textSecondary,
                                fontSize: 10,
                              ),
                            ),
                        ],
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

  void _showAudiencePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.colors.surfaceElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: context.colors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                S.of(context).audiencePickerTitle,
                style: TextStyle(
                  color: context.colors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            for (final option in ['Todos', 'Seguidores', 'Apenas eu'])
              ListTile(
                leading: Icon(
                  option == 'Todos'
                      ? Icons.public
                      : option == 'Seguidores'
                          ? Icons.people
                          : Icons.lock,
                  color: _audience == option
                      ? AppColors.electricPurple
                      : Colors.white,
                ),
                title: Text(
                  _audienceLabel(S.of(context), option),
                  style: TextStyle(
                    color: _audience == option
                        ? AppColors.electricPurple
                        : context.colors.textPrimary,
                    fontWeight: _audience == option
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
                trailing: _audience == option
                    ? const Icon(Icons.check, color: AppColors.electricPurple)
                    : null,
                onTap: () {
                  setState(() => _audience = option);
                  Navigator.pop(context);
                },
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _ToolbarBtn extends StatelessWidget {
  const _ToolbarBtn({
    required this.icon,
    required this.onTap,
    this.active = false,
    this.activeColor,
  });
  final IconData icon;
  final VoidCallback onTap;
  final bool active;
  final Color? activeColor;

  @override
  Widget build(BuildContext context) {
    final color = active
        ? (activeColor ?? AppColors.electricPurple)
        : AppColors.electricPurple;
    return IconButton(
      icon: Icon(icon, color: color, size: 22),
      onPressed: onTap,
    );
  }
}

class _SelectedSoundChip extends StatelessWidget {
  const _SelectedSoundChip({required this.sound, required this.onRemove});
  final Sound sound;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: context.colors.surfaceElevated,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE11D48).withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Cover thumbnail
          if (sound.coverUrl != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Image.network(
                sound.coverUrl!,
                width: 32,
                height: 32,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _fallbackIcon(),
              ),
            )
          else
            _fallbackIcon(),
          const SizedBox(width: 8),
          // Info
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  sound.title,
                  style: TextStyle(
                    color: context.colors.textPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  sound.artist.artistName,
                  style: TextStyle(
                    color: context.colors.textSecondary,
                    fontSize: 11,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          // Remove button
          GestureDetector(
            onTap: onRemove,
            child: Icon(
              LucideIcons.x,
              size: 16,
              color: context.colors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _fallbackIcon() {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: const Color(0xFFE11D48).withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Image.asset(
          'assets/images/brawe_sounds_icon.png',
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}