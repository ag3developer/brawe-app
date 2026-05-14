import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../data/repositories/post_repository.dart';
import '../../core/themes/app_colors.dart';
import '../view_models/feed_view_model.dart';
import '../../home/view_models/for_you_feed_view_model.dart';

class CreatePostSheet extends ConsumerStatefulWidget {
  const CreatePostSheet({super.key});

  @override
  ConsumerState<CreatePostSheet> createState() => _CreatePostSheetState();
}

class _CreatePostSheetState extends ConsumerState<CreatePostSheet> {
  final TextEditingController _textController = TextEditingController();
  File? _selectedImage;
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
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Post publicado!'),
          backgroundColor: AppColors.electricPurple,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _isPosting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro ao publicar. Tente novamente.'),
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

  @override
  Widget build(BuildContext context) {
    final canPost =
        _textController.text.trim().isNotEmpty && _charCount <= _maxChars;

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
            // Handle
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

            // Top bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 18,
                    backgroundColor: AppColors.slate,
                    child: Icon(Icons.person,
                        color: AppColors.coolGray, size: 18),
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
                            _audience,
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
                          : AppColors.slate,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: _isPosting
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Publicar',
                            style: TextStyle(
                              color: Colors.white,
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
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        height: 1.5,
                      ),
                      decoration: const InputDecoration(
                        hintText: 'O que está acontecendo?',
                        hintStyle: TextStyle(
                          color: AppColors.coolGray,
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
                                child: const Icon(Icons.close,
                                    color: Colors.white, size: 16),
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),

            // Bottom toolbar
            Container(
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: Colors.white10)),
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
                            backgroundColor: Colors.white10,
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
                                    : AppColors.coolGray,
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
      backgroundColor: AppColors.slate,
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
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Quem pode ver?',
                style: TextStyle(
                  color: Colors.white,
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
                  option,
                  style: TextStyle(
                    color: _audience == option
                        ? AppColors.electricPurple
                        : Colors.white,
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
  const _ToolbarBtn({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon, color: AppColors.electricPurple, size: 22),
      onPressed: onTap,
    );
  }
}