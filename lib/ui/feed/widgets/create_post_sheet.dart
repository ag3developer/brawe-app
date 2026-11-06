import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../data/repositories/auth_state_provider.dart';
import '../../../data/services/city_location_service.dart';
import '../../../domain/models/poll_draft.dart';
import '../../../domain/models/post_poll.dart';
import '../../../data/repositories/post_repository.dart';
import '../../../domain/models/sound.dart';
import '../../../gen/l10n/app_localizations.dart';
import '../../core/themes/app_colors.dart';
import '../../core/themes/brawe_colors.dart';
import '../../feed/view_models/feed_view_model.dart';
import '../../home/view_models/for_you_feed_view_model.dart';
import '../../sounds/view_models/sound_player_view_model.dart';
import '../../sounds/widgets/sound_trim_screen.dart';
import '../../sounds/widgets/sounds_catalog_screen.dart';
import 'package:brawe_app/ui/core/ui/image_decode.dart';
import 'post_location_widgets.dart';
import 'post_poll_editor.dart';

class CreatePostSheet extends ConsumerStatefulWidget {
  const CreatePostSheet({super.key});

  @override
  ConsumerState<CreatePostSheet> createState() => _CreatePostSheetState();
}

class _CreatePostSheetState extends ConsumerState<CreatePostSheet> {
  /// Insere "#" na posição do cursor (com espaço antes, se preciso).
  void _insertHashtag() {
    final t = _textController.text;
    final sel = _textController.selection;
    final at = sel.isValid ? sel.start : t.length;
    final needSpace = at > 0 && t[at - 1] != ' ' && t[at - 1] != '\n';
    final ins = needSpace ? ' #' : '#';
    final end = sel.isValid ? sel.end : t.length;
    _textController.value = TextEditingValue(
      text: t.replaceRange(at, end, ins),
      selection: TextSelection.collapsed(offset: at + ins.length),
    );
    setState(() {});
  }

  final TextEditingController _textController = TextEditingController();
  File? _selectedImage;
  Sound? _selectedSound;
  bool _isPosting = false;

  // Enquete (exclusiva com foto) e cidade do post.
  PollDraft? _poll;
  PostLocation? _location;
  bool _locating = false;
  String _audience = 'Todos';

  // Brawe Sound: trecho ESPECÍFICO escolhido para ESTE post (não o trim
  // default sugerido pelo artista). Teto de segurança igual ao validado
  // no backend (`MAX_TRIM_MS_BY_CONTEXT["posts"]` = 60s).
  static const Duration _kMaxSoundTrim = Duration(seconds: 60);
  int _soundTrimStartMs = 0;
  int? _soundTrimEndMs;

  int get _charCount => _textController.text.length;
  static const _maxChars = 500;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _post() async {
    if (_textController.text.trim().isEmpty) return;
    if (_poll != null && !_poll!.isValid) return;
    setState(() => _isPosting = true);
    try {
      await ref
          .read(postRepositoryProvider)
          .createPost(
            content: _textController.text.trim(),
            imageLocalPath: _selectedImage?.path,
            audience: _audience,
            soundId: _selectedSound?.id,
            soundTrimStartMs: _soundTrimStartMs,
            soundTrimEndMs: _soundTrimEndMs,
            poll: _poll?.toRequestJson(),
            location: _location,
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
          backgroundColor: AppColors.braweBlue,
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

  void _snack(String msg, {SnackBarAction? action}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(msg), action: action));
  }

  void _togglePoll() {
    if (_poll != null) {
      setState(() => _poll = null);
      return;
    }
    if (_selectedImage != null) {
      _snack(S.of(context).pollBlockedByImage);
      return;
    }
    setState(() => _poll = PollDraft());
  }

  Future<void> _toggleLocation() async {
    if (_location != null) {
      setState(() => _location = null);
      return;
    }
    if (_locating) return;
    setState(() => _locating = true);
    final service = ref.read(cityLocationServiceProvider);
    final result = await service.resolveCity();
    if (!mounted) return;
    setState(() {
      _locating = false;
      if (result.status == CityLocationStatus.ok) _location = result.location;
    });
    final s = S.of(context);
    switch (result.status) {
      case CityLocationStatus.ok:
        break;
      case CityLocationStatus.denied:
      case CityLocationStatus.deniedForever:
        _snack(
          s.postLocationDenied,
          action: SnackBarAction(
            label: s.postLocationOpenSettings,
            onPressed: service.openSettings,
          ),
        );
      case CityLocationStatus.serviceDisabled:
        _snack(s.postLocationServiceOff);
      case CityLocationStatus.failed:
        _snack(s.postLocationFailed);
    }
  }

  Future<void> _pickImage() async {
    if (_poll != null) {
      _snack(S.of(context).imageBlockedByPoll);
      return;
    }
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
      ref.read(soundPlayerViewModelProvider.notifier).stop();
      await _openTrimScreen(sound);
    }
  }

  /// Abre a tela de trim para o usuário escolher o trecho ESPECÍFICO
  /// deste post. Se cancelar, mantém/descarta a seleção anterior sem
  /// travar o fluxo — nunca deixa a música anexada sem um trim válido.
  Future<void> _openTrimScreen(Sound sound) async {
    final result = await SoundTrimScreen.push(
      context,
      sound: sound,
      maxDuration: _kMaxSoundTrim,
    );
    if (result != null && mounted) {
      setState(() {
        _selectedSound = sound;
        _soundTrimStartMs = result.trimStartMs;
        _soundTrimEndMs = result.trimEndMs;
      });
    } else if (_selectedSound == null) {
      // Cancelou sem ter uma música prévia selecionada — nada a fazer.
      return;
    }
  }

  /// Reabre a tela de trim para AJUSTAR o trecho de uma música já
  /// selecionada (tap no chip).
  Future<void> _editTrim() async {
    final sound = _selectedSound;
    if (sound == null) return;
    await _openTrimScreen(sound);
  }

  void _removeSound() {
    ref.read(soundPlayerViewModelProvider.notifier).stop();
    setState(() {
      _selectedSound = null;
      _soundTrimStartMs = 0;
      _soundTrimEndMs = null;
    });
  }

  String _audienceLabel(S s, String value) => switch (value) {
    'Seguidores' => s.audienceFollowers,
    'Apenas eu' => s.audienceOnlyMe,
    _ => s.audienceAll,
  };

  @override
  Widget build(BuildContext context) {
    final canPost =
        _textController.text.trim().isNotEmpty &&
        _charCount <= _maxChars &&
        (_poll == null || _poll!.isValid);
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
                  Builder(builder: (context) {
                    final avatar = ref.watch(authStateProvider).value?.avatarUrl;
                    final has = avatar != null && avatar.isNotEmpty;
                    return CircleAvatar(
                      radius: 18,
                      backgroundColor: context.colors.surfaceHighest,
                      backgroundImage: has ? NetworkImage(avatar) : null,
                      child: has
                          ? null
                          : Icon(LucideIcons.user, color: context.colors.textSecondary, size: 18),
                    );
                  }),
                  const SizedBox(width: 12),
                  // Audience selector
                  GestureDetector(
                    onTap: _showAudiencePicker,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: context.colors.accentPrimary.withValues(
                            alpha: 0.5,
                          ),
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _audienceLabel(s, _audience),
                            style: TextStyle(
                              color: context.colors.accentPrimary,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            LucideIcons.chevronDown,
                            color: context.colors.accentPrimary,
                            size: 14,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Spacer(),
                  // Botão padrão do app (FilledButton do tema): mesma cor e
                  // texto de todos os botões principais, nos dois temas.
                  FilledButton(
                    onPressed: canPost && !_isPosting ? _post : null,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(0, 36),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      shape: const StadiumBorder(),
                      backgroundColor: context.colors.accentPrimary,
                      foregroundColor: context.colors.textOnAccent,
                      disabledBackgroundColor: context.colors.surfaceHighest,
                      disabledForegroundColor: context.colors.textTertiary,
                    ),
                    child: _isPosting
                        ? SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              color: context.colors.textOnAccent,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            s.postPublish,
                            style: const TextStyle(fontWeight: FontWeight.w700),
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
                      cursorColor: context.colors.accentPrimary,
                      // Campo de escrever post, não de formulário: sem caixa,
                      // sem fundo e sem borda azul do tema global.
                      decoration: InputDecoration(
                        hintText: s.postHintWhatsHappening,
                        hintStyle: TextStyle(
                          color: context.colors.textTertiary,
                          fontSize: 16,
                        ),
                        filled: false,
                        isCollapsed: true,
                        contentPadding: const EdgeInsets.symmetric(vertical: 8),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        focusedErrorBorder: InputBorder.none,
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
                                child: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                    // Enquete: a pergunta é o texto do post (obrigatório).
                    if (_poll != null) ...[
                      PostPollEditor(
                        draft: _poll!,
                        onChanged: () => setState(() {}),
                        onRemove: () => setState(() => _poll = null),
                      ),
                      if (_textController.text.trim().isEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            s.pollNeedsQuestion,
                            style: TextStyle(
                              color: context.colors.danger,
                              fontSize: 12,
                            ),
                          ),
                        ),
                    ],

                    // Cidade do post (nunca coordenadas)
                    if (_location != null) ...[
                      const SizedBox(height: 10),
                      Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: PostLocationChip(
                          label: _location!.label,
                          onRemove: () => setState(() => _location = null),
                        ),
                      ),
                    ],

                    // Chip do som selecionado (tap = ajustar o trecho)
                    if (_selectedSound != null) ...[
                      const SizedBox(height: 10),
                      GestureDetector(
                        onTap: _editTrim,
                        child: _SelectedSoundChip(
                          sound: _selectedSound!,
                          onRemove: _removeSound,
                        ),
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
              // Android 15 edge-to-edge: o sheet (sem useSafeArea) desenha
              // atrás da barra de navegação — sem isso a barra de 3 botões
              // cobria a toolbar com o teclado fechado. `padding.bottom` já
              // vira 0 com o teclado aberto. iOS mantém o layout anterior.
              padding: EdgeInsets.fromLTRB(
                8,
                8,
                16,
                12 +
                    (Platform.isAndroid
                        ? MediaQuery.paddingOf(context).bottom
                        : 0),
              ),
              child: Row(
                children: [
                  _ToolbarBtn(
                    icon: LucideIcons.image,
                    onTap: _pickImage,
                    active: _selectedImage != null,
                  ),
                  _ToolbarBtn(icon: LucideIcons.hash, onTap: _insertHashtag),
                  _ToolbarBtn(
                    icon: LucideIcons.music,
                    onTap: _pickSound,
                    active: _selectedSound != null,
                    activeColor: const Color(0xFFE11D48),
                  ),
                  _ToolbarBtn(
                    icon: LucideIcons.chartBar,
                    tooltip: s.postAddPoll,
                    onTap: _togglePoll,
                    active: _poll != null,
                  ),
                  _ToolbarBtn(
                    icon: LucideIcons.mapPin,
                    tooltip: s.postAddLocation,
                    onTap: _toggleLocation,
                    active: _location != null,
                    busy: _locating,
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
                                ? context.colors.warning
                                : context.colors.accentPrimary,
                          ),
                          if (_charCount > _maxChars * 0.8)
                            Text(
                              '${_maxChars - _charCount}',
                              style: TextStyle(
                                color: _charCount > _maxChars
                                    ? context.colors.danger
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
                      ? context.colors.accentPrimary
                      : context.colors.textPrimary,
                ),
                title: Text(
                  _audienceLabel(S.of(context), option),
                  style: TextStyle(
                    color: _audience == option
                        ? context.colors.accentPrimary
                        : context.colors.textPrimary,
                    fontWeight: _audience == option
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
                trailing: _audience == option
                    ? Icon(Icons.check, color: context.colors.accentPrimary)
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
    this.tooltip,
    this.busy = false,
  });
  final IconData icon;
  final VoidCallback onTap;
  final bool active;
  final Color? activeColor;
  final String? tooltip;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final color = active
        ? (activeColor ?? context.colors.accentPrimary)
        : context.colors.textSecondary;
    return IconButton(
      tooltip: tooltip,
      icon: busy
          ? SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2, color: color),
            )
          : Icon(icon, color: color, size: 22),
      onPressed: busy ? null : onTap,
    );
  }
}

class _SelectedSoundChip extends StatelessWidget {
  const _SelectedSoundChip({required this.sound, required this.onRemove});
  final Sound sound;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: context.colors.surfaceElevated,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE11D48).withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Cover thumbnail
          if (sound.coverUrl != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Image.network(
                cacheWidth: context.decodePx(32),
                sound.coverUrl!,
                width: 32,
                height: 32,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => _fallbackIcon(),
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
                  sound.artist?.artistName ?? '',
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
