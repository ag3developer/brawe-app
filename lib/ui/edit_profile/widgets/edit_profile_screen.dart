// ignore_for_file: unused_element_parameter
import 'dart:async';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/themes/app_colors.dart';
import '../../core/themes/brawe_colors.dart';
import '../../../domain/models/profile.dart';
import '../../../gen/l10n/app_localizations.dart';
import '../view_models/edit_profile_view_model.dart';
import 'image_position_editor.dart';

extension _ErrorCodeLabel on EditProfileErrorCode {
  String label(S s) {
    switch (this) {
      case EditProfileErrorCode.saveFailed:
        return s.editProfileLoadError;
      case EditProfileErrorCode.usernameTooShort:
        return s.editProfileUsernameTooShort;
      case EditProfileErrorCode.usernameCheckFailed:
      case EditProfileErrorCode.usernameSaveFailed:
        return s.editProfileSavedUsernameFailed;
      case EditProfileErrorCode.usernameInUse:
        return s.editProfileSavedUsernameFailed;
      default:
        return s.editProfileLoadError;
    }
  }
}

// Chave global para campos de músico (compatibilidade)
final musicianFieldsKey = GlobalKey<_MusicianFieldsState>();

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen>
    with SingleTickerProviderStateMixin {
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

    final ok = await ref
        .read(editProfileViewModelProvider.notifier)
        .save(
          displayName: _nameCtrl.text,
          bio: _bioCtrl.text,
          socialLinks: socialLinks,
          accountType: ref
              .read(editProfileViewModelProvider)
              .value
              ?.effectiveAccountType,
        );
    if (!mounted) return;

    if (ok) {
      final vmState = ref.read(editProfileViewModelProvider).value;
      final currentUsername = vmState?.profile?.username?.toLowerCase() ?? '';
      final newUsername = _usernameCtrl.text.trim().toLowerCase();
      if (newUsername.isNotEmpty && newUsername != currentUsername) {
        final usernameOk = await ref
            .read(editProfileViewModelProvider.notifier)
            .saveUsername(newUsername);
        if (!mounted) return;
        if (!usernameOk) {
          _showSnack(
            S.of(context).editProfileSavedUsernameFailed,
            isError: true,
          );
          return;
        }
      }

      if (ok) {
        final mf = musicianFieldsKey.currentState;
        if (mf != null) {
          await ref
              .read(editProfileViewModelProvider.notifier)
              .registerArtistIfNeeded(
                artistName: mf.artistName,
                city: mf.city.isEmpty ? null : mf.city,
                spotifyUrl: mf.spotifyUrl.isEmpty ? null : mf.spotifyUrl,
                appleMusicUrl: mf.appleMusicUrl.isEmpty
                    ? null
                    : mf.appleMusicUrl,
                genres: mf.selectedGenres.toList(),
              );
        }
      }

      _showSnack(S.of(context).editProfileSaved);
    }
  }

  void _showSnack(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? LucideIcons.alertCircle : LucideIcons.checkCircle,
              color: Colors.white,
              size: 16,
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(msg)),
          ],
        ),
        backgroundColor: isError ? Colors.red.shade700 : Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final async = ref.watch(editProfileViewModelProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: context.colors.background,
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(s, async, isDark),
      body: async.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.mutedRed),
        ),
        error: (e, _) => _ErrorView(message: s.editProfileLoadError),
        data: (state) {
          _hydrate(state);
          return _buildBody(state, s, isDark);
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(
    S s,
    AsyncValue<EditProfileState> async,
    bool isDark,
  ) {
    final isSaving = async.value?.isSaving == true;
    return AppBar(
      backgroundColor: context.colors.background.withValues(alpha: 0.85),
      foregroundColor: context.colors.textPrimary,
      elevation: 0,
      scrolledUnderElevation: 0,
      flexibleSpace: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: const SizedBox.expand(),
        ),
      ),
      leading: IconButton(
        icon: const Icon(LucideIcons.chevronLeft, size: 22),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Text(
        s.editProfileTitle,
        style: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w700,
          color: context.colors.textPrimary,
          letterSpacing: -0.3,
        ),
      ),
      centerTitle: true,
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: FilledButton(
            onPressed: isSaving ? null : _onSave,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.mutedRed,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              minimumSize: Size.zero,
            ),
            child: isSaving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    s.editProfileSave,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildBody(EditProfileState state, S s, bool isDark) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _HeroMediaEditor(state: state),
            const SizedBox(height: 20),
            if (state.error != null)
              _ErrorBanner(message: state.error!.label(s)),

            // Seção Informações
            _SectionCard(
              icon: LucideIcons.user,
              title: s.editProfileSectionInfo,
              children: [
                _FieldRow(
                  icon: LucideIcons.atSign,
                  label: s.editProfileUsernameLabel,
                  child: _UsernameField(
                    controller: _usernameCtrl,
                    state: state,
                    onChanged: (val) {
                      _usernameDebounce?.cancel();
                      _usernameDebounce = Timer(
                        const Duration(milliseconds: 600),
                        () {
                          if (val.length >= 3) {
                            ref
                                .read(editProfileViewModelProvider.notifier)
                                .checkUsername(val.trim());
                          }
                        },
                      );
                    },
                  ),
                ),
                _RowDivider(),
                _FieldRow(
                  icon: LucideIcons.type,
                  label: s.editProfileFieldName,
                  child: _CompactTextField(
                    controller: _nameCtrl,
                    hint: s.editProfileFieldName,
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? s.editProfileFieldNameRequired
                        : null,
                  ),
                ),
                _RowDivider(),
                _FieldRow(
                  icon: LucideIcons.alignLeft,
                  label: s.editProfileFieldBio,
                  child: _CompactTextField(
                    controller: _bioCtrl,
                    hint: s.editProfileFieldBioHint,
                    maxLines: 3,
                    maxLength: 160,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Seção Tipo de Conta
            _AccountTypeCard(accountType: state.effectiveAccountType),

            const SizedBox(height: 12),

            // Seção Links Sociais
            _SectionCard(
              icon: LucideIcons.link,
              title: s.editProfileSectionSocial,
              children: [
                _SocialRow(
                  icon: LucideIcons.globe,
                  color: const Color(0xFFE1306C),
                  label: 'Instagram',
                  controller: _instaCtrl,
                  hint: s.editProfileSocialUserHint,
                ),
                _RowDivider(),
                _SocialRow(
                  icon: LucideIcons.globe,
                  color: const Color(0xFF1DA1F2),
                  label: 'X / Twitter',
                  controller: _twitterCtrl,
                  hint: s.editProfileSocialUserHint,
                ),
                _RowDivider(),
                _SocialRow(
                  icon: LucideIcons.music2,
                  color: const Color(0xFF010101),
                  label: 'TikTok',
                  controller: _tiktokCtrl,
                  hint: s.editProfileSocialUserHint,
                ),
                _RowDivider(),
                _SocialRow(
                  icon: LucideIcons.globe,
                  color: const Color(0xFFFF0000),
                  label: 'YouTube',
                  controller: _ytCtrl,
                  hint: s.editProfileSocialChannelHint,
                ),
                _RowDivider(),
                _SocialRow(
                  icon: LucideIcons.globe,
                  color: AppColors.mutedRed,
                  label: 'Website',
                  controller: _siteCtrl,
                  hint: s.editProfileSocialUrlHint,
                ),
              ],
            ),

            const SizedBox(height: 24),
            SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════
// HERO: Banner + Avatar
// ══════════════════════════════════════════════════════════

class _HeroMediaEditor extends ConsumerWidget {
  final EditProfileState state;
  const _HeroMediaEditor({required this.state});

  Future<void> _pickBanner(BuildContext ctx, WidgetRef ref) async {
    final vm = ref.read(editProfileViewModelProvider.notifier);
    final picked = await vm.pickImageFromGallery(imageQuality: 90);
    if (picked == null || !ctx.mounted) return;
    final cropped = await Navigator.of(ctx).push<String>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => ImagePositionEditor(
          sourcePath: picked,
          aspectRatio: 16 / 5,
          circle: false,
          title: S.of(ctx).editProfileBannerPosition,
          outputWidth: 1500,
        ),
      ),
    );
    if (cropped == null) return;
    await vm.uploadBannerFromPath(cropped);
  }

  Future<void> _pickAvatar(BuildContext ctx, WidgetRef ref) async {
    final vm = ref.read(editProfileViewModelProvider.notifier);
    final picked = await vm.pickImageFromGallery(imageQuality: 95);
    if (picked == null || !ctx.mounted) return;
    final cropped = await Navigator.of(ctx).push<String>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => ImagePositionEditor(
          sourcePath: picked,
          aspectRatio: 1.0,
          circle: true,
          title: S.of(ctx).editProfileAvatarPosition,
          outputWidth: 1024,
        ),
      ),
    );
    if (cropped == null) return;
    await vm.uploadAvatarFromPath(cropped);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bannerUrl = state.profile?.bannerUrl;
    final avatarUrl = state.profile?.avatarUrl;
    final topPad = MediaQuery.of(context).padding.top + kToolbarHeight;

    return SizedBox(
      height: topPad + 130,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Banner
          GestureDetector(
            onTap: () => _pickBanner(context, ref),
            child: Container(
              height: topPad + 90,
              width: double.infinity,
              color: context.colors.divider,
              child: bannerUrl != null && bannerUrl.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: bannerUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                    )
                  : Center(
                      child: Padding(
                        padding: EdgeInsets.only(top: topPad),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              LucideIcons.image,
                              size: 26,
                              color: context.colors.textTertiary.withValues(
                                alpha: 0.4,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              S.of(context).editProfileBannerAdd,
                              style: TextStyle(
                                color: context.colors.textTertiary.withValues(
                                  alpha: 0.5,
                                ),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
            ),
          ),

          if (state.isUploadingBanner)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: topPad + 90,
              child: Container(
                color: Colors.black.withValues(alpha: 0.5),
                child: const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              ),
            ),

          // Botões de editar banner
          Positioned(
            right: 10,
            top: topPad + 54,
            child: Row(
              children: [
                if (bannerUrl != null && bannerUrl.isNotEmpty) ...[
                  _GlassCircleBtn(
                    icon: LucideIcons.trash2,
                    size: 30,
                    iconSize: 13,
                    onTap: () => ref
                        .read(editProfileViewModelProvider.notifier)
                        .removeBanner(),
                  ),
                  const SizedBox(width: 6),
                ],
                _GlassCircleBtn(
                  icon: LucideIcons.camera,
                  size: 30,
                  iconSize: 13,
                  onTap: () => _pickBanner(context, ref),
                ),
              ],
            ),
          ),

          // Avatar
          Positioned(
            left: 16,
            bottom: 0,
            child: GestureDetector(
              onTap: () => _pickAvatar(context, ref),
              child: Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: context.colors.background,
                    width: 3,
                  ),
                ),
                child: ClipOval(
                  child: state.isUploadingAvatar
                      ? Container(
                          color: Colors.black54,
                          child: const Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          ),
                        )
                      : (avatarUrl != null && avatarUrl.isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl: avatarUrl,
                                fit: BoxFit.cover,
                                width: 88,
                                height: 88,
                              )
                            : Container(
                                color: context.colors.divider,
                                child: Icon(
                                  LucideIcons.user,
                                  size: 40,
                                  color: context.colors.textTertiary,
                                ),
                              )),
                ),
              ),
            ),
          ),

          if (!state.isUploadingAvatar)
            Positioned(
              left: 78,
              bottom: 0,
              child: _GlassCircleBtn(
                icon: LucideIcons.camera,
                size: 28,
                iconSize: 12,
                onTap: () => _pickAvatar(context, ref),
              ),
            ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════
// ACCOUNT TYPE CARD
// ══════════════════════════════════════════════════════════
//
// UX Decision: o tipo de conta é uma IDENTIDADE, não uma configuração.
// Por isso fica no EditProfile (próximo ao nome/bio) como indicador de
// status, não em Settings (que é para preferências técnicas).
//
// Consumer → incentivo de upgrade com CTA
// Creator / Musician / Business → badge de conquista com descrição

class _AccountTypeCard extends StatelessWidget {
  final AccountType accountType;
  const _AccountTypeCard({required this.accountType});

  String? _routeFor(AccountType type) {
    switch (type) {
      case AccountType.musician:
        return '/artist-profile';
      case AccountType.business:
        return '/business-profile';
      case AccountType.creator:
        return '/creator/profile-settings';
      case AccountType.consumer:
        return '/creator/intro';
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final config = _accountConfig(accountType, s);
    final route = _routeFor(accountType);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label da seção
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Row(
              children: [
                Icon(LucideIcons.shieldCheck, size: 13, color: config.color),
                const SizedBox(width: 6),
                Text(
                  'CONTA'.toUpperCase(),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                    color: context.colors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          // Card
          GestureDetector(
            onTap: route != null ? () => context.push(route) : null,
            child: Container(
              decoration: BoxDecoration(
                color: config.color.withValues(alpha: isDark ? 0.12 : 0.07),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: config.color.withValues(alpha: isDark ? 0.3 : 0.2),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    // Ícone com fundo
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: config.color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(config.icon, size: 20, color: config.color),
                    ),
                    const SizedBox(width: 12),
                    // Textos
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                config.title,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: context.colors.textPrimary,
                                ),
                              ),
                              if (accountType != AccountType.consumer) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: config.color.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    'Ativo',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: config.color,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            config.subtitle,
                            style: TextStyle(
                              fontSize: 12,
                              color: context.colors.textSecondary,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Chevron para todos — consumer=upgrade, outros=editar perfil
                    Icon(
                      LucideIcons.chevronRight,
                      size: 18,
                      color: config.color,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  _AccountTypeConfig _accountConfig(AccountType type, S s) {
    switch (type) {
      case AccountType.creator:
        return _AccountTypeConfig(
          icon: LucideIcons.award,
          color: const Color(0xFF8B5CF6), // violeta
          title: s.creatorProgramTitle,
          subtitle: 'Lives, monetização e ferramentas de criador.',
        );
      case AccountType.musician:
        return _AccountTypeConfig(
          icon: LucideIcons.music,
          color: const Color(0xFFEC4899), // pink
          title: 'Artista · Brawe Sounds',
          subtitle: 'Perfil musical, distribuição e royalties.',
        );
      case AccountType.business:
        return _AccountTypeConfig(
          icon: LucideIcons.briefcase,
          color: const Color(0xFF3B82F6), // azul
          title: 'Business',
          subtitle: 'Ferramentas para marcas e empresas.',
        );
      case AccountType.consumer:
        return _AccountTypeConfig(
          icon: LucideIcons.user,
          color: const Color(0xFF6B7280), // cinza
          title: 'Conta básica',
          subtitle:
              'Faça upgrade para o Creator Network e comece a transmitir ao vivo.',
        );
    }
  }
}

class _AccountTypeConfig {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;

  const _AccountTypeConfig({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
  });
}

// ══════════════════════════════════════════════════════════
// SECTION CARD
// ══════════════════════════════════════════════════════════

class _SectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<Widget> children;

  const _SectionCard({
    required this.icon,
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Row(
              children: [
                Icon(icon, size: 13, color: AppColors.mutedRed),
                const SizedBox(width: 6),
                Text(
                  title.toUpperCase(),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                    color: context.colors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.black.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.07)
                    : Colors.black.withValues(alpha: 0.06),
              ),
            ),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }
}

class _FieldRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget child;

  const _FieldRow({
    required this.icon,
    required this.label,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Icon(icon, size: 16, color: context.colors.textTertiary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: context.colors.textTertiary,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 2),
                child,
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SocialRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final TextEditingController controller;
  final String hint;

  const _SocialRow({
    required this.icon,
    required this.color,
    required this.label,
    required this.controller,
    required this.hint,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 15, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _CompactTextField(
              controller: controller,
              hint: hint,
              prefixText: label == 'Website' ? null : '$label · ',
            ),
          ),
        ],
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
    return Row(
      children: [
        Expanded(
          child: _CompactTextField(
            controller: controller,
            hint: s.editProfileUsernameHint,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9._]')),
            ],
            validator: (v) {
              if (v == null || v.isEmpty) return null;
              if (v.length < 3) return s.editProfileUsernameTooShort;
              if (!RegExp(r'^[a-zA-Z0-9._]+$').hasMatch(v)) {
                return s.editProfileUsernameInvalid;
              }
              return null;
            },
            onChanged: onChanged,
          ),
        ),
        if (state.isCheckingUsername)
          const Padding(
            padding: EdgeInsets.only(left: 8),
            child: SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          )
        else if (state.usernameAvailable == true)
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Icon(
              LucideIcons.checkCircle,
              size: 16,
              color: Colors.green.shade500,
            ),
          )
        else if (state.usernameAvailable == false)
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Icon(
              LucideIcons.xCircle,
              size: 16,
              color: Colors.red.shade400,
            ),
          ),
      ],
    );
  }
}

class _CompactTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final int maxLines;
  final int? maxLength;
  final String? prefixText;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final List<TextInputFormatter>? inputFormatters;

  const _CompactTextField({
    required this.controller,
    required this.hint,
    this.maxLines = 1,
    this.maxLength,
    this.prefixText,
    this.validator,
    this.onChanged,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      maxLength: maxLength,
      onChanged: onChanged,
      validator: validator,
      inputFormatters: inputFormatters,
      style: TextStyle(
        fontSize: 15,
        color: context.colors.textPrimary,
        fontWeight: FontWeight.w400,
      ),
      decoration: InputDecoration(
        hintText: hint,
        prefixText: prefixText,
        prefixStyle: TextStyle(
          fontSize: 14,
          color: context.colors.textTertiary,
          fontWeight: FontWeight.w500,
        ),
        hintStyle: TextStyle(
          fontSize: 15,
          color: context.colors.textTertiary.withValues(alpha: 0.5),
        ),
        counterText: '',
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 4),
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        errorBorder: InputBorder.none,
        errorStyle: const TextStyle(fontSize: 11),
      ),
    );
  }
}

class _RowDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      indent: 42,
      color: context.colors.divider.withValues(alpha: 0.5),
    );
  }
}

class _GlassCircleBtn extends StatelessWidget {
  final IconData icon;
  final double size;
  final double iconSize;
  final VoidCallback onTap;

  const _GlassCircleBtn({
    required this.icon,
    required this.size,
    required this.iconSize,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipOval(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.45),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Icon(icon, size: iconSize, color: Colors.white),
          ),
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(LucideIcons.alertCircle, color: Colors.red, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: Colors.red, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  const _ErrorView({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              LucideIcons.wifiOff,
              size: 40,
              color: context.colors.textTertiary,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: context.colors.textSecondary,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Stub para compatibilidade com ViewModel de músico
class _MusicianFieldsState extends State<_MusicianFields> {
  String artistName = '';
  String city = '';
  String spotifyUrl = '';
  String appleMusicUrl = '';
  Set<String> selectedGenres = {};

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

class _MusicianFields extends StatefulWidget {
  const _MusicianFields({super.key});
  @override
  State<_MusicianFields> createState() => _MusicianFieldsState();
}
