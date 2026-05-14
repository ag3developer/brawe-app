import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/themes/app_colors.dart';
import '../view_models/edit_profile_view_model.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _bioCtrl = TextEditingController();
  final _instaCtrl = TextEditingController();
  final _twitterCtrl = TextEditingController();
  final _tiktokCtrl = TextEditingController();
  final _ytCtrl = TextEditingController();
  final _siteCtrl = TextEditingController();

  bool _initialized = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _bioCtrl.dispose();
    _instaCtrl.dispose();
    _twitterCtrl.dispose();
    _tiktokCtrl.dispose();
    _ytCtrl.dispose();
    _siteCtrl.dispose();
    super.dispose();
  }

  void _hydrate(EditProfileState s) {
    if (_initialized || s.profile == null) return;
    final p = s.profile!;
    _nameCtrl.text = p.displayName ?? '';
    _bioCtrl.text = p.bio ?? '';
    final links = p.socialLinks ?? const <String, String>{};
    _instaCtrl.text = links['instagram'] ?? '';
    _twitterCtrl.text = links['twitter'] ?? '';
    _tiktokCtrl.text = links['tiktok'] ?? '';
    _ytCtrl.text = links['youtube'] ?? '';
    _siteCtrl.text = links['website'] ?? '';
    _initialized = true;
  }

  Future<void> _onSave() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();

    final socialLinks = <String, String>{};
    void add(String key, TextEditingController c) {
      final v = c.text.trim();
      if (v.isNotEmpty) socialLinks[key] = v;
    }

    add('instagram', _instaCtrl);
    add('twitter', _twitterCtrl);
    add('tiktok', _tiktokCtrl);
    add('youtube', _ytCtrl);
    add('website', _siteCtrl);

    final ok = await ref.read(editProfileViewModelProvider.notifier).save(
          displayName: _nameCtrl.text,
          bio: _bioCtrl.text,
          socialLinks: socialLinks,
        );
    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Perfil atualizado'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(editProfileViewModelProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Editar perfil'),
        actions: [
          TextButton(
            onPressed: async.value?.isSaving == true ? null : _onSave,
            child: async.value?.isSaving == true
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text(
                    'Salvar',
                    style: TextStyle(
                      color: AppColors.mutedRed,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ],
      ),
      body: async.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.mutedRed),
        ),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Erro ao carregar perfil',
              style: TextStyle(color: Colors.white70),
            ),
          ),
        ),
        data: (s) {
          _hydrate(s);
          return SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 32),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _BannerEditor(state: s),
                  const SizedBox(height: 60),
                  _AvatarEditor(state: s),
                  const SizedBox(height: 24),
                  if (s.error != null)
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.withValues(alpha: 0.4)),
                      ),
                      child: Text(s.error!,
                          style: const TextStyle(color: Colors.white)),
                    ),
                  const _SectionLabel('Informações'),
                  _Field(
                    controller: _nameCtrl,
                    label: 'Nome de exibição',
                    maxLength: 50,
                    validator: (v) {
                      if ((v ?? '').trim().isEmpty) return 'Obrigatório';
                      return null;
                    },
                  ),
                  _Field(
                    controller: _bioCtrl,
                    label: 'Bio',
                    maxLength: 500,
                    maxLines: 4,
                    hint: 'Conte um pouco sobre você...',
                  ),
                  const _SectionLabel('Links sociais'),
                  _Field(
                    controller: _instaCtrl,
                    label: 'Instagram',
                    prefixIcon: Icons.camera_alt_outlined,
                    hint: '@usuario',
                  ),
                  _Field(
                    controller: _tiktokCtrl,
                    label: 'TikTok',
                    prefixIcon: Icons.music_note,
                    hint: '@usuario',
                  ),
                  _Field(
                    controller: _twitterCtrl,
                    label: 'X / Twitter',
                    prefixIcon: Icons.alternate_email,
                    hint: '@usuario',
                  ),
                  _Field(
                    controller: _ytCtrl,
                    label: 'YouTube',
                    prefixIcon: Icons.play_circle_outline,
                    hint: 'canal',
                  ),
                  _Field(
                    controller: _siteCtrl,
                    label: 'Website',
                    prefixIcon: Icons.link,
                    hint: 'https://...',
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _BannerEditor extends ConsumerWidget {
  final EditProfileState state;
  const _BannerEditor({required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final url = state.profile?.bannerUrl;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        GestureDetector(
          onTap: () => ref
              .read(editProfileViewModelProvider.notifier)
              .pickAndUploadBanner(),
          child: Container(
            height: 160,
            width: double.infinity,
            color: Colors.white10,
            child: url == null || url.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.image_outlined,
                            size: 40, color: Colors.white54),
                        SizedBox(height: 6),
                        Text('Adicionar banner',
                            style: TextStyle(color: Colors.white54)),
                      ],
                    ),
                  )
                : CachedNetworkImage(imageUrl: url, fit: BoxFit.cover),
          ),
        ),
        if (state.isUploadingBanner)
          Positioned.fill(
            child: Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
          ),
        Positioned(
          right: 12,
          bottom: 12,
          child: Row(
            children: [
              if (url != null && url.isNotEmpty)
                _RoundIconBtn(
                  icon: Icons.delete_outline,
                  onTap: () => ref
                      .read(editProfileViewModelProvider.notifier)
                      .removeBanner(),
                ),
              const SizedBox(width: 8),
              _RoundIconBtn(
                icon: Icons.camera_alt,
                onTap: () => ref
                    .read(editProfileViewModelProvider.notifier)
                    .pickAndUploadBanner(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AvatarEditor extends ConsumerWidget {
  final EditProfileState state;
  const _AvatarEditor({required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final url = state.profile?.avatarUrl;
    return Center(
      child: Transform.translate(
        offset: const Offset(0, -60),
        child: Stack(
          alignment: Alignment.bottomRight,
          children: [
            GestureDetector(
              onTap: () => ref
                  .read(editProfileViewModelProvider.notifier)
                  .pickAndUploadAvatar(),
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.black, width: 4),
                  color: Colors.white12,
                ),
                child: ClipOval(
                  child: url == null || url.isEmpty
                      ? const Icon(Icons.person, size: 64, color: Colors.white54)
                      : CachedNetworkImage(
                          imageUrl: url,
                          fit: BoxFit.cover,
                          width: 120,
                          height: 120,
                        ),
                ),
              ),
            ),
            if (state.isUploadingAvatar)
              Positioned.fill(
                child: Container(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black54,
                  ),
                  child: const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                ),
              )
            else
              _RoundIconBtn(
                icon: Icons.camera_alt,
                onTap: () => ref
                    .read(editProfileViewModelProvider.notifier)
                    .pickAndUploadAvatar(),
              ),
          ],
        ),
      ),
    );
  }
}

class _RoundIconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _RoundIconBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.mutedRed,
      shape: const CircleBorder(),
      elevation: 2,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(icon, color: Colors.white, size: 18),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
          color: AppColors.coolGray,
          fontWeight: FontWeight.w700,
          fontSize: 11,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final int? maxLength;
  final int maxLines;
  final IconData? prefixIcon;
  final FormFieldValidator<String>? validator;

  const _Field({
    required this.controller,
    required this.label,
    this.hint,
    this.maxLength,
    this.maxLines = 1,
    this.prefixIcon,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: TextFormField(
        controller: controller,
        maxLength: maxLength,
        maxLines: maxLines,
        validator: validator,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          labelStyle: const TextStyle(color: AppColors.coolGray),
          hintStyle: const TextStyle(color: Colors.white24),
          prefixIcon: prefixIcon != null
              ? Icon(prefixIcon, color: AppColors.coolGray, size: 20)
              : null,
          filled: true,
          fillColor: Colors.white10,
          counterStyle: const TextStyle(color: AppColors.coolGray),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.mutedRed, width: 1.5),
          ),
        ),
      ),
    );
  }
}
