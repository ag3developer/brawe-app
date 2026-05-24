import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/themes/app_colors.dart';
import '../../core/themes/brawe_colors.dart';
import '../../../gen/l10n/app_localizations.dart';
import '../view_models/edit_profile_view_model.dart';
import 'image_position_editor.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _bioCtrl = TextEditingController();
  final _instaCtrl = TextEditingController();
  final _twitterCtrl = TextEditingController();
  final _tiktokCtrl = TextEditingController();
  final _ytCtrl = TextEditingController();
  final _siteCtrl = TextEditingController();

  Timer? _usernameDebounce;
  bool _initialized = false;

  @override
  void dispose() {
    _usernameDebounce?.cancel();
    _usernameCtrl.dispose();
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
    _usernameCtrl.text = p.username ?? '';
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

    // Salva username separadamente se foi alterado
    final vmState = ref.read(editProfileViewModelProvider).value;
    final currentUsername = vmState?.profile?.username?.toLowerCase() ?? '';
    final newUsername = _usernameCtrl.text.trim().toLowerCase();
    if (ok && newUsername.isNotEmpty && newUsername != currentUsername) {
      final usernameOk = await ref
          .read(editProfileViewModelProvider.notifier)
          .saveUsername(newUsername);
      if (!mounted) return;
      if (!usernameOk) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(S.of(context).editProfileSavedUsernameFailed),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }
    }
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(S.of(context).editProfileSaved),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final async = ref.watch(editProfileViewModelProvider);

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        backgroundColor: context.colors.background,
        foregroundColor: context.colors.textPrimary,
        elevation: 0,
        title: Text(s.editProfileTitle),
        actions: [
          TextButton(
            onPressed: async.value?.isSaving == true ? null : _onSave,
            child: async.value?.isSaving == true
                ? SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: context.colors.textPrimary,
                    ),
                  )
                : Text(
                    s.editProfileSave,
                    style: const TextStyle(
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
              s.editProfileLoadError,
              style: TextStyle(color: context.colors.textSecondary),
            ),
          ),
        ),
        data: (state) {
          _hydrate(state);
          return SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 32),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _BannerEditor(state: state),
                  const SizedBox(height: 60),
                  _AvatarEditor(state: state),
                  const SizedBox(height: 24),
                  if (state.error != null)
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.withValues(alpha: 0.4)),
                      ),
                      child: Text(_errorMessage(s, state.error!),
                          style: TextStyle(color: context.colors.textPrimary)),
                    ),
                  _SectionLabel(s.editProfileSectionInfo),
                  _UsernameField(
                    controller: _usernameCtrl,
                    state: state,
                    onChanged: (val) {
                      _usernameDebounce?.cancel();
                      _usernameDebounce = Timer(
                        const Duration(milliseconds: 600),
                        () => ref
                            .read(editProfileViewModelProvider.notifier)
                            .checkUsername(val),
                      );
                    },
                  ),
                  _Field(
                    controller: _nameCtrl,
                    label: s.editProfileFieldName,
                    maxLength: 50,
                    validator: (v) {
                      if ((v ?? '').trim().isEmpty) {
                        return s.editProfileFieldNameRequired;
                      }
                      return null;
                    },
                  ),
                  _Field(
                    controller: _bioCtrl,
                    label: s.editProfileFieldBio,
                    maxLength: 500,
                    maxLines: 4,
                    hint: s.editProfileFieldBioHint,
                  ),
                  _SectionLabel(s.editProfileSectionSocial),
                  _Field(
                    controller: _instaCtrl,
                    label: s.editProfileSocialInstagram,
                    prefixIcon: Icons.camera_alt_outlined,
                    hint: s.editProfileSocialUserHint,
                  ),
                  _Field(
                    controller: _tiktokCtrl,
                    label: s.editProfileSocialTikTok,
                    prefixIcon: Icons.music_note,
                    hint: s.editProfileSocialUserHint,
                  ),
                  _Field(
                    controller: _twitterCtrl,
                    label: s.editProfileSocialTwitter,
                    prefixIcon: Icons.alternate_email,
                    hint: s.editProfileSocialUserHint,
                  ),
                  _Field(
                    controller: _ytCtrl,
                    label: s.editProfileSocialYouTube,
                    prefixIcon: Icons.play_circle_outline,
                    hint: s.editProfileSocialChannelHint,
                  ),
                  _Field(
                    controller: _siteCtrl,
                    label: s.editProfileSocialWebsite,
                    prefixIcon: Icons.link,
                    hint: s.editProfileSocialUrlHint,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _errorMessage(S s, EditProfileErrorCode code) {
    switch (code) {
      case EditProfileErrorCode.saveFailed:
        return s.editProfileErrorSaveFailed;
      case EditProfileErrorCode.usernameTooShort:
        return s.editProfileUsernameTooShort;
      case EditProfileErrorCode.usernameCheckFailed:
        return s.editProfileErrorUsernameCheck;
      case EditProfileErrorCode.usernameInUse:
        return s.editProfileErrorUsernameInUse;
      case EditProfileErrorCode.usernameSaveFailed:
        return s.editProfileErrorUsernameSaveFailed;
      case EditProfileErrorCode.avatarUploadFailed:
        return s.editProfileErrorAvatarUpload;
      case EditProfileErrorCode.bannerUploadFailed:
        return s.editProfileErrorBannerUpload;
      case EditProfileErrorCode.avatarRemoveFailed:
        return s.editProfileErrorAvatarRemove;
      case EditProfileErrorCode.bannerRemoveFailed:
        return s.editProfileErrorBannerRemove;
    }
  }
}

class _BannerEditor extends ConsumerWidget {
  final EditProfileState state;
  const _BannerEditor({required this.state});

  Future<void> _pickAndPositionBanner(
      BuildContext context, WidgetRef ref) async {
    final vm = ref.read(editProfileViewModelProvider.notifier);
    final picked = await vm.pickImageFromGallery(imageQuality: 95);
    if (picked == null || !context.mounted) return;
    final cropped = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => ImagePositionEditor(
          sourcePath: picked,
          aspectRatio: 3.0,
          circle: false,
          title: S.of(context).editProfileBannerPosition,
          outputWidth: 1500,
        ),
      ),
    );
    if (cropped == null) return;
    await vm.uploadBannerFromPath(cropped);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final url = state.profile?.bannerUrl;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        GestureDetector(
          onTap: () => _pickAndPositionBanner(context, ref),
          child: Container(
            height: 160,
            width: double.infinity,
            color: Colors.white10,
            child: url == null || url.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.image_outlined,
                            size: 40, color: context.colors.textTertiary),
                        SizedBox(height: 6),
                        Text(S.of(context).editProfileBannerAdd,
                            style: TextStyle(color: context.colors.textTertiary)),
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
              child: Center(
                child: CircularProgressIndicator(color: context.colors.textPrimary),
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
                onTap: () => _pickAndPositionBanner(context, ref),
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

  Future<void> _pickAndPositionAvatar(
      BuildContext context, WidgetRef ref) async {
    final vm = ref.read(editProfileViewModelProvider.notifier);
    final picked = await vm.pickImageFromGallery(imageQuality: 95);
    if (picked == null || !context.mounted) return;
    final cropped = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => ImagePositionEditor(
          sourcePath: picked,
          aspectRatio: 1.0,
          circle: true,
          title: S.of(context).editProfileAvatarPosition,
          outputWidth: 1024,
        ),
      ),
    );
    if (cropped == null) return;
    await vm.uploadAvatarFromPath(cropped);
  }

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
              onTap: () => _pickAndPositionAvatar(context, ref),
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.black, width: 4),
                  color: context.colors.divider,
                ),
                child: ClipOval(
                  child: url == null || url.isEmpty
                      ? Icon(Icons.person,
                          size: 64, color: context.colors.textTertiary)
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
                  child: Center(
                    child: CircularProgressIndicator(color: context.colors.textPrimary),
                  ),
                ),
              )
            else
              _RoundIconBtn(
                icon: Icons.camera_alt,
                onTap: () => _pickAndPositionAvatar(context, ref),
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
          child: Icon(icon, color: context.colors.textPrimary, size: 18),
        ),
      ),
    );
  }
}

class _UsernameField extends StatelessWidget {
  final TextEditingController controller;
  final EditProfileState state;
  final ValueChanged<String> onChanged;

  const _UsernameField({
    required this.controller,
    required this.state,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    Widget? suffixIcon;
    String? helperText;
    Color helperColor = Colors.white54;

    if (state.isCheckingUsername) {
      suffixIcon =  Padding(
        padding: EdgeInsets.all(12),
        child: SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: context.colors.textSecondary,
          ),
        ),
      );
    } else if (state.usernameAvailable) {
      suffixIcon =
          const Icon(Icons.check_circle, color: Colors.greenAccent, size: 20);
      helperText = s.editProfileUsernameAvailable;
      helperColor = Colors.greenAccent;
    } else if (state.usernameError != null ||
        state.usernameErrorMessage != null) {
      suffixIcon = const Icon(Icons.cancel, color: Colors.redAccent, size: 20);
      helperText = state.usernameError != null
          ? _usernameErrorText(s, state.usernameError!)
          : state.usernameErrorMessage;
      helperColor = Colors.redAccent;
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: TextFormField(
        controller: controller,
        maxLength: 30,
        onChanged: onChanged,
        style: TextStyle(color: context.colors.textPrimary),
        validator: (v) {
          final val = (v ?? '').trim();
          if (val.isEmpty) return null;
          if (val.length < 3) return s.editProfileUsernameTooShort;
          final re = RegExp(r'^[a-zA-Z][a-zA-Z0-9_]*$');
          if (!re.hasMatch(val)) {
            return s.editProfileUsernameInvalid;
          }
          return null;
        },
        decoration: InputDecoration(
          labelText: s.editProfileUsernameLabel,
          hintText: s.editProfileUsernameHint,
          labelStyle:  TextStyle(color: context.colors.textSecondary),
          hintStyle: TextStyle(color: context.colors.border),
          prefixIcon:  Icon(
            Icons.alternate_email,
            color: context.colors.textSecondary,
            size: 20,
          ),
          suffixIcon: suffixIcon,
          helperText: helperText,
          helperStyle: TextStyle(color: helperColor),
          filled: true,
          fillColor: Colors.white10,
          counterStyle:  TextStyle(color: context.colors.textSecondary),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide:
                const BorderSide(color: AppColors.mutedRed, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide:
                const BorderSide(color: Colors.redAccent, width: 1.5),
          ),
        ),
      ),
    );
  }

  String _usernameErrorText(S s, EditProfileErrorCode code) {
    switch (code) {
      case EditProfileErrorCode.usernameTooShort:
        return s.editProfileUsernameTooShort;
      case EditProfileErrorCode.usernameCheckFailed:
        return s.editProfileErrorUsernameCheck;
      case EditProfileErrorCode.usernameInUse:
        return s.editProfileErrorUsernameInUse;
      case EditProfileErrorCode.usernameSaveFailed:
        return s.editProfileErrorUsernameSaveFailed;
      default:
        return s.editProfileErrorUsernameCheck;
    }
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
        style:  TextStyle(
          color: context.colors.textSecondary,
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
        style: TextStyle(color: context.colors.textPrimary),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          labelStyle:  TextStyle(color: context.colors.textSecondary),
          hintStyle: TextStyle(color: context.colors.border),
          prefixIcon: prefixIcon != null
              ? Icon(prefixIcon, color: context.colors.textSecondary, size: 20)
              : null,
          filled: true,
          fillColor: Colors.white10,
          counterStyle:  TextStyle(color: context.colors.textSecondary),
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
