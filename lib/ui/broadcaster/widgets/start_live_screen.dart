import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
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
        AppSnackBar.showError(context, S.of(context).startLiveThumbCaptureFailed);
      }
    }
  }

  Future<void> _pickThumbnailFromGallery() async {
    final picker = ImagePicker();
    final XFile? file =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
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
              leading: const Icon(Icons.camera_alt_outlined,
                  color: AppColors.electricPurple),
              title: Text(s.startLiveThumbCaptureNow,
                  style: const TextStyle(color: Colors.white)),
              subtitle: Text(s.startLiveThumbCaptureNowSubtitle,
                  style: const TextStyle(color: AppColors.coolGray)),
              onTap: () {
                Navigator.pop(ctx);
                _captureThumbnailFromCamera();
              },
            ),
            ListTile(
              leading: const Icon(Icons.image_outlined,
                  color: AppColors.electricPurple),
              title: Text(s.startLiveThumbPickGallery,
                  style: const TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(ctx);
                _pickThumbnailFromGallery();
              },
            ),
            if (ref.read(startLiveViewModelProvider).thumbnailUrl != null)
              ListTile(
                leading: const Icon(Icons.delete_outline,
                    color: AppColors.mutedRed),
                title: Text(s.startLiveThumbRemove,
                    style: const TextStyle(color: AppColors.mutedRed)),
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
    final success =
        await ref.read(startLiveViewModelProvider.notifier).submit();
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
    unawaited(_lastConfig.save(
      title: state.title,
      category: state.category,
      visibility: state.visibility,
      notifyFollowers: state.notifyFollowers,
    ));

    // Se o usuário pediu para avisar seguidores, abre o warm-up de 30s.
    if (state.notifyFollowers) {
      // Dispara o anúncio (best-effort — se backend não suportar, segue o jogo).
      unawaited(
        ref.read(liveRepositoryProvider).announceLive(room.id, secondsUntilLive: 30),
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

    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          _buildPreview(),
          // Gradient escuro para dar contraste à UI sobreposta.
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0x99000000),
                  Color(0x33000000),
                  Color(0xCC000000),
                ],
                stops: [0.0, 0.4, 1.0],
              ),
            ),
            child: SizedBox.expand(),
          ),
          SafeArea(
            child: Column(
              children: [
                _TopBar(
                  onClose: () => context.pop(),
                  onFlip: _cameras.length > 1 ? _flipCamera : null,
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: VibeCheckBar(),
                  ),
                ),
                const Spacer(),
                _BottomSheet(
                  state: state,
                  thumbnailPath: state.thumbnailUrl,
                  titleController: _titleCtrl,
                  titleSuggestions: _titleSuggestions,
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
                  onCategoryChanged: (c) {
                    ref
                        .read(startLiveViewModelProvider.notifier)
                        .updateCategory(c);
                    _refreshSuggestions();
                  },
                  onVisibilityChanged: ref
                      .read(startLiveViewModelProvider.notifier)
                      .updateVisibility,
                  onNotifyChanged: ref
                      .read(startLiveViewModelProvider.notifier)
                      .toggleNotifyFollowers,
                  onBattleModeChanged: ref
                      .read(startLiveViewModelProvider.notifier)
                      .toggleBattleMode,
                  onGiftsChanged: ref
                      .read(startLiveViewModelProvider.notifier)
                      .toggleGifts,
                  onTapFeaturedProduct: () {
                    // TODO: abrir seletor de produto
                  },
                  onTapThumbnail: _openThumbnailSheet,
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
              const Icon(Icons.videocam_off_outlined,
                  color: AppColors.coolGray, size: 56),
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
  const _TopBar({required this.onClose, this.onFlip});

  final VoidCallback onClose;
  final VoidCallback? onFlip;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _GlassButton(icon: Icons.close, onTap: onClose),
          const SizedBox(width: 12),
          // Badge de conexão
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(99),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 7, height: 7,
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
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.chevron_right_rounded, size: 14, color: Colors.white.withValues(alpha: 0.5)),
                  ],
                ),
              ),
            ),
          ),
          const Spacer(),
          if (onFlip != null)
            _GlassButton(
              icon: Icons.flip_camera_ios_outlined,
              onTap: onFlip!,
              label: 'Inverter',
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
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(icon, color: Colors.white, size: 18),
                        const SizedBox(width: 6),
                        Text(label!, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
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
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF0E0E14).withValues(alpha: 0.92),
            border: Border(
              top: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
            ),
          ),
          padding: EdgeInsets.fromLTRB(
            20,
            20,
            20,
            20 + MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Drag handle ──
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 18),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

                // ── Título ──
                _CompactTitleField(
                  controller: titleController,
                  onChanged: onTitleChanged,
                  enabled: !isLoading,
                ),
                if (titleSuggestions.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  _TitleSuggestions(
                    suggestions: titleSuggestions,
                    onTap: onSuggestionTap,
                    enabled: !isLoading,
                  ),
                ],
                const SizedBox(height: 16),

                // ── Categoria + Visibilidade inline ──
                Row(
                  children: [
                    Expanded(
                      child: _InlineDropdown(
                        icon: Icons.category_outlined,
                        label: state.category.isEmpty
                            ? S.of(context).startLiveCategoryLabel
                            : _CategoryChips.categoryLabel(S.of(context), state.category),
                        onTap: () => _showCategorySheet(context),
                        enabled: !isLoading,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _InlineDropdown(
                        icon: Icons.public_outlined,
                        label: _visLabel(S.of(context), state.visibility),
                        onTap: () => _showVisibilitySheet(context),
                        enabled: !isLoading,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // ── Avisar seguidores ──
                _SlimToggleRow(
                  icon: Icons.notifications_active_outlined,
                  iconColor: const Color(0xFF4ADE80),
                  label: S.of(context).startLiveNotifyFollowers,
                  value: state.notifyFollowers,
                  onChanged: onNotifyChanged,
                  enabled: !isLoading,
                ),
                const SizedBox(height: 6),

                // ── Divisor ──
                Divider(color: Colors.white.withValues(alpha: 0.06), height: 16),

                // ── Feature tiles compactos ──
                _FeatureTile(
                  icon: Icons.sports_kabaddi_outlined,
                  iconColor: AppColors.electricPurple,
                  title: 'Modo batalha',
                  subtitle: 'Permitir desafios e batalhas com outros criadores',
                  trailing: Switch.adaptive(
                    value: state.battleModeEnabled,
                    onChanged: isLoading ? null : onBattleModeChanged,
                    activeColor: AppColors.electricPurple,
                  ),
                ),
                const SizedBox(height: 6),
                _FeatureTile(
                  icon: Icons.card_giftcard_outlined,
                  iconColor: const Color(0xFFEC4899),
                  title: 'Gifts',
                  subtitle: 'Receba presentes dos espectadores',
                  trailing: Switch.adaptive(
                    value: state.giftsEnabled,
                    onChanged: isLoading ? null : onGiftsChanged,
                    activeColor: const Color(0xFFEC4899),
                  ),
                ),
                const SizedBox(height: 6),
                _FeatureTile(
                  icon: Icons.shopping_bag_outlined,
                  iconColor: const Color(0xFFF59E0B),
                  title: 'Produto em destaque',
                  subtitle: 'Selecione um produto para promover na live',
                  trailing: const Icon(Icons.chevron_right_rounded,
                      color: Colors.white38, size: 20),
                  onTap: onTapFeaturedProduct,
                ),
                const SizedBox(height: 20),

                // ── Erro ──
                if (state.errorMessage != null) ...[
                  Text(
                    state.displayError(S.of(context)) ?? state.errorMessage!,
                    style: const TextStyle(color: AppColors.mutedRed),
                  ),
                  const SizedBox(height: 12),
                ],

                // ── Botão ENTRAR AO VIVO ──
                _GoLiveButton(onPressed: onSubmit, isLoading: isLoading),
                const SizedBox(height: 6),
                Center(
                  child: TextButton.icon(
                    onPressed: null,
                    icon: const Icon(Icons.help_outline, size: 14, color: Colors.white38),
                    label: const Text(
                      'Dicas para uma boa live',
                      style: TextStyle(color: Colors.white38, fontSize: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _visLabel(S s, LiveVisibility v) {
    switch (v) {
      case LiveVisibility.public: return s.liveVisibilityPublic;
      case LiveVisibility.followers: return s.liveVisibilityFollowers;
      case LiveVisibility.private: return s.liveVisibilityPrivate;
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
                  width: 36, height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                ...AppConstants.categories.map((cat) {
                  final emoji = _CategoryChips._emojis[cat] ?? '•';
                  return ListTile(
                    leading: Text(emoji, style: const TextStyle(fontSize: 20)),
                    title: Text(
                      _CategoryChips.categoryLabel(S.of(context), cat),
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                    ),
                    trailing: state.category == cat
                        ? const Icon(Icons.check_rounded, color: AppColors.electricPurple)
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
          (LiveVisibility.public, Icons.public_outlined, s.liveVisibilityPublic, 'Qualquer pessoa pode assistir'),
          (LiveVisibility.followers, Icons.group_outlined, s.liveVisibilityFollowers, 'Apenas seus seguidores'),
          (LiveVisibility.private, Icons.lock_outline, s.liveVisibilityPrivate, 'Somente com link privado'),
        ];
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 36, height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                ...options.map((o) => ListTile(
                  leading: Icon(o.$2, color: Colors.white70),
                  title: Text(o.$3, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                  subtitle: Text(o.$4, style: const TextStyle(color: Colors.white54, fontSize: 12)),
                  trailing: state.visibility == o.$1
                      ? const Icon(Icons.check_rounded, color: AppColors.electricPurple)
                      : null,
                  onTap: () {
                    onVisibilityChanged(o.$1);
                    Navigator.pop(ctx);
                  },
                )),
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
            contentPadding: const EdgeInsets.only(left: 16, right: 56, top: 14, bottom: 14),
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.06),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.electricPurple, width: 1.5),
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
            Icon(Icons.expand_more_rounded, size: 16, color: Colors.white.withValues(alpha: 0.4)),
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

  static const Map<String, String> _emojis = {
    'Shopping': '🛍️',
    'Gaming': '🎮',
    'Talk Show': '🎙️',
    'Música': '🎵',
    'Educação': '📚',
    'Fitness': '💪',
    'Culinária': '🍳',
    'Beleza': '💄',
    'Tecnologia': '💻',
    'Esportes': '⚽',
    'Entretenimento': '🎉',
    'Outro': '✨',
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
                final emoji = _emojis[category] ?? '•';
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
                                color: AppColors.electricPurple
                                    .withValues(alpha: 0.4),
                                blurRadius: 12,
                                spreadRadius: -2,
                              ),
                            ]
                          : null,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(emoji, style: const TextStyle(fontSize: 15)),
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
                        fontWeight:
                            selected ? FontWeight.w700 : FontWeight.w500,
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
            const Icon(Icons.notifications_active_outlined,
                color: Colors.white, size: 20),
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
            colors: [
              Color(0xFFE91E63),
              AppColors.electricPurple,
            ],
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
                        const Icon(Icons.fiber_manual_record,
                            color: Colors.white, size: 14),
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
                        const Icon(Icons.arrow_forward,
                            color: Colors.white, size: 18),
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
