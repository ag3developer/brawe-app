import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rtmp_broadcaster/camera.dart';
import '../../../data/repositories/live_repository.dart';

import '../services/last_live_config_service.dart';
import '../services/title_suggester.dart';
import 'start_live/warmup_overlay.dart';

import '../../../core/constants/app_constants.dart';
import '../../../gen/l10n/app_localizations.dart';
import '../../core/themes/app_colors.dart';
import '../../live/view_models/live_eligibility_view_model.dart';
import '../../core/ui/app_radius.dart';
import '../../core/ui/app_snackbar.dart';
import '../../core/ui/app_spacing.dart';
import '../view_models/start_live_view_model.dart';

/// Tela "Brawe Way" para iniciar live:
/// - Preview da câmera fullscreen como fundo
/// - Bottom sheet em glass com título, categoria, visibilidade, notificar seguidores
/// - Auto-captura de capa (frame da câmera) ou upload da galeria
/// - Flip câmera no topo
class StartLiveScreen extends ConsumerStatefulWidget {
  const StartLiveScreen({super.key});

  @override
  ConsumerState<StartLiveScreen> createState() => _StartLiveScreenState();
}

class _StartLiveScreenState extends ConsumerState<StartLiveScreen>
    with WidgetsBindingObserver {
  CameraController? _controller;
  List<CameraDescription> _cameras = const [];
  int _cameraIndex = 0;
  bool _initializing = true;
  String? _initError;
  bool _showWarmup = false;
  List<String> _titleSuggestions = const [];
  final TextEditingController _titleCtrl = TextEditingController();
  final LastLiveConfigService _lastConfig = LastLiveConfigService();
  final TitleSuggester _suggester = const TitleSuggester();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _bootstrapCamera();
    // Defer i18n-dependent work until after first frame so `S.of(context)`
    // is available.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _loadLastConfig();
      _refreshSuggestions();
    });
  }

  Future<void> _loadLastConfig() async {
    final cfg = await _lastConfig.load();
    if (cfg == null || !mounted) return;
    final suggested = cfg.suggestedTitle();
    _titleCtrl.text = suggested;
    final vm = ref.read(startLiveViewModelProvider.notifier);
    vm.updateTitle(suggested);
    if (cfg.category.isNotEmpty) vm.updateCategory(cfg.category);
    vm.updateVisibility(cfg.visibility);
    vm.toggleNotifyFollowers(cfg.notifyFollowers);
    _refreshSuggestions();
  }

  void _refreshSuggestions() {
    if (!mounted) return;
    final cat = ref.read(startLiveViewModelProvider).category;
    setState(() {
      _titleSuggestions = _suggester.suggest(
        s: S.of(context),
        category: cat.isEmpty ? null : cat,
      );
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    _titleCtrl.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final c = _controller;
    if (c == null || c.value.isInitialized != true) return;
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      c.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _bootstrapCamera();
    }
  }

  Future<void> _bootstrapCamera() async {
    if (!mounted) return;
    setState(() {
      _initializing = true;
      _initError = null;
    });

    try {
      final cameraStatus = await Permission.camera.request();
      final micStatus = await Permission.microphone.request();
      if (!cameraStatus.isGranted || !micStatus.isGranted) {
        setState(() {
          _initializing = false;
          _initError = S.of(context).startLivePermissionDenied;
        });
        return;
      }

      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        setState(() {
          _initializing = false;
          _initError = S.of(context).startLiveNoCamera;
        });
        return;
      }
      // Por padrão usa câmera frontal (selfie).
      final frontIdx = cameras.indexWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
      );
      _cameras = cameras;
      _cameraIndex = frontIdx >= 0 ? frontIdx : 0;
      await _setupController(_cameras[_cameraIndex]);
      if (mounted) setState(() => _initializing = false);
    } catch (e) {
      if (mounted) {
        setState(() {
          _initializing = false;
          _initError = S.of(context).startLiveCameraInitError(e.toString());
        });
      }
    }
  }

  Future<void> _setupController(CameraDescription description) async {
    final controller = CameraController(
      description,
      ResolutionPreset.high,
      enableAudio: true,
      androidUseOpenGL: false,
    );
    _controller = controller;
    try {
      await controller.initialize();
      if (mounted) setState(() {});
    } catch (e) {
      if (mounted) {
        setState(() => _initError = S.of(context).startLiveCameraInitFailed);
      }
    }
  }

  Future<void> _flipCamera() async {
    if (_cameras.length < 2 || !mounted) return;
    _cameraIndex = (_cameraIndex + 1) % _cameras.length;
    await _controller?.dispose();
    if (!mounted) return; // Check again after dispose, as it's async
    await _setupController(_cameras[_cameraIndex]);
  }

  Future<void> _captureThumbnailFromCamera() async {
    final controller = _controller;
    if (controller == null || controller.value.isInitialized != true) return;
    try {
      final tmpDir = await getTemporaryDirectory();
      final path =
          '${tmpDir.path}/live_thumb_${DateTime.now().millisecondsSinceEpoch}.jpg';
      await controller.takePicture(path);
      ref.read(startLiveViewModelProvider.notifier).setThumbnail(path);
      if (mounted) {
        AppSnackBar.showSuccess(context, S.of(context).startLiveThumbCaptured);
      }
    } catch (e) {
      if (mounted) {
        AppSnackBar.showError(
          context,
          S.of(context).startLiveThumbCaptureFailed,
        );
      }
    }
  }

  Future<void> _pickThumbnailFromGallery() async {
    final picker = ImagePicker();
    final XFile? file = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (file == null) return;
    ref.read(startLiveViewModelProvider.notifier).setThumbnail(file.path);
    if (mounted) {
      AppSnackBar.showSuccess(context, S.of(context).startLiveThumbUpdated);
    }
  }

  Future<void> _onStartLive() async {
    final s = S.of(context);
    final success = await ref
        .read(startLiveViewModelProvider.notifier)
        .submit();
    if (!mounted) return;

    if (!success) {
      final error = ref.read(startLiveViewModelProvider).displayError(s);
      if (error != null) AppSnackBar.showError(context, error);
      return;
    }

    final state = ref.read(startLiveViewModelProvider);
    final room = state.status.asData?.value;
    if (room == null) {
      AppSnackBar.showError(context, s.startLiveRoomDataError);
      return;
    }

    // Persiste última config para "Re-Live preset" na próxima vez.
    unawaited(
      _lastConfig.save(
        title: state.title,
        category: state.category,
        visibility: state.visibility,
        notifyFollowers: state.notifyFollowers,
      ),
    );

    // Se o usuário pediu para avisar seguidores, abre o warm-up de 30s.
    if (state.notifyFollowers) {
      // Dispara o anúncio (best-effort — se backend não suportar, segue o jogo).
      unawaited(
        ref
            .read(liveRepositoryProvider)
            .announceLive(room.id, secondsUntilLive: 30),
      );
      setState(() => _showWarmup = true);
      return;
    }

    await _goToBroadcaster();
  }

  Future<void> _goToBroadcaster() async {
    final room = ref.read(startLiveViewModelProvider).status.asData?.value;
    if (room == null) return;
    await _controller?.dispose();
    _controller = null;
    if (!mounted) return;
    context.go('/live/broadcast', extra: room);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(startLiveViewModelProvider);
    final eligAsync = ref.watch(liveEligibilityProvider);
    final isLoading = state.status.isLoading;

    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Camera preview fullscreen ──
          _buildPreview(),

          // ── Gradient overlay ──
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xBB000000),
                  Color(0x00000000),
                  Color(0x00000000),
                  Color(0xEE000000),
                ],
                stops: [0.0, 0.2, 0.55, 1.0],
              ),
            ),
            child: SizedBox.expand(),
          ),

          // ── RIGHT SIDE CONTROLS (flutuando no Stack, fora da Column) ──
          Positioned(
            right: 12,
            bottom: MediaQuery.of(context).size.height * 0.32,
            child: _RightSideBar(
              canFlip: _cameras.length > 1,
              onFlip: _flipCamera,
              onThumbnail: _pickThumbnailFromGallery,
            ),
          ),

          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // ── TOP BAR ──
                _TikTokTopBar(onClose: () => context.pop(), onAddSound: () {}),

                // ── BOTTOM AREA ──
                _TikTokBottomArea(
                  state: state,
                  titleController: _titleCtrl,
                  titleSuggestions: _titleSuggestions,
                  isLoading: isLoading,
                  onTitleChanged: ref
                      .read(startLiveViewModelProvider.notifier)
                      .updateTitle,
                  onSuggestionTap: (s) {
                    _titleCtrl.text = s;
                    _titleCtrl.selection = TextSelection.fromPosition(
                      TextPosition(offset: s.length),
                    );
                    ref
                        .read(startLiveViewModelProvider.notifier)
                        .updateTitle(s);
                  },
                  onCategoryChanged: (cat) {
                    ref
                        .read(startLiveViewModelProvider.notifier)
                        .updateCategory(cat);
                    _refreshSuggestions();
                  },
                  onBattleTap: () => ref
                      .read(startLiveViewModelProvider.notifier)
                      .toggleBattleMode(!state.battleModeEnabled),
                  onGiftsTap: () => ref
                      .read(startLiveViewModelProvider.notifier)
                      .toggleGifts(!state.giftsEnabled),
                  onNotifyTap: () => ref
                      .read(startLiveViewModelProvider.notifier)
                      .toggleNotifyFollowers(!state.notifyFollowers),
                  onThumbnailTap: _pickThumbnailFromGallery,
                  onThumbnailLongPress: _captureThumbnailFromCamera,
                  onSubmit: state.canSubmit ? _onStartLive : null,
                ),
              ],
            ),
          ),
          if (_showWarmup)
            WarmupOverlay(
              totalSeconds: 30,
              onComplete: _goToBroadcaster,
              onCancel: () => setState(() => _showWarmup = false),
            ),
          // Eligibility overlay — cobre câmera quando não apto ou carregando
          eligAsync.when(
            loading: () => const _EligibilityLoadingOverlay(),
            error: (e, _) => _EligibilityBlockedOverlay(
              icon: Icons.cloud_off_rounded,
              title: 'Não foi possível verificar',
              subtitle: 'Verifique sua conexão e tente novamente.',
              ctaLabel: 'Tentar novamente',
              onCta: () => ref.invalidate(liveEligibilityProvider),
              onClose: () => context.pop(),
              gradient: const [Color(0xFF64748B), Color(0xFF475569)],
            ),
            data: (elig) {
              if (elig.canGoLive) return const SizedBox.shrink();
              if (elig.needsAvatar) {
                return _EligibilityBlockedOverlay(
                  icon: Icons.account_circle_outlined,
                  title: 'Adicione uma foto de perfil',
                  subtitle:
                      'Lives só podem ser iniciadas por usuários com foto de perfil.',
                  ctaLabel: 'Adicionar foto agora',
                  ctaIcon: Icons.camera_alt_rounded,
                  onCta: () {
                    invalidateLiveEligibilityCache();
                    context.pop();
                    context.push('/edit-profile');
                  },
                  onClose: () => context.pop(),
                  gradient: const [AppColors.braweBlue, AppColors.braweSky],
                );
              }
              if (elig.needsCreator) {
                return _EligibilityBlockedOverlay(
                  icon: Icons.workspace_premium_rounded,
                  title: 'Live é exclusivo do Creator Network',
                  subtitle:
                      'Transmissões ao vivo são liberadas após aprovação no programa. É grátis e leva poucos minutos.',
                  ctaLabel: 'Inscrever-se no programa',
                  ctaIcon: Icons.rocket_launch_rounded,
                  onCta: () {
                    invalidateLiveEligibilityCache();
                    context.pop();
                    context.push('/creator/intro');
                  },
                  onClose: () => context.pop(),
                  gradient: AppColors.brandGradient,
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPreview() {
    if (_initializing) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.braweBlue),
      );
    }
    if (_initError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.videocam_off_outlined,
                color: AppColors.coolGray,
                size: 56,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                _initError!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
              const SizedBox(height: AppSpacing.lg),
              FilledButton(
                onPressed: _bootstrapCamera,
                child: Text(S.of(context).startLiveRetry),
              ),
            ],
          ),
        ),
      );
    }
    final controller = _controller;
    if (controller == null || controller.value.isInitialized != true) {
      return const ColoredBox(color: Colors.black);
    }
    return FittedBox(
      fit: BoxFit.cover,
      child: SizedBox(
        width: controller.value.previewSize?.height ?? 1080,
        height: controller.value.previewSize?.width ?? 1920,
        child: CameraPreview(controller),
      ),
    );
  }
}

class _CategoryChips extends StatelessWidget {
  const _CategoryChips({
    required this.value,
    required this.onChanged,
  });

  final String? value;
  final ValueChanged<String> onChanged;

  static const Map<String, IconData> _icons = {
    'Shopping': LucideIcons.shoppingBag, // sacola de compras ✓
    'Gaming': Icons.sports_esports, // controle de videogame ✓
    'Talk Show': LucideIcons.mic2, // microfone ✓
    'Música': LucideIcons.music, // nota musical ✓
    'Educação': LucideIcons.bookMarked, // livro ✓
    'Fitness': Icons.fitness_center, // haltere ✓
    'Culinária': Icons.restaurant, // garfo e faca ✓
    'Beleza': LucideIcons.sparkles, // brilho ✓
    'Tecnologia': Icons.developer_mode, // código/tech ✓
    'Esportes': LucideIcons.trophy, // troféu ✓
    'Entretenimento': LucideIcons.disc3, // disco ✓
    'Outro': LucideIcons.plus, // genérico ✓
  };

  static String categoryLabel(S s, String id) {
    switch (id) {
      case 'Shopping':
        return s.liveCategoryShopping;
      case 'Gaming':
        return s.liveCategoryGaming;
      case 'Talk Show':
        return s.liveCategoryTalkShow;
      case 'Música':
        return s.liveCategoryMusic;
      case 'Educação':
        return s.liveCategoryEducation;
      case 'Fitness':
        return s.liveCategoryFitness;
      case 'Culinária':
        return s.liveCategoryCooking;
      case 'Beleza':
        return s.liveCategoryBeauty;
      case 'Tecnologia':
        return s.liveCategoryTech;
      case 'Esportes':
        return s.liveCategorySports;
      case 'Entretenimento':
        return s.liveCategoryEntertainment;
      case 'Outro':
        return s.liveCategoryOther;
      default:
        return id;
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 2, bottom: 8),
          child: Row(
            children: [
              Text(
                s.startLiveCategoryLabel,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              const SizedBox(width: 6),
              if (value != null && value!.isNotEmpty)
                Text(
                  '· ${categoryLabel(s, value!)}',
                  style: const TextStyle(
                    color: AppColors.braweBlue,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              const Spacer(),
              Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: Colors.white.withValues(alpha: 0.4),
              ),
            ],
          ),
        ),
        ShaderMask(
          shaderCallback: (rect) => LinearGradient(
            colors: const [
              Colors.transparent,
              Colors.black,
              Colors.black,
              Colors.transparent,
            ],
            stops: const [0.0, 0.04, 0.96, 1.0],
          ).createShader(rect),
          blendMode: BlendMode.dstIn,
          child: SizedBox(
            height: 44,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 2),
              itemCount: AppConstants.categories.length,
              separatorBuilder: (context, index) =>
                  const SizedBox(width: AppSpacing.sm),
              itemBuilder: (context, index) {
                final category = AppConstants.categories[index];
                final selected = value == category;
                final icon = _icons[category] ?? LucideIcons.helpCircle;
                return GestureDetector(
                  onTap: () => onChanged(selected ? '' : category),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: AppSpacing.sm,
                    ),
                    decoration: BoxDecoration(
                      gradient: selected
                          ? const LinearGradient(
                              colors: [
                                AppColors.braweBlue,
                                AppColors.braweSky,
                              ],
                            )
                          : null,
                      color: selected
                          ? null
                          : Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: selected
                            ? Colors.transparent
                            : Colors.white.withValues(alpha: 0.15),
                        width: 1.2,
                      ),
                      boxShadow: selected
                          ? [
                              BoxShadow(
                                color: AppColors.braweBlue.withValues(
                                  alpha: 0.4,
                                ),
                                blurRadius: 12,
                                spreadRadius: -2,
                              ),
                            ]
                          : null,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(icon, color: Colors.white, size: 14),
                        const SizedBox(width: 6),
                        Text(
                          categoryLabel(s, category),
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: selected
                                ? FontWeight.w700
                                : FontWeight.w500,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _GoLiveButton extends StatelessWidget {
  const _GoLiveButton({required this.onPressed, required this.isLoading});
  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !isLoading;
    return Opacity(
      opacity: enabled ? 1 : 0.6,
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          gradient: const LinearGradient(
            colors: [AppColors.braweBlue, AppColors.braweSky],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          boxShadow: enabled
              ? [
                  BoxShadow(
                    color: AppColors.braweBlue.withValues(alpha: 0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ]
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: enabled ? onPressed : null,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            child: Center(
              child: isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.fiber_manual_record,
                          color: Colors.white,
                          size: 14,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          S.of(context).startLiveGoLive,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                            letterSpacing: 1.1,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.arrow_forward,
                          color: Colors.white,
                          size: 18,
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ELIGIBILITY OVERLAYS
// ─────────────────────────────────────────────────────────────────────────────

/// Spinner de carregamento sobre o preview da câmera.
class _EligibilityLoadingOverlay extends StatelessWidget {
  const _EligibilityLoadingOverlay();

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
      child: Container(
        color: Colors.black.withValues(alpha: 0.65),
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
              SizedBox(height: 16),
              Text(
                'Verificando permissões…',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Overlay de bloqueio — câmera visível atrás com blur + mensagem centralizada.
class _EligibilityBlockedOverlay extends StatelessWidget {
  const _EligibilityBlockedOverlay({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.ctaLabel,
    required this.onCta,
    required this.onClose,
    required this.gradient,
    this.ctaIcon,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String ctaLabel;
  final IconData? ctaIcon;
  final VoidCallback onCta;
  final VoidCallback onClose;
  final List<Color> gradient;

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
      child: Container(
        color: Colors.black.withValues(alpha: 0.72),
        child: SafeArea(
          child: Column(
            children: [
              // Close button top-right
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.only(top: 12, right: 16),
                  child: GestureDetector(
                    onTap: onClose,
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.2),
                        ),
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ),
              const Spacer(),
              // Icon with gradient glow
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: gradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: gradient.first.withValues(alpha: 0.5),
                      blurRadius: 32,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: Icon(icon, color: Colors.white, size: 48),
              ),
              const SizedBox(height: 28),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 36),
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 36),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton.icon(
                    onPressed: onCta,
                    icon: Icon(ctaIcon ?? Icons.arrow_forward, size: 18),
                    label: Text(
                      ctaLabel,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: gradient.first,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: onClose,
                child: Text(
                  'Agora não',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 13.5,
                  ),
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// NEW CAMERA-STYLE WIDGETS
// ─────────────────────────────────────────────────────────────────────────────

// ═════════════════════════════════════════════════════════════════════════════
// TIKTOK-STYLE WIDGETS
// ═════════════════════════════════════════════════════════════════════════════

// ── Top Bar ───────────────────────────────────────────────────────────────────
class _TikTokTopBar extends StatelessWidget {
  const _TikTokTopBar({required this.onClose, required this.onAddSound});
  final VoidCallback onClose;
  final VoidCallback onAddSound;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          // Close button
          GestureDetector(
            onTap: onClose,
            child: ClipOval(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  width: 36,
                  height: 36,
                  color: Colors.black.withValues(alpha: 0.45),
                  child: const Icon(Icons.close, color: Colors.white, size: 18),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Add sound pill
          GestureDetector(
            onTap: onAddSound,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 7,
                  ),
                  color: Colors.black.withValues(alpha: 0.5),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(LucideIcons.music, color: Colors.white, size: 14),
                      const SizedBox(width: 6),
                      const Text(
                        'Adicionar som',
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
          ),

          const Spacer(),

          // LIVE badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
            ),
            child: const Text(
              'LIVE',
              style: TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Right Side Bar ────────────────────────────────────────────────────────────
class _RightSideBar extends StatelessWidget {
  const _RightSideBar({
    required this.canFlip,
    required this.onFlip,
    required this.onThumbnail,
  });
  final bool canFlip;
  final VoidCallback onFlip;
  final VoidCallback onThumbnail;

  @override
  Widget build(BuildContext context) {
    final items = <({IconData icon, String label, VoidCallback? onTap})>[
      if (canFlip) (icon: LucideIcons.refreshCw, label: 'Virar', onTap: onFlip),
      (icon: LucideIcons.sparkles, label: 'Beleza', onTap: null),
      (icon: LucideIcons.aperture, label: 'Filtros', onTap: null),
      (icon: LucideIcons.share2, label: 'Compartilhar', onTap: null),
      (icon: LucideIcons.image, label: 'Capa', onTap: onThumbnail),
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: items.map((item) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: GestureDetector(
            onTap: item.onTap,
            child: Opacity(
              opacity: item.onTap != null ? 1.0 : 0.4,
              child: Column(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.4),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Icon(item.icon, color: Colors.white, size: 20),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      shadows: [Shadow(blurRadius: 4, color: Colors.black54)],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ── Bottom Area (TikTok style) ────────────────────────────────────────────────
class _TikTokBottomArea extends StatelessWidget {
  const _TikTokBottomArea({
    required this.state,
    required this.titleController,
    required this.titleSuggestions,
    required this.isLoading,
    required this.onTitleChanged,
    required this.onSuggestionTap,
    required this.onCategoryChanged,
    required this.onBattleTap,
    required this.onGiftsTap,
    required this.onNotifyTap,
    required this.onThumbnailTap,
    required this.onThumbnailLongPress,
    required this.onSubmit,
  });

  final StartLiveState state;
  final TextEditingController titleController;
  final List<String> titleSuggestions;
  final bool isLoading;
  final ValueChanged<String> onTitleChanged;
  final ValueChanged<String> onSuggestionTap;
  final ValueChanged<String> onCategoryChanged;
  final VoidCallback onBattleTap;
  final VoidCallback onGiftsTap;
  final VoidCallback onNotifyTap;
  final VoidCallback onThumbnailTap;
  final VoidCallback onThumbnailLongPress;
  final VoidCallback? onSubmit;

  @override
  Widget build(BuildContext context) {
    // Reduz espaçamentos em telas com menos de 750pt de altura útil
    final screenH = MediaQuery.of(context).size.height;
    final compact = screenH < 750;
    final gap = compact ? 8.0 : 16.0;
    final gap2 = compact ? 10.0 : 20.0;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        0,
        16,
        16 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Thumbnail + Title ──
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Thumbnail
              GestureDetector(
                onTap: isLoading ? null : onThumbnailTap,
                onLongPress: isLoading ? null : onThumbnailLongPress,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    width: 50,
                    height: 50,
                    child: state.thumbnailUrl != null
                        ? Image.file(
                            File(state.thumbnailUrl!),
                            fit: BoxFit.cover,
                          )
                        : Container(
                            color: Colors.white.withValues(alpha: 0.1),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  LucideIcons.image,
                                  color: Colors.white60,
                                  size: 18,
                                ),
                                const SizedBox(height: 2),
                                const Text(
                                  'Alterar',
                                  style: TextStyle(
                                    color: Colors.white60,
                                    fontSize: 9,
                                  ),
                                ),
                              ],
                            ),
                          ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Title field
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: titleController,
                            onChanged: onTitleChanged,
                            enabled: !isLoading,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLength: 100,
                            decoration: InputDecoration(
                              hintText: 'Adicionar um título',
                              hintStyle: TextStyle(
                                color: Colors.white.withValues(alpha: 0.4),
                                fontSize: 15,
                              ),
                              border: InputBorder.none,
                              counterText: '',
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                              filled: true,
                              fillColor: Colors.transparent,
                              enabledBorder: const UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white30),
                              ),
                              focusedBorder: const UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white70),
                              ),
                            ),
                          ),
                        ),
                        ValueListenableBuilder(
                          valueListenable: titleController,
                          builder: (_, val, _) => Text(
                            '${val.text.length}/100',
                            style: const TextStyle(
                              color: Colors.white38,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: gap),

          // ── Category grid inline ──
          _InlineCategoryGrid(
            selected: state.category,
            onChanged: isLoading ? null : onCategoryChanged,
          ),
          SizedBox(height: gap),

          // ── Actions row ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _ActionCircle(
                icon: LucideIcons.swords,
                label: 'Batalha',
                active: state.battleModeEnabled,
                onTap: isLoading ? null : onBattleTap,
              ),
              _ActionCircle(
                icon: LucideIcons.gift,
                label: 'Presentes',
                active: state.giftsEnabled,
                onTap: isLoading ? null : onGiftsTap,
              ),
              _ActionCircle(
                icon: LucideIcons.bell,
                label: 'Notificar',
                active: state.notifyFollowers,
                onTap: isLoading ? null : onNotifyTap,
              ),
              _ActionCircle(
                icon: LucideIcons.user,
                label: 'Convidados',
                active: false,
                onTap: null,
                dimmed: true,
              ),
              _ActionCircle(
                icon: LucideIcons.zap,
                label: 'Promover',
                active: false,
                onTap: null,
                dimmed: true,
              ),
            ],
          ),
          SizedBox(height: gap2),

          // ── Error ──
          if (state.errorMessage != null) ...[
            Text(
              state.errorMessage!,
              style: const TextStyle(color: Colors.redAccent, fontSize: 12),
            ),
            const SizedBox(height: 8),
          ],

          // ── Go Live button ──
          SizedBox(
            width: double.infinity,
            height: compact ? 50 : 58,
            child: _GoLiveButton(onPressed: onSubmit, isLoading: isLoading),
          ),
          SizedBox(height: compact ? 4 : 8),

          // ── Safety text + Mode selector em linha para economizar espaço ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.shield_outlined, color: Colors.white38, size: 11),
                  const SizedBox(width: 4),
                  const Text(
                    'LIVE pública',
                    style: TextStyle(color: Colors.white38, fontSize: 10),
                  ),
                ],
              ),
              if (!compact) const _ModeSelector(),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Action Circle ─────────────────────────────────────────────────────────────
class _ActionCircle extends StatelessWidget {
  const _ActionCircle({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
    this.dimmed = false,
  });
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback? onTap;
  final bool dimmed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: dimmed ? 0.35 : 1.0,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: active
                    ? Colors.white.withValues(alpha: 0.2)
                    : Colors.white.withValues(alpha: 0.1),
                border: Border.all(
                  color: active
                      ? Colors.white.withValues(alpha: 0.6)
                      : Colors.white.withValues(alpha: 0.2),
                  width: active ? 1.5 : 1,
                ),
              ),
              child: Icon(
                icon,
                color: active ? Colors.white : Colors.white70,
                size: 22,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              label,
              style: TextStyle(
                color: active ? Colors.white : Colors.white54,
                fontSize: 10,
                fontWeight: active ? FontWeight.w700 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Mode Selector (TikTok bottom nav) ────────────────────────────────────────
class _ModeSelector extends StatelessWidget {
  const _ModeSelector();

  @override
  Widget build(BuildContext context) {
    const modes = ['Câmera', 'LIVE', 'Modelo', 'MV'];
    const activeIndex = 1; // LIVE always selected

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: modes.asMap().entries.map((e) {
        final isActive = e.key == activeIndex;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                e.value,
                style: TextStyle(
                  color: isActive ? Colors.white : Colors.white38,
                  fontSize: isActive ? 14 : 13,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
                ),
              ),
              const SizedBox(height: 4),
              if (isActive)
                Container(
                  width: 20,
                  height: 2,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(1),
                  ),
                )
              else
                const SizedBox(height: 2),
            ],
          ),
        );
      }).toList(),
    );
  }
}

// ── Inline Category Grid ──────────────────────────────────────────────────────
class _InlineCategoryGrid extends StatelessWidget {
  const _InlineCategoryGrid({required this.selected, required this.onChanged});

  final String selected;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final categories = AppConstants.categories;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: categories.map((cat) {
        final isSelected = selected == cat;
        final icon = _CategoryChips._icons[cat] ?? LucideIcons.helpCircle;

        return GestureDetector(
          onTap: onChanged != null
              ? () => onChanged!(isSelected ? '' : cat)
              : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: isSelected
                  ? Colors.white.withValues(alpha: 0.22)
                  : Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected
                    ? Colors.white.withValues(alpha: 0.6)
                    : Colors.white.withValues(alpha: 0.15),
                width: isSelected ? 1.5 : 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  color: isSelected ? Colors.white : Colors.white60,
                  size: 13,
                ),
                const SizedBox(width: 6),
                Text(
                  _CategoryChips.categoryLabel(s, cat),
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.white60,
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
