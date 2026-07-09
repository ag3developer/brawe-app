import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rtmp_broadcaster/camera.dart';
import '../../../data/repositories/live_repository.dart';

import '../services/last_live_config_service.dart';
import '../services/title_suggester.dart';
import 'start_live/vibe_check_bar.dart';
import 'start_live/warmup_overlay.dart';

import '../../../core/constants/app_constants.dart';
import '../../../data/model/create_live_room_request_dto.dart';
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
    if (_cameras.length < 2) return;
    _cameraIndex = (_cameraIndex + 1) % _cameras.length;
    await _controller?.dispose();
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

  void _openThumbnailSheet() {
    final s = S.of(context);
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.slate,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(
                Icons.camera_alt_outlined,
                color: AppColors.electricPurple,
              ),
              title: Text(
                s.startLiveThumbCaptureNow,
                style: const TextStyle(color: Colors.white),
              ),
              subtitle: Text(
                s.startLiveThumbCaptureNowSubtitle,
                style: const TextStyle(color: AppColors.coolGray),
              ),
              onTap: () {
                Navigator.pop(ctx);
                _captureThumbnailFromCamera();
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.image_outlined,
                color: AppColors.electricPurple,
              ),
              title: Text(
                s.startLiveThumbPickGallery,
                style: const TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(ctx);
                _pickThumbnailFromGallery();
              },
            ),
            if (ref.read(startLiveViewModelProvider).thumbnailUrl != null)
              ListTile(
                leading: const Icon(
                  Icons.delete_outline,
                  color: AppColors.mutedRed,
                ),
                title: Text(
                  s.startLiveThumbRemove,
                  style: const TextStyle(color: AppColors.mutedRed),
                ),
                onTap: () {
                  ref
                      .read(startLiveViewModelProvider.notifier)
                      .setThumbnail(null);
                  Navigator.pop(ctx);
                },
              ),
            const SizedBox(height: AppSpacing.sm),
          ],
        ),
      ),
    );
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

  void _showCategorySheet(BuildContext context, StartLiveState state) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF12121A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              ...AppConstants.categories.map((cat) {
                final icon =
                    _CategoryChips._icons[cat] ?? LucideIcons.helpCircle;
                final selected = state.category == cat;
                return ListTile(
                  leading: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color:
                          (selected ? AppColors.electricPurple : Colors.white)
                              .withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      icon,
                      color: selected
                          ? AppColors.electricPurple
                          : Colors.white70,
                      size: 18,
                    ),
                  ),
                  title: Text(
                    _CategoryChips.categoryLabel(S.of(context), cat),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  trailing: selected
                      ? const Icon(
                          Icons.check_rounded,
                          color: AppColors.electricPurple,
                        )
                      : null,
                  onTap: () {
                    ref
                        .read(startLiveViewModelProvider.notifier)
                        .updateCategory(cat);
                    _refreshSuggestions();
                    Navigator.pop(ctx);
                  },
                );
              }),
            ],
          ),
        ),
      ),
    );
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

          SafeArea(
            child: Column(
              children: [
                // ── TOP BAR ──
                _TikTokTopBar(onClose: () => context.pop(), onAddSound: () {}),
                const Spacer(),

                // ── RIGHT SIDE CONTROLS ──
                Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: _RightSideBar(
                      canFlip: _cameras.length > 1,
                      onFlip: _flipCamera,
                      onThumbnail: _pickThumbnailFromGallery,
                    ),
                  ),
                ),

                const Spacer(),

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
                  gradient: const [Color(0xFF3B82F6), Color(0xFF8B5CF6)],
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
                  gradient: const [
                    Color(0xFFA855F7),
                    Color(0xFFEC4899),
                    Color(0xFFF59E0B),
                  ],
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
        child: CircularProgressIndicator(color: AppColors.electricPurple),
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

class _TopBar extends StatelessWidget {
  const _TopBar({required this.onClose});
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          // Close
          GestureDetector(
            onTap: onClose,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(99),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.45),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.15),
                    ),
                  ),
                  child: const Icon(
                    LucideIcons.x,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Connection badge
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(99),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.10),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Color(0xFF4ADE80),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'Conexão: ótima',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const Spacer(),
          // LIVE badge
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.mutedRed.withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(LucideIcons.radio, color: Colors.white, size: 13),
                    SizedBox(width: 5),
                    Text(
                      'LIVE',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                      ),
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
}

class _GlassButton extends StatelessWidget {
  const _GlassButton({required this.icon, required this.onTap, this.label});
  final IconData icon;
  final VoidCallback onTap;
  final String? label;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Material(
          color: Colors.white.withValues(alpha: 0.15),
          child: InkWell(
            onTap: onTap,
            child: label != null
                ? Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(icon, color: Colors.white, size: 18),
                        const SizedBox(width: 6),
                        Text(
                          label!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  )
                : SizedBox(
                    width: 44,
                    height: 44,
                    child: Icon(icon, color: Colors.white, size: 22),
                  ),
          ),
        ),
      ),
    );
  }
}

class _BottomSheet extends StatelessWidget {
  const _BottomSheet({
    required this.state,
    required this.thumbnailPath,
    required this.titleController,
    required this.titleSuggestions,
    required this.onTitleChanged,
    required this.onSuggestionTap,
    required this.onCategoryChanged,
    required this.onVisibilityChanged,
    required this.onNotifyChanged,
    required this.onBattleModeChanged,
    required this.onGiftsChanged,
    required this.onTapFeaturedProduct,
    required this.onTapThumbnail,
    required this.onSubmit,
  });

  final StartLiveState state;
  final String? thumbnailPath;
  final TextEditingController titleController;
  final List<String> titleSuggestions;
  final ValueChanged<String> onTitleChanged;
  final ValueChanged<String> onSuggestionTap;
  final ValueChanged<String> onCategoryChanged;
  final ValueChanged<LiveVisibility> onVisibilityChanged;
  final ValueChanged<bool> onNotifyChanged;
  final ValueChanged<bool> onBattleModeChanged;
  final ValueChanged<bool> onGiftsChanged;
  final VoidCallback onTapFeaturedProduct;
  final VoidCallback onTapThumbnail;
  final VoidCallback? onSubmit;

  @override
  Widget build(BuildContext context) {
    final isLoading = state.status.isLoading;
    final s = S.of(context);
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF0A0A10).withValues(alpha: 0.94),
            border: Border(
              top: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
            ),
          ),
          padding: EdgeInsets.fromLTRB(
            20,
            14,
            20,
            20 + MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // ── Thumbnail + Título ──
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: isLoading ? null : onTapThumbnail,
                    child: Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.white.withValues(alpha: 0.07),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.15),
                        ),
                        image: thumbnailPath != null
                            ? DecorationImage(
                                image: FileImage(File(thumbnailPath!)),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: thumbnailPath == null
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  LucideIcons.image,
                                  color: Colors.white38,
                                  size: 18,
                                ),
                                const SizedBox(height: 2),
                                const Text(
                                  'Capa',
                                  style: TextStyle(
                                    color: Colors.white38,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _CompactTitleField(
                      controller: titleController,
                      onChanged: onTitleChanged,
                      enabled: !isLoading,
                    ),
                  ),
                ],
              ),

              // Title suggestions
              if (titleSuggestions.isNotEmpty) ...[
                const SizedBox(height: 8),
                _TitleSuggestions(
                  suggestions: titleSuggestions,
                  onTap: onSuggestionTap,
                  enabled: !isLoading,
                ),
              ],

              const SizedBox(height: 14),
              Divider(color: Colors.white.withValues(alpha: 0.07), height: 1),
              const SizedBox(height: 14),

              // ── Categorias ──
              _CompactCategoryRow(
                value: state.category,
                onChanged: onCategoryChanged,
                onShowAll: () => _showCategorySheet(context),
                enabled: !isLoading,
              ),

              const SizedBox(height: 14),
              Divider(color: Colors.white.withValues(alpha: 0.07), height: 1),
              const SizedBox(height: 16),

              // ── Feature circles row ──
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _FeatureCircle(
                    icon: LucideIcons.swords,
                    label: 'Batalha',
                    active: state.battleModeEnabled,
                    color: AppColors.electricPurple,
                    onTap: isLoading
                        ? null
                        : () => onBattleModeChanged(!state.battleModeEnabled),
                  ),
                  _FeatureCircle(
                    icon: LucideIcons.gift,
                    label: 'Gifts',
                    active: state.giftsEnabled,
                    color: const Color(0xFFEC4899),
                    onTap: isLoading
                        ? null
                        : () => onGiftsChanged(!state.giftsEnabled),
                  ),
                  _FeatureCircle(
                    icon: LucideIcons.bell,
                    label: 'Notificar',
                    active: state.notifyFollowers,
                    color: const Color(0xFF4ADE80),
                    onTap: isLoading
                        ? null
                        : () => onNotifyChanged(!state.notifyFollowers),
                  ),
                  _FeatureCircle(
                    icon: _visIcon(state.visibility),
                    label: _visShortLabel(s, state.visibility),
                    active: false,
                    color: Colors.white54,
                    onTap: isLoading
                        ? null
                        : () => _showVisibilitySheet(context),
                    showChevron: true,
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // ── Error ──
              if (state.errorMessage != null) ...[
                Text(
                  state.displayError(s) ?? state.errorMessage!,
                  style: const TextStyle(
                    color: AppColors.mutedRed,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 10),
              ],

              // ── GO LIVE button ──
              _GoLiveButton(onPressed: onSubmit, isLoading: isLoading),
            ],
          ),
        ),
      ),
    );
  }

  String _visLabel(S s, LiveVisibility v) {
    switch (v) {
      case LiveVisibility.public:
        return s.liveVisibilityPublic;
      case LiveVisibility.followers:
        return s.liveVisibilityFollowers;
      case LiveVisibility.private:
        return s.liveVisibilityPrivate;
    }
  }

  String _visShortLabel(S s, LiveVisibility v) {
    switch (v) {
      case LiveVisibility.public:
        return 'Público';
      case LiveVisibility.followers:
        return 'Seguidores';
      case LiveVisibility.private:
        return 'Privado';
    }
  }

  IconData _visIcon(LiveVisibility v) {
    switch (v) {
      case LiveVisibility.public:
        return LucideIcons.user;
      case LiveVisibility.followers:
        return LucideIcons.heart;
      case LiveVisibility.private:
        return LucideIcons.lock;
    }
  }

  void _showCategorySheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF12121A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                ...AppConstants.categories.map((cat) {
                  final icon =
                      _CategoryChips._icons[cat] ?? LucideIcons.helpCircle;
                  return ListTile(
                    leading: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color:
                            (state.category == cat
                                    ? AppColors.electricPurple
                                    : Colors.white)
                                .withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        icon,
                        color: state.category == cat
                            ? AppColors.electricPurple
                            : Colors.white70,
                        size: 18,
                      ),
                    ),
                    title: Text(
                      _CategoryChips.categoryLabel(S.of(context), cat),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    trailing: state.category == cat
                        ? const Icon(
                            Icons.check_rounded,
                            color: AppColors.electricPurple,
                          )
                        : null,
                    onTap: () {
                      onCategoryChanged(cat);
                      Navigator.pop(ctx);
                    },
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showVisibilitySheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF12121A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        final s = S.of(context);
        final options = [
          (
            LiveVisibility.public,
            Icons.public_outlined,
            s.liveVisibilityPublic,
            'Qualquer pessoa pode assistir',
          ),
          (
            LiveVisibility.followers,
            Icons.group_outlined,
            s.liveVisibilityFollowers,
            'Apenas seus seguidores',
          ),
          (
            LiveVisibility.private,
            Icons.lock_outline,
            s.liveVisibilityPrivate,
            'Somente com link privado',
          ),
        ];
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                ...options.map(
                  (o) => ListTile(
                    leading: Icon(o.$2, color: Colors.white70),
                    title: Text(
                      o.$3,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      o.$4,
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                      ),
                    ),
                    trailing: state.visibility == o.$1
                        ? const Icon(
                            Icons.check_rounded,
                            color: AppColors.electricPurple,
                          )
                        : null,
                    onTap: () {
                      onVisibilityChanged(o.$1);
                      Navigator.pop(ctx);
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _CompactTitleField extends StatelessWidget {
  const _CompactTitleField({
    required this.onChanged,
    this.controller,
    this.enabled = true,
  });
  final ValueChanged<String> onChanged;
  final TextEditingController? controller;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final charCount = controller?.text.length ?? 0;
    return Stack(
      alignment: Alignment.centerRight,
      children: [
        TextField(
          controller: controller,
          enabled: enabled,
          onChanged: onChanged,
          maxLength: 100,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          cursorColor: AppColors.electricPurple,
          decoration: InputDecoration(
            hintText: S.of(context).startLiveTitleHint,
            hintStyle: TextStyle(
              color: Colors.white.withValues(alpha: 0.35),
              fontWeight: FontWeight.w500,
              fontSize: 16,
            ),
            counterText: '',
            contentPadding: const EdgeInsets.only(
              left: 16,
              right: 56,
              top: 14,
              bottom: 14,
            ),
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.06),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: AppColors.electricPurple,
                width: 1.5,
              ),
            ),
          ),
        ),
        Positioned(
          right: 14,
          child: Text(
            '$charCount/100',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.3),
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

class _InlineDropdown extends StatelessWidget {
  const _InlineDropdown({
    required this.icon,
    required this.label,
    required this.onTap,
    this.enabled = true,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 15, color: Colors.white60),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.expand_more_rounded,
              size: 16,
              color: Colors.white.withValues(alpha: 0.4),
            ),
          ],
        ),
      ),
    );
  }
}

class _SlimToggleRow extends StatelessWidget {
  const _SlimToggleRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.onChanged,
    this.enabled = true,
  });
  final IconData icon;
  final Color iconColor;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled ? () => onChanged(!value) : null,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 2),
        child: Row(
          children: [
            Icon(icon, size: 16, color: iconColor),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Switch.adaptive(
              value: value,
              onChanged: enabled ? onChanged : null,
              activeColor: iconColor,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureTile extends StatelessWidget {
  const _FeatureTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.trailing,
    this.onTap,
  });
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final Widget trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.45),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            trailing,
          ],
        ),
      ),
    );
  }
}

class _LiveTitleField extends StatelessWidget {
  const _LiveTitleField({
    required this.onChanged,
    this.controller,
    this.enabled = true,
  });
  final ValueChanged<String> onChanged;
  final TextEditingController? controller;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      enabled: enabled,
      onChanged: onChanged,
      maxLength: 60,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
      cursorColor: AppColors.electricPurple,
      decoration: InputDecoration(
        hintText: S.of(context).startLiveTitleHint,
        hintStyle: TextStyle(
          color: Colors.white.withValues(alpha: 0.5),
          fontWeight: FontWeight.w500,
        ),
        counterText: '',
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.08),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(
            color: AppColors.electricPurple,
            width: 1.5,
          ),
        ),
      ),
    );
  }
}

class _CategoryChips extends StatelessWidget {
  const _CategoryChips({
    required this.value,
    required this.onChanged,
    this.enabled = true,
  });

  final String? value;
  final ValueChanged<String> onChanged;
  final bool enabled;

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
                    color: AppColors.electricPurple,
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
                  onTap: enabled
                      ? () => onChanged(selected ? '' : category)
                      : null,
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
                                AppColors.electricPurple,
                                AppColors.coolCyan,
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
                                color: AppColors.electricPurple.withValues(
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

class _VisibilityPicker extends StatelessWidget {
  const _VisibilityPicker({
    required this.value,
    required this.onChanged,
    this.enabled = true,
  });

  final LiveVisibility value;
  final ValueChanged<LiveVisibility> onChanged;
  final bool enabled;

  static String _label(S s, LiveVisibility v) {
    switch (v) {
      case LiveVisibility.public:
        return s.liveVisibilityPublic;
      case LiveVisibility.followers:
        return s.liveVisibilityFollowers;
      case LiveVisibility.private:
        return s.liveVisibilityPrivate;
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: LiveVisibility.values.map((v) {
          final selected = v == value;
          return Expanded(
            child: GestureDetector(
              onTap: enabled ? () => onChanged(v) : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                padding: const EdgeInsets.symmetric(vertical: 10),
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: selected
                      ? AppColors.electricPurple.withValues(alpha: 0.85)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      switch (v) {
                        LiveVisibility.public => Icons.public,
                        LiveVisibility.followers => Icons.group_outlined,
                        LiveVisibility.private => Icons.lock_outline,
                      },
                      size: 18,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _label(s, v),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: selected
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _NotifyFollowersToggle extends StatelessWidget {
  const _NotifyFollowersToggle({
    required this.value,
    required this.onChanged,
    this.enabled = true,
  });

  final bool value;
  final ValueChanged<bool> onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled ? () => onChanged(!value) : null,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            const Icon(
              Icons.notifications_active_outlined,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                S.of(context).startLiveNotifyFollowers,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
            Switch.adaptive(
              value: value,
              onChanged: enabled ? onChanged : null,
              activeThumbColor: AppColors.electricPurple,
            ),
          ],
        ),
      ),
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
            colors: [Color(0xFFE91E63), AppColors.electricPurple],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          boxShadow: enabled
              ? [
                  BoxShadow(
                    color: AppColors.electricPurple.withValues(alpha: 0.4),
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

class _TitleSuggestions extends StatelessWidget {
  const _TitleSuggestions({
    required this.suggestions,
    required this.onTap,
    this.enabled = true,
  });

  final List<String> suggestions;
  final ValueChanged<String> onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: suggestions.length + 1,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.xs),
        itemBuilder: (context, index) {
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.only(right: 2),
              child: Row(
                children: [
                  Icon(
                    Icons.auto_awesome,
                    size: 14,
                    color: AppColors.electricPurple.withValues(alpha: 0.9),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    S.of(context).startLiveSuggestions,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                ],
              ),
            );
          }
          final s = suggestions[index - 1];
          return InkWell(
            onTap: enabled ? () => onTap(s) : null,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: AppColors.electricPurple.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(
                  color: AppColors.electricPurple.withValues(alpha: 0.4),
                  width: 1,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                s,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
        },
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

/// Circular side control (flip/thumbnail) — floats on the right of the camera.
class _SideCircleButton extends StatelessWidget {
  const _SideCircleButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipOval(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.2),
                  ),
                ),
                child: Icon(icon, color: Colors.white, size: 20),
              ),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w600,
              shadows: [Shadow(color: Colors.black54, blurRadius: 4)],
            ),
          ),
        ],
      ),
    );
  }
}

/// Compact horizontal category row with icon chips.
class _CompactCategoryRow extends StatelessWidget {
  const _CompactCategoryRow({
    required this.value,
    required this.onChanged,
    required this.onShowAll,
    this.enabled = true,
  });

  final String value;
  final ValueChanged<String> onChanged;
  final VoidCallback onShowAll;
  final bool enabled;

  static const List<String> _quick = [
    'Gaming',
    'Música',
    'Talk Show',
    'Fitness',
    'Entretenimento',
  ];

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return SizedBox(
      height: 36,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          ..._quick.map((cat) {
            final selected = value == cat;
            final icon = _CategoryChips._icons[cat] ?? LucideIcons.helpCircle;
            return GestureDetector(
              onTap: enabled ? () => onChanged(selected ? '' : cat) : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: selected
                      ? AppColors.electricPurple.withValues(alpha: 0.9)
                      : Colors.white.withValues(alpha: 0.07),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: selected
                        ? AppColors.electricPurple
                        : Colors.white.withValues(alpha: 0.15),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, color: Colors.white, size: 13),
                    const SizedBox(width: 5),
                    Text(
                      _CategoryChips.categoryLabel(s, cat),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: selected
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
          // "Mais" button
          GestureDetector(
            onTap: enabled ? onShowAll : null,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.15),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(LucideIcons.helpCircle, color: Colors.white54, size: 13),
                  const SizedBox(width: 5),
                  const Text(
                    'Mais',
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Feature toggle circle with label — compact camera-style control.
class _FeatureCircle extends StatelessWidget {
  const _FeatureCircle({
    required this.icon,
    required this.label,
    required this.active,
    required this.color,
    required this.onTap,
    this.showChevron = false,
  });

  final IconData icon;
  final String label;
  final bool active;
  final Color color;
  final VoidCallback? onTap;
  final bool showChevron;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: active
                  ? color.withValues(alpha: 0.2)
                  : Colors.white.withValues(alpha: 0.07),
              shape: BoxShape.circle,
              border: Border.all(
                color: active
                    ? color.withValues(alpha: 0.7)
                    : Colors.white.withValues(alpha: 0.15),
                width: active ? 1.5 : 1,
              ),
              boxShadow: active
                  ? [
                      BoxShadow(
                        color: color.withValues(alpha: 0.3),
                        blurRadius: 10,
                      ),
                    ]
                  : null,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(icon, color: active ? color : Colors.white54, size: 22),
                if (showChevron)
                  Positioned(
                    bottom: 6,
                    right: 6,
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      color: Colors.white38,
                      size: 12,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              color: active ? color : Colors.white54,
              fontSize: 10,
              fontWeight: active ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

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
    final s = S.of(context);
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
