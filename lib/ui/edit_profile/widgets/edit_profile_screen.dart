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
import '../../core/ui/grouped_list.dart';
import '../../account/account_type_screen.dart' show accountTypeInfo;
import '../../account/verify_account_screen.dart' show kycStateLabel;
import '../../../data/repositories/kyc_repository.dart';
import '../../account/about_you_screen.dart' show myAboutProvider;
import '../../../domain/models/profile.dart';
import '../../../gen/l10n/app_localizations.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/auth_state_provider.dart';
import '../../settings/view_models/settings_view_model.dart';
import '../view_models/edit_profile_view_model.dart';
import 'image_position_editor.dart';
import 'package:brawe_app/ui/core/ui/image_decode.dart';

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

  /// Visibilidade do selo de creator (só creators). null = ainda não mexeu.
  bool? _showBadge;

  @override
  void initState() {
    super.initState();
    // Preenche os campos assim que o perfil chega (e não só no primeiro
    // build): evita telas com campos vazios se o dado vier depois.
    ref.listenManual<AsyncValue<EditProfileState>>(
      editProfileViewModelProvider,
      (_, next) => next.whenData(_hydrate),
      fireImmediately: true,
    );
  }

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
    // Sem nome no perfil, usa o da conta logada.
    var name = (p.displayName ?? '').trim();
    if (name.isEmpty) {
      name = (ref.read(authStateProvider).value?.name ?? '').trim();
    }
    _nameCtrl.text = name;
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

      // Selo de creator (campo real: privacy_show_account_type).
      final settings = ref.read(settingsViewModelProvider).value;
      if (_showBadge != null &&
          settings != null &&
          _showBadge != settings.privacyShowAccountType) {
        try {
          await ref
              .read(settingsViewModelProvider.notifier)
              .setBool('privacy_show_account_type', _showBadge!);
        } catch (_) {
          if (!mounted) return;
          _showSnack(
            S.of(context).editProfileCreatorBadgeSaveFailed,
            isError: true,
          );
          return;
        }
        if (!mounted) return;
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

      if (!mounted) return;
      _showSnack(S.of(context).editProfileSaved);

      // ── Atualizar estado de autenticação e navegar para feed ─────────────────
      // Após salvar perfil com sucesso, obtém usuário atualizado do backend
      // e notifica o router para reconhecer que perfil agora está completo.
      try {
        final updatedUser = await ref
            .read(authRepositoryProvider)
            .getCurrentUser();

        // Atualizar o estado autenticado (padrão: LoginViewModel e SignupViewModel)
        ref.read(authStateProvider.notifier).updateSession(updatedUser);

        // Aguardar um micro-delay para garantir que router processa a mudança
        await Future.delayed(const Duration(milliseconds: 50));

        // Navegar para o feed (novo usuário completa onboarding → feed)
        if (mounted) {
          if (context.canPop()) {
            context.pop();
          } else {
            context.go('/home');
          }
        }
      } catch (e) {
        // Log silencioso: perfil principal já foi salvo
        // Se falhar aqui, na próxima tela o router ainda vai redirecionar correto
        // pois o backend tem avatarUrl preenchido e app recarrega sessão
        debugPrint('Aviso: Falha ao atualizar sessão: $e');
      }
    }
  }

  Widget _creatorBadgeSwitch(S s) {
    final settings = ref.watch(settingsViewModelProvider).value;
    final value = _showBadge ?? settings?.privacyShowAccountType ?? true;
    return GroupedRow(
      key: const ValueKey('creator_badge_switch'),
      icon: LucideIcons.sparkles,
      title: s.editProfileCreatorBadgeTitle,
      subtitle: s.editProfileCreatorBadgeHint,
      trailing: Switch.adaptive(
        value: value,
        activeTrackColor: context.colors.accentPrimary,
        onChanged: settings == null
            ? null
            : (v) => setState(() => _showBadge = v),
      ),
    );
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
        backgroundColor: isError
            ? context.colors.danger
            : context.colors.success,
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
          child: CircularProgressIndicator(color: AppColors.braweBlue),
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
              backgroundColor: AppColors.braweBlue,
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
    final type = state.profile?.accountType ?? AccountType.consumer;
    final (typeName, _, typeIcon) = accountTypeInfo(s, type);
    final kyc = ref.watch(kycStatusProvider).value;
    final (kycLabel, kycColor) = kycStateLabel(
      context,
      kyc?.identity ?? 'none',
    );
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _HeroMediaEditor(state: state),
            const SizedBox(height: 20),
            if (state.error != null)
              _ErrorBanner(message: state.error!.label(s)),
            Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 640),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // ── perfil ──────────────────────────────────
                      GroupedSection(
                        caption: s.editProfileSectionInfo,
                        indent: 16,
                        children: [
                          GroupedField(
                            label: s.editProfileFieldName,
                            child: _CompactTextField(
                              controller: _nameCtrl,
                              hint: s.editProfileFieldName,
                              validator: (v) => (v == null || v.trim().isEmpty)
                                  ? s.editProfileFieldNameRequired
                                  : null,
                            ),
                          ),
                          GroupedField(
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
                                          .read(
                                            editProfileViewModelProvider
                                                .notifier,
                                          )
                                          .checkUsername(val.trim());
                                    }
                                  },
                                );
                              },
                            ),
                          ),
                          GroupedField(
                            label: s.editProfileFieldBio,
                            child: _CompactTextField(
                              controller: _bioCtrl,
                              hint: s.editProfileFieldBioHint,
                              maxLines: 4,
                              maxLength: 160,
                            ),
                          ),
                        ],
                      ),

                      // ── sobre você (gênero, cidade) ─────────────
                      GroupedSection(
                        children: [
                          GroupedRow(
                            icon: LucideIcons.userRound,
                            title: s.editProfileAbout,
                            value: _aboutSummary(s),
                            onTap: () => context.push('/account/about'),
                          ),
                        ],
                      ),

                      // ── conta ───────────────────────────────────
                      GroupedSection(
                        caption: s.settingsAccount,
                        children: [
                          GroupedRow(
                            icon: typeIcon,
                            title: s.acctTitle,
                            value: typeName,
                            onTap: () => context.push('/account/type'),
                          ),
                          GroupedRow(
                            icon: LucideIcons.badgeCheck,
                            title: s.kycTitle,
                            value: kycLabel,
                            valueColor: kycColor,
                            onTap: () => context.push('/account/verify'),
                          ),
                          if (type == AccountType.creator)
                            GroupedRow(
                              icon: LucideIcons.layoutDashboard,
                              title: s.editProfileCreatorPanel,
                              onTap: () => context.push('/creator/dashboard'),
                            ),
                          if (type == AccountType.musician)
                            GroupedRow(
                              icon: LucideIcons.mic,
                              title: s.editProfileArtistPage,
                              onTap: () => context.push('/artist-profile'),
                            ),
                          if (type == AccountType.business)
                            GroupedRow(
                              icon: LucideIcons.building2,
                              title: s.editProfileBusinessPage,
                              onTap: () => context.push('/business-profile'),
                            ),
                          if (type == AccountType.creator)
                            _creatorBadgeSwitch(s),
                        ],
                      ),

                      // ── redes ───────────────────────────────────
                      GroupedSection(
                        caption: s.editProfileSectionSocial,
                        children: [
                          _SocialField(
                            icon: LucideIcons.camera,
                            label: 'Instagram',
                            controller: _instaCtrl,
                            hint: s.editProfileSocialUserHint,
                          ),
                          _SocialField(
                            icon: LucideIcons.atSign,
                            label: 'X',
                            controller: _twitterCtrl,
                            hint: s.editProfileSocialUserHint,
                          ),
                          _SocialField(
                            icon: LucideIcons.music2,
                            label: 'TikTok',
                            controller: _tiktokCtrl,
                            hint: s.editProfileSocialUserHint,
                          ),
                          _SocialField(
                            icon: LucideIcons.circlePlay,
                            label: 'YouTube',
                            controller: _ytCtrl,
                            hint: s.editProfileSocialChannelHint,
                          ),
                          _SocialField(
                            icon: LucideIcons.globe,
                            label: s.editProfileWebsite,
                            controller: _siteCtrl,
                            hint: s.editProfileSocialUrlHint,
                            url: true,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
          ],
        ),
      ),
    );
  }
}

extension on _EditProfileScreenState {
  /// "Feminino · Curitiba" (vazio enquanto carrega).
  String _aboutSummary(S s) {
    final me = ref.watch(myAboutProvider).value;
    if (me == null) return '';
    final g = switch (me['gender']) {
      'female' => s.onbGenderFemale,
      'male' => s.onbGenderMale,
      'other' => s.onbGenderOther,
      'undisclosed' => s.onbGenderUndisclosed,
      _ => '',
    };
    return [g, '${me['city'] ?? ''}'].where((e) => e.isNotEmpty).join(' · ');
  }
}

/// Rede social: ícone discreto, nome à esquerda e o @ / link à direita (como digitado, sem maiúscula).
class _SocialField extends StatelessWidget {
  const _SocialField({
    required this.icon,
    required this.label,
    required this.controller,
    required this.hint,
    this.url = false,
  });
  final IconData icon;
  final String label;
  final TextEditingController controller;
  final String hint;
  final bool url;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: colors.textSecondary),
          const SizedBox(width: 16),
          SizedBox(
            width: 88,
            child: Text(
              label,
              style: TextStyle(
                color: colors.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: url ? TextInputType.url : TextInputType.text,
              textCapitalization: TextCapitalization.none,
              autocorrect: false,
              style: TextStyle(color: colors.textPrimary, fontSize: 15),
              decoration: groupedInput(context, hint: hint).copyWith(
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ],
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
                      memCacheWidth: context.decodeScreenPx,
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
                                memCacheWidth: context.decodePx(88),
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
              color: context.colors.success,
            ),
          )
        else if (state.usernameAvailable == false)
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Icon(
              LucideIcons.xCircle,
              size: 16,
              color: context.colors.danger,
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
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final List<TextInputFormatter>? inputFormatters;

  const _CompactTextField({
    required this.controller,
    required this.hint,
    this.maxLines = 1,
    this.maxLength,
    this.validator,
    this.onChanged,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      // maiúscula automática só em texto livre (nome, bio); @usuário e links ficam como digitados
      textCapitalization: inputFormatters == null
          ? TextCapitalization.sentences
          : TextCapitalization.none,
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
  const _MusicianFields();
  @override
  State<_MusicianFields> createState() => _MusicianFieldsState();
}
