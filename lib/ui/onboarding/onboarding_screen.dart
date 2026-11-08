import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../data/repositories/ads_repository.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/auth_state_provider.dart';
import '../../data/repositories/social_repository.dart';
import '../../data/services/profile_service.dart';
import '../../data/services/social_service.dart';
import '../../domain/models/creator_network.dart'
    show ContentNiche, ContentNicheX;
import '../../domain/models/ad_models.dart';
import '../../domain/models/user.dart';
import '../creator/utils/creator_l10n.dart';
import '../../gen/l10n/app_localizations.dart';
import '../core/themes/brawe_colors.dart';
import '../core/widgets/country_picker.dart';
import '../core/ui/verified_badge.dart';
import '../edit_profile/widgets/image_position_editor.dart';
import 'onboarding_gate.dart';

/// Cadastro em passos (estilo TikTok/Instagram), mostrado depois de criar a
/// conta — e, uma única vez, para contas antigas que ainda não têm data de
/// nascimento, @ ou foto. Só aparecem os passos que faltam:
///
///   1. Data de nascimento (18+)   — obrigatório
///   2. @ (nome de usuário)        — obrigatório
///   3. Foto de perfil             — obrigatório
///   4. Bio                        — opcional (só conta nova)
///   5. Seguir pessoas             — opcional (conta nova ou seguindo < 3)
///
/// No fim vai para o Feed, que já tem conteúdo de quem a pessoa seguiu.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

enum _Step { birth, about, username, photo, bio, interests, follow }

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  List<_Step>? _steps;
  int _index = 0;
  bool _underage = false;

  @override
  void initState() {
    super.initState();
    _loadSteps();
  }

  Future<void> _loadSteps() async {
    OnboardingNeeds? needs = OnboardingGate.instance.value;
    try {
      final p = await ref.read(profileServiceProvider).getMyProfile();
      needs = OnboardingNeeds.fromProfile(p);
    } catch (_) {}
    if (!mounted) return;
    final user = ref.read(authStateProvider).value;
    final noAvatar = (user?.avatarUrl ?? '').trim().isEmpty;
    final n = needs;
    final isNew = noAvatar || (n?.isNewAccount ?? false);
    setState(() {
      _steps = [
        if (n == null || n.birthDate) _Step.birth,
        if (n == null || n.gender || n.location) _Step.about,
        if (n == null || n.username) _Step.username,
        if (noAvatar || (n?.avatar ?? false)) _Step.photo,
        if (isNew && (n?.bio ?? true)) _Step.bio,
        if (n?.interests ?? true) _Step.interests,
        if (isNew || (n?.followingCount ?? 0) < 3) _Step.follow,
      ];
      if (_steps!.isEmpty) _steps = [_Step.follow];
    });
  }

  void _next() {
    HapticFeedback.selectionClick();
    final steps = _steps!;
    if (_index < steps.length - 1) {
      setState(() => _index++);
    } else {
      _finish();
    }
  }

  void _finish() {
    OnboardingGate.instance.markDone();
    context.go('/feed');
  }

  Future<void> _signOut() async {
    OnboardingGate.instance.reset();
    await ref.read(authStateProvider.notifier).logout();
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final colors = context.colors;
    final steps = _steps;

    Widget body;
    if (_underage) {
      body = _UnderageView(onSignOut: _signOut);
    } else if (steps == null) {
      body = const Center(child: CircularProgressIndicator());
    } else {
      final step = steps[_index];
      body = AnimatedSwitcher(
        duration: const Duration(milliseconds: 280),
        transitionBuilder: (child, a) => FadeTransition(
          opacity: a,
          child: SlideTransition(
            position: Tween(
              begin: const Offset(0.08, 0),
              end: Offset.zero,
            ).animate(a),
            child: child,
          ),
        ),
        child: KeyedSubtree(
          key: ValueKey(step),
          child: switch (step) {
            _Step.birth => _BirthStep(
              onDone: _next,
              onUnderage: () => setState(() => _underage = true),
            ),
            _Step.about => AboutYouStep(onDone: _next),
            _Step.username => _UsernameStep(onDone: _next),
            _Step.photo => _PhotoStep(onDone: _next),
            _Step.bio => _BioStep(onDone: _next),
            _Step.interests => _InterestsStep(onDone: _next),
            _Step.follow => _FollowStep(onDone: _finish),
          },
        ),
      );
    }

    final total = steps?.length ?? 1;
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: colors.background,
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 8, 0),
                child: Row(
                  children: [
                    if (steps != null && !_underage) ...[
                      Expanded(
                        child: Row(
                          children: [
                            for (var i = 0; i < total; i++) ...[
                              if (i > 0) const SizedBox(width: 6),
                              Expanded(
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 250),
                                  height: 4,
                                  decoration: BoxDecoration(
                                    color: i <= _index
                                        ? colors.accentPrimary
                                        : colors.surfaceHighest,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        s.onbStepOf(_index + 1, total),
                        style: TextStyle(
                          color: colors.textTertiary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ] else
                      const Spacer(),
                    IconButton(
                      tooltip: s.onbSignOut,
                      icon: Icon(
                        LucideIcons.logOut,
                        size: 18,
                        color: colors.textTertiary,
                      ),
                      onPressed: _signOut,
                    ),
                  ],
                ),
              ),
              Expanded(child: body),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Peças comuns

class _StepScaffold extends StatelessWidget {
  const _StepScaffold({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.child,
    required this.primaryLabel,
    required this.onPrimary,
    this.busy = false,
    this.onSkip,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget child;
  final String primaryLabel;
  final VoidCallback? onPrimary;
  final bool busy;
  final VoidCallback? onSkip;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            width: 52,
            height: 52,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: colors.accentPrimary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: colors.accentPrimary, size: 26),
          ),
          const SizedBox(height: 18),
          Text(
            title,
            style: TextStyle(
              color: colors.textPrimary,
              fontSize: 26,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: TextStyle(
              color: colors.textSecondary,
              fontSize: 14.5,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 24),
          Expanded(child: child),
          FilledButton(
            onPressed: busy ? null : onPrimary,
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: busy
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    primaryLabel,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
          ),
          if (onSkip != null)
            TextButton(onPressed: busy ? null : onSkip, child: Text(s.onbSkip))
          else
            const SizedBox(height: 48),
        ],
      ),
    );
  }
}

void _toast(BuildContext context, String msg) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(msg)));
}

// ─────────────────────────────────────────────────────────────────────────────
// 1. Data de nascimento

class _BirthStep extends ConsumerStatefulWidget {
  const _BirthStep({required this.onDone, required this.onUnderage});
  final VoidCallback onDone;
  final VoidCallback onUnderage;

  @override
  ConsumerState<_BirthStep> createState() => _BirthStepState();
}

class _BirthStepState extends ConsumerState<_BirthStep> {
  static const _minAge = 18;
  DateTime _date = DateTime(DateTime.now().year - 20, 1, 1);
  bool _busy = false;

  int get _age {
    final now = DateTime.now();
    var a = now.year - _date.year;
    if (now.month < _date.month ||
        (now.month == _date.month && now.day < _date.day)) {
      a--;
    }
    return a;
  }

  Future<void> _save() async {
    if (_age < _minAge) {
      widget.onUnderage();
      return;
    }
    setState(() => _busy = true);
    try {
      await ref.read(profileServiceProvider).updateBirthDate(_date);
      if (mounted) widget.onDone();
    } on DioException catch (e) {
      if (!mounted) return;
      if ('${e.response?.data}'.contains('underage')) {
        widget.onUnderage();
      } else {
        _toast(context, S.of(context).onbError);
      }
    } catch (_) {
      if (mounted) _toast(context, S.of(context).onbError);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final colors = context.colors;
    final now = DateTime.now();
    return _StepScaffold(
      icon: LucideIcons.cake,
      title: s.onbBirthTitle,
      subtitle: s.onbBirthSubtitle,
      primaryLabel: s.onbContinue,
      busy: _busy,
      onPrimary: _save,
      child: Align(
        alignment: Alignment.topCenter,
        child: Container(
          height: 216,
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(18),
          ),
          child: CupertinoTheme(
            data: CupertinoThemeData(
              textTheme: CupertinoTextThemeData(
                dateTimePickerTextStyle: TextStyle(
                  color: colors.textPrimary,
                  fontSize: 21,
                ),
              ),
            ),
            child: CupertinoDatePicker(
              mode: CupertinoDatePickerMode.date,
              initialDateTime: _date,
              minimumDate: DateTime(1900),
              maximumDate: now,
              dateOrder: DatePickerDateOrder.dmy,
              onDateTimeChanged: (d) => _date = d,
            ),
          ),
        ),
      ),
    );
  }
}

class _UnderageView extends StatelessWidget {
  const _UnderageView({required this.onSignOut});
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(LucideIcons.shieldAlert, size: 56, color: colors.textTertiary),
          const SizedBox(height: 18),
          Text(
            s.onbUnderageTitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: colors.textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            s.onbUnderageBody,
            textAlign: TextAlign.center,
            style: TextStyle(color: colors.textSecondary, height: 1.4),
          ),
          const SizedBox(height: 28),
          FilledButton(onPressed: onSignOut, child: Text(s.onbSignOut)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 2. @

class _UsernameStep extends ConsumerStatefulWidget {
  const _UsernameStep({required this.onDone});
  final VoidCallback onDone;

  @override
  ConsumerState<_UsernameStep> createState() => _UsernameStepState();
}

class _UsernameStepState extends ConsumerState<_UsernameStep> {
  final _ctrl = TextEditingController();
  Timer? _debounce;
  bool _checking = false;
  String? _problem; // null = ok (quando já verificado)
  bool _checked = false;
  bool _busy = false;

  static final _valid = RegExp(r'^[a-z0-9._]{3,30}$');

  @override
  void initState() {
    super.initState();
    // Sugestão a partir do nome da conta.
    final User? user = ref.read(authStateProvider).value;
    final base = _slug(user?.name ?? '');
    if (base.length >= 3) {
      _ctrl.text = base;
      _check(base);
    }
  }

  static String _slug(String name) {
    const from = 'áàâãäéèêëíìîïóòôõöúùûüçñ';
    const to = 'aaaaaeeeeiiiiooooouuuucn';
    var s = name.toLowerCase();
    for (var i = 0; i < from.length; i++) {
      s = s.replaceAll(from[i], to[i]);
    }
    s = s.replaceAll(RegExp(r'[^a-z0-9]+'), '.');
    s = s.replaceAll(RegExp(r'^\.+|\.+$'), '');
    return s.length > 30 ? s.substring(0, 30) : s;
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _ctrl.dispose();
    super.dispose();
  }

  void _onChanged(String v) {
    final clean = v.toLowerCase().replaceAll('@', '').trim();
    if (clean != v) {
      _ctrl.value = TextEditingValue(
        text: clean,
        selection: TextSelection.collapsed(offset: clean.length),
      );
    }
    setState(() {
      _checked = false;
      _problem = null;
    });
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 450), () => _check(clean));
  }

  Future<void> _check(String u) async {
    if (!_valid.hasMatch(u)) {
      setState(() {
        _checked = true;
        _problem = S.of(context).onbUsernameRules;
      });
      return;
    }
    setState(() => _checking = true);
    final reason = await ref
        .read(profileServiceProvider)
        .checkUsernameAvailability(u);
    if (!mounted || _ctrl.text != u) return;
    setState(() {
      _checking = false;
      _checked = true;
      _problem = reason;
    });
  }

  Future<void> _save() async {
    setState(() => _busy = true);
    try {
      await ref.read(profileServiceProvider).updateUsername(_ctrl.text);
      if (mounted) widget.onDone();
    } on DioException catch (e) {
      if (!mounted) return;
      final d = e.response?.data;
      setState(
        () => _problem =
            (d is Map ? d['detail']?.toString() : null) ??
            S.of(context).onbError,
      );
    } catch (_) {
      if (mounted) _toast(context, S.of(context).onbError);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final colors = context.colors;
    final ok = _checked && _problem == null && !_checking;

    Widget? suffix;
    if (_checking) {
      suffix = const Padding(
        padding: EdgeInsets.all(14),
        child: SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    } else if (ok) {
      suffix = const Icon(LucideIcons.checkCircle2, color: Color(0xFF10B981));
    } else if (_checked && _problem != null) {
      suffix = const Icon(LucideIcons.xCircle, color: Color(0xFFEF4444));
    }

    return _StepScaffold(
      icon: LucideIcons.atSign,
      title: s.onbUsernameTitle,
      subtitle: s.onbUsernameSubtitle,
      primaryLabel: s.onbContinue,
      busy: _busy,
      onPrimary: ok ? _save : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _ctrl,
            autofocus: true,
            autocorrect: false,
            enableSuggestions: false,
            textInputAction: TextInputAction.done,
            maxLength: 30,
            onChanged: _onChanged,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9._@]')),
            ],
            style: TextStyle(
              color: colors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
            decoration: InputDecoration(
              prefixText: '@',
              prefixStyle: TextStyle(
                color: colors.textSecondary,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
              counterText: '',
              suffixIcon: suffix,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _checking
                ? s.onbUsernameChecking
                : (ok
                      ? s.onbUsernameAvailable
                      : (_problem ?? s.onbUsernameRules)),
            style: TextStyle(
              color: ok
                  ? const Color(0xFF10B981)
                  : (_checked && _problem != null
                        ? const Color(0xFFEF4444)
                        : colors.textTertiary),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 3. Foto

class _PhotoStep extends ConsumerStatefulWidget {
  const _PhotoStep({required this.onDone});
  final VoidCallback onDone;

  @override
  ConsumerState<_PhotoStep> createState() => _PhotoStepState();
}

class _PhotoStepState extends ConsumerState<_PhotoStep> {
  String? _url;
  bool _busy = false;

  Future<void> _pick(ImageSource source) async {
    final picked = await ImagePicker().pickImage(
      source: source,
      imageQuality: 95,
      preferredCameraDevice: CameraDevice.front,
    );
    if (picked == null || !mounted) return;
    final s = S.of(context);
    final cropped = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => ImagePositionEditor(
          sourcePath: picked.path,
          aspectRatio: 1.0,
          circle: true,
          title: s.onbPhotoPosition,
          outputWidth: 1024,
        ),
      ),
    );
    if (cropped == null || !mounted) return;
    setState(() => _busy = true);
    try {
      final url = await ref.read(profileServiceProvider).uploadAvatar(cropped);
      // O servidor também grava a foto na conta principal: recarrega a
      // sessão para a trava do router enxergar a foto na hora.
      try {
        final user = await ref.read(authRepositoryProvider).getCurrentUser();
        ref.read(authStateProvider.notifier).updateSession(user);
      } catch (_) {}
      if (mounted) setState(() => _url = url);
    } catch (_) {
      if (mounted) _toast(context, s.onbPhotoError);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final colors = context.colors;
    final has = _url != null && _url!.isNotEmpty;
    return _StepScaffold(
      icon: LucideIcons.camera,
      title: s.onbPhotoTitle,
      subtitle: s.onbPhotoSubtitle,
      primaryLabel: s.onbContinue,
      busy: _busy,
      onPrimary: has ? widget.onDone : null,
      child: Column(
        children: [
          GestureDetector(
            onTap: _busy ? null : () => _pick(ImageSource.gallery),
            child: Container(
              width: 156,
              height: 156,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colors.surfaceHighest,
                border: Border.all(
                  color: has ? colors.accentPrimary : colors.border,
                  width: 3,
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: _busy
                  ? const Center(child: CircularProgressIndicator())
                  : has
                  ? CachedNetworkImage(imageUrl: _url!, fit: BoxFit.cover)
                  : Icon(
                      LucideIcons.userRound,
                      size: 64,
                      color: colors.textTertiary,
                    ),
            ),
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _busy ? null : () => _pick(ImageSource.gallery),
                  icon: const Icon(LucideIcons.image, size: 18),
                  label: Text(has ? s.onbPhotoChange : s.onbPhotoGallery),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _busy ? null : () => _pick(ImageSource.camera),
                  icon: const Icon(LucideIcons.camera, size: 18),
                  label: Text(s.onbPhotoCamera),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 4. Bio (opcional)

class _BioStep extends ConsumerStatefulWidget {
  const _BioStep({required this.onDone});
  final VoidCallback onDone;

  @override
  ConsumerState<_BioStep> createState() => _BioStepState();
}

class _BioStepState extends ConsumerState<_BioStep> {
  final _ctrl = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final bio = _ctrl.text.trim();
    if (bio.isEmpty) {
      widget.onDone();
      return;
    }
    setState(() => _busy = true);
    try {
      await ref.read(profileServiceProvider).updateBio(bio);
    } catch (_) {
      // Bio é opcional: não prende a pessoa aqui.
    }
    if (mounted) {
      setState(() => _busy = false);
      widget.onDone();
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return _StepScaffold(
      icon: LucideIcons.penLine,
      title: s.onbBioTitle,
      subtitle: s.onbBioSubtitle,
      primaryLabel: s.onbContinue,
      busy: _busy,
      onPrimary: _save,
      onSkip: widget.onDone,
      child: TextField(
        textCapitalization: TextCapitalization.sentences,
        controller: _ctrl,
        maxLength: 150,
        maxLines: 3,
        minLines: 2,
        decoration: InputDecoration(hintText: s.onbBioHint),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 5. Interesses (opcional) — visual clássico: pílulas simples

class _InterestsStep extends ConsumerStatefulWidget {
  const _InterestsStep({required this.onDone});
  final VoidCallback onDone;

  @override
  ConsumerState<_InterestsStep> createState() => _InterestsStepState();
}

class _InterestsStepState extends ConsumerState<_InterestsStep> {
  /// Ícone Lucide de cada tema (visual clássico, sem emoji).
  static const _icons = <ContentNiche, IconData>{
    ContentNiche.lifestyle: LucideIcons.coffee,
    ContentNiche.games: LucideIcons.gamepad2,
    ContentNiche.music: LucideIcons.music,
    ContentNiche.fashion: LucideIcons.shirt,
    ContentNiche.beauty: LucideIcons.brush,
    ContentNiche.fitness: LucideIcons.dumbbell,
    ContentNiche.comedy: LucideIcons.laugh,
    ContentNiche.business: LucideIcons.briefcase,
    ContentNiche.tech: LucideIcons.laptop,
    ContentNiche.education: LucideIcons.graduationCap,
    ContentNiche.travel: LucideIcons.plane,
    ContentNiche.entertainment: LucideIcons.clapperboard,
    ContentNiche.sports: LucideIcons.volleyball,
    ContentNiche.cooking: LucideIcons.chefHat,
  };

  final Set<ContentNiche> _picked = {};
  bool _busy = false;

  static const _min = 3;

  Future<void> _save() async {
    if (_picked.length < _min) return;
    setState(() => _busy = true);
    try {
      await ref
          .read(profileServiceProvider)
          .updateInterests(_picked.map((e) => e.apiValue).toList());
      if (mounted) widget.onDone();
    } catch (_) {
      if (mounted) _toast(context, S.of(context).onbError);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final colors = context.colors;
    return _StepScaffold(
      icon: LucideIcons.heart,
      title: s.onbInterestsTitle,
      subtitle: s.onbInterestsSubtitle,
      primaryLabel: _picked.length < _min
          ? s.onbInterestsPickMin('$_min')
          : '${s.onbContinue} · ${s.onbInterestsCount(_picked.length)}',
      busy: _busy,
      onPrimary: _picked.length < _min ? null : _save,
      child: SingleChildScrollView(
        child: Wrap(
          spacing: 8,
          runSpacing: 10,
          children: [
            for (final n in _icons.keys)
              _InterestPill(
                icon: _icons[n]!,
                label: n.label(s),
                selected: _picked.contains(n),
                colors: colors,
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(
                    () => _picked.contains(n)
                        ? _picked.remove(n)
                        : _picked.add(n),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _InterestPill extends StatelessWidget {
  const _InterestPill({
    required this.icon,
    required this.label,
    required this.selected,
    required this.colors,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final BraweColors colors;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
        decoration: BoxDecoration(
          color: selected ? colors.textPrimary : colors.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: selected ? colors.textPrimary : colors.border,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 17,
              color: selected ? colors.background : colors.textSecondary,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: selected ? colors.background : colors.textPrimary,
                fontSize: 14.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 6. Seguir pessoas (opcional)

class _FollowStep extends ConsumerStatefulWidget {
  const _FollowStep({required this.onDone});
  final VoidCallback onDone;

  @override
  ConsumerState<_FollowStep> createState() => _FollowStepState();
}

class _FollowStepState extends ConsumerState<_FollowStep> {
  List<Map<String, dynamic>>? _users;
  final Set<String> _followed = {};
  final Set<String> _busy = {};

  @override
  void initState() {
    super.initState();
    ref
        .read(socialServiceProvider)
        .getSuggestions(limit: 20)
        .then((u) => mounted ? setState(() => _users = u) : null)
        .catchError((_) => mounted ? setState(() => _users = []) : null);
  }

  String _id(Map<String, dynamic> u) =>
      (u['user_id'] ?? u['id'] ?? u['uid'] ?? '').toString();

  Future<void> _follow(String id) async {
    if (id.isEmpty || _followed.contains(id) || _busy.contains(id)) return;
    HapticFeedback.selectionClick();
    setState(() => _busy.add(id));
    try {
      await ref.read(socialRepositoryProvider).followUser(id);
      if (mounted) setState(() => _followed.add(id));
    } catch (_) {
    } finally {
      if (mounted) setState(() => _busy.remove(id));
    }
  }

  Future<void> _followAll() async {
    for (final u in _users ?? const <Map<String, dynamic>>[]) {
      await _follow(_id(u));
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final colors = context.colors;
    final users = _users;

    Widget list;
    if (users == null) {
      list = const Center(child: CircularProgressIndicator());
    } else if (users.isEmpty) {
      list = Center(
        child: Text(
          s.onbFollowEmpty,
          textAlign: TextAlign.center,
          style: TextStyle(color: colors.textSecondary),
        ),
      );
    } else {
      list = Column(
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: _followed.length == users.length ? null : _followAll,
              icon: const Icon(LucideIcons.userPlus, size: 16),
              label: Text(s.onbFollowAll),
            ),
          ),
          Expanded(
            child: ListView.separated(
              itemCount: users.length,
              separatorBuilder: (_, _) => const SizedBox(height: 4),
              itemBuilder: (_, i) {
                final u = users[i];
                final id = _id(u);
                final name = (u['display_name'] ?? u['name'] ?? '').toString();
                final avatar = u['avatar_url']?.toString();
                final followers =
                    (u['follower_count'] ?? u['followers_count'] ?? 0)
                        .toString();
                final followed = _followed.contains(id);
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    radius: 22,
                    backgroundColor: colors.surfaceHighest,
                    backgroundImage: (avatar != null && avatar.isNotEmpty)
                        ? CachedNetworkImageProvider(avatar)
                        : null,
                    child: (avatar == null || avatar.isEmpty)
                        ? Text(name.isEmpty ? '?' : name[0].toUpperCase())
                        : null,
                  ),
                  title: Row(
                    children: [
                      Flexible(
                        child: Text(
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: colors.textPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      if (u['is_verified'] == true)
                        const VerifiedBadge(size: 14),
                    ],
                  ),
                  subtitle: Text(
                    s.onbFollowers(followers),
                    style: TextStyle(color: colors.textTertiary, fontSize: 12),
                  ),
                  trailing: _busy.contains(id)
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : followed
                      ? OutlinedButton(
                          onPressed: null,
                          style: OutlinedButton.styleFrom(
                            shape: const StadiumBorder(),
                          ),
                          child: Text(s.onbFollowing),
                        )
                      : FilledButton(
                          onPressed: () => _follow(id),
                          style: FilledButton.styleFrom(
                            shape: const StadiumBorder(),
                          ),
                          child: Text(s.onbFollow),
                        ),
                );
              },
            ),
          ),
        ],
      );
    }

    return _StepScaffold(
      icon: LucideIcons.users,
      title: s.onbFollowTitle,
      subtitle: s.onbFollowSubtitle,
      primaryLabel: s.onbFinish,
      onPrimary: widget.onDone,
      onSkip: _followed.isEmpty ? widget.onDone : null,
      child: list,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sobre você: gênero, país e cidade (ajudam a mostrar conteúdo e anúncios da sua região)

class AboutYouStep extends ConsumerStatefulWidget {
  const AboutYouStep({
    super.key,
    required this.onDone,
    this.initialGender,
    this.initialCountry,
  });
  final VoidCallback onDone;
  final String? initialGender;
  final String? initialCountry;

  @override
  ConsumerState<AboutYouStep> createState() => _AboutStepState();
}

class _AboutStepState extends ConsumerState<AboutYouStep> {
  late String? _gender = widget.initialGender;
  late String _country = (widget.initialCountry ?? '').isNotEmpty
      ? widget.initialCountry!.toUpperCase()
      : _guessCountry();
  AdCity? _city; // Brasil (IBGE)
  final _cityText = TextEditingController(); // outros países
  final _q = TextEditingController();
  List<AdCity> _results = [];
  Timer? _debounce;
  bool _busy = false;

  String _guessCountry() {
    final c = WidgetsBinding.instance.platformDispatcher.locale.countryCode
        ?.toUpperCase();
    return (c != null && findCountryByCode(c) != null) ? c : 'BR';
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _cityText.dispose();
    _q.dispose();
    super.dispose();
  }

  bool get _isBr => _country == 'BR';
  bool get _valid =>
      _gender != null &&
      (_isBr ? _city != null : _cityText.text.trim().length >= 2);

  void _search(String v) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 250), () async {
      if (v.trim().length < 2) {
        if (mounted) setState(() => _results = []);
        return;
      }
      try {
        final r = await ref.read(adsRepositoryProvider).searchCities(v);
        if (mounted && _q.text == v) setState(() => _results = r);
      } catch (_) {}
    });
  }

  Future<void> _pickCountry() async {
    final s = S.of(context);
    final c = await showCountryPicker(
      context,
      selectedCode: _country,
      title: s.kycCountryChoose,
      searchHint: s.kycCountrySearch,
    );
    if (c == null) return;
    setState(() {
      _country = c.code;
      _city = null;
      _results = [];
      _q.clear();
    });
  }

  Future<void> _save() async {
    setState(() => _busy = true);
    try {
      await ref
          .read(profileServiceProvider)
          .updateAbout(
            gender: _gender!,
            country: _country,
            cityId: _isBr ? _city!.id : null,
            city: _isBr ? null : _cityText.text.trim(),
          );
      if (mounted) widget.onDone();
    } catch (_) {
      if (mounted) _toast(context, S.of(context).onbError);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final colors = context.colors;
    final country = findCountryByCode(_country);
    final genders = {
      'female': s.onbGenderFemale,
      'male': s.onbGenderMale,
      'other': s.onbGenderOther,
      'undisclosed': s.onbGenderUndisclosed,
    };
    return _StepScaffold(
      icon: LucideIcons.userRound,
      title: s.onbAboutTitle,
      subtitle: s.onbAboutSubtitle,
      primaryLabel: s.onbContinue,
      busy: _busy,
      onPrimary: _valid ? _save : null,
      child: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              s.onbGender,
              style: TextStyle(
                color: colors.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final e in genders.entries)
                  ChoiceChip(
                    label: Text(e.value),
                    selected: _gender == e.key,
                    showCheckmark: false,
                    shape: const StadiumBorder(),
                    onSelected: (_) {
                      HapticFeedback.selectionClick();
                      setState(() => _gender = e.key);
                    },
                  ),
              ],
            ),
            const SizedBox(height: 22),
            Text(
              s.onbWhereYouLive,
              style: TextStyle(
                color: colors.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Material(
              color: colors.surface,
              borderRadius: BorderRadius.circular(14),
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: _pickCountry,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 14,
                  ),
                  child: Row(
                    children: [
                      Text(
                        country?.flag ?? '🌎',
                        style: const TextStyle(fontSize: 20),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          country?.name ?? _country,
                          style: TextStyle(
                            color: colors.textPrimary,
                            fontSize: 15.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Icon(
                        LucideIcons.chevronDown,
                        size: 18,
                        color: colors.textTertiary,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            if (_isBr && _city != null)
              Material(
                color: colors.surface,
                borderRadius: BorderRadius.circular(14),
                child: ListTile(
                  leading: Icon(
                    LucideIcons.mapPin,
                    color: colors.accentPrimary,
                  ),
                  title: Text(
                    _city!.label,
                    style: TextStyle(
                      color: colors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  trailing: TextButton(
                    onPressed: () => setState(() => _city = null),
                    child: Text(s.kycChangeFile),
                  ),
                ),
              )
            else
              TextField(
                controller: _isBr ? _q : _cityText,
                textCapitalization: TextCapitalization.words,
                onChanged: _isBr ? _search : (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: s.onbCityHint,
                  prefixIcon: Icon(
                    _isBr ? LucideIcons.search : LucideIcons.mapPin,
                    size: 18,
                  ),
                  filled: true,
                  fillColor: colors.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            if (_isBr && _city == null && _results.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(top: 6),
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  children: [
                    for (final c in _results.take(6))
                      ListTile(
                        dense: true,
                        leading: Icon(
                          LucideIcons.mapPin,
                          size: 18,
                          color: colors.textSecondary,
                        ),
                        title: Text(c.label),
                        onTap: () {
                          FocusScope.of(context).unfocus();
                          setState(() {
                            _city = c;
                            _results = [];
                            _q.clear();
                          });
                        },
                      ),
                  ],
                ),
              ),
            const SizedBox(height: 14),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(LucideIcons.lock, size: 14, color: colors.textTertiary),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    s.onbAboutPrivacy,
                    style: TextStyle(
                      color: colors.textTertiary,
                      fontSize: 12.5,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
