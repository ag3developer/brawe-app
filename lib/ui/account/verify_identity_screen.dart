// Verificar identidade: 1) documento (CNH Digital do dia no Brasil, passaporte nos demais países)
// 2) prova de vida (vídeo curto falando nome, data, hora e código mostrados) 3) consentimento e envio.

import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../data/repositories/kyc_repository.dart';
import '../../gen/l10n/app_localizations.dart';
import '../core/themes/brawe_colors.dart';
import '../core/ui/grouped_list.dart';
import '../core/widgets/country_picker.dart';

class VerifyIdentityScreen extends ConsumerStatefulWidget {
  const VerifyIdentityScreen({super.key});

  @override
  ConsumerState<VerifyIdentityScreen> createState() =>
      _VerifyIdentityScreenState();
}

class _VerifyIdentityScreenState extends ConsumerState<VerifyIdentityScreen> {
  int _step = 0;
  late String _country =
      Localizations.localeOf(context).countryCode?.toUpperCase() == 'BR' ||
          Localizations.localeOf(context).languageCode == 'pt'
      ? 'BR'
      : '';
  String _docType = 'cnh_digital';
  String? _docPath;
  String? _docName;
  KycChallenge? _challenge;
  String? _videoPath;
  bool _consent = false;
  bool _sending = false;
  double _progress = 0;
  bool _done = false;

  bool get _isBr => _country == 'BR';

  void _snack(String m) => ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(m), behavior: SnackBarBehavior.floating),
  );

  Future<void> _pickCountry() async {
    final s = S.of(context);
    final c = await showCountryPicker(
      context,
      selectedCode: _country,
      title: s.kycCountry,
      searchHint: s.kycCountrySearch,
    );
    if (c == null) return;
    setState(() {
      _country = c.code;
      _docType = c.code == 'BR' ? _docType : 'passport';
      _docPath = null;
      _docName = null;
    });
  }

  Future<void> _pickDocument({bool camera = false}) async {
    if (camera) {
      final x = await ImagePicker().pickImage(
        source: ImageSource.camera,
        imageQuality: 92,
        maxWidth: 2400,
      );
      if (x == null) return;
      setState(() {
        _docPath = x.path;
        _docName = x.name;
      });
      return;
    }
    final res = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: _docType == 'cnh_digital'
          ? const ['pdf']
          : const ['pdf', 'jpg', 'jpeg', 'png'],
    );
    final f = res?.files.single;
    if (f?.path == null) return;
    setState(() {
      _docPath = f!.path;
      _docName = f.name;
    });
  }

  Future<void> _recordVideo() async {
    final s = S.of(context);
    try {
      final ch = await ref.read(kycRepositoryProvider).challenge();
      if (!mounted) return;
      final path = await Navigator.of(context, rootNavigator: true)
          .push<String>(
            MaterialPageRoute(
              fullscreenDialog: true,
              builder: (_) => _LivenessCamera(challenge: ch),
            ),
          );
      if (path == null || !mounted) return;
      setState(() {
        _challenge = ch;
        _videoPath = path;
      });
    } on KycFailure catch (e) {
      _snack(e.message.isNotEmpty ? e.message : s.kycError);
    } catch (_) {
      _snack(s.kycError);
    }
  }

  Future<void> _submit() async {
    final s = S.of(context);
    setState(() {
      _sending = true;
      _progress = 0;
    });
    try {
      await ref
          .read(kycRepositoryProvider)
          .submitIdentity(
            country: _country,
            docType: _docType,
            challengeToken: _challenge!.token,
            documentPath: _docPath!,
            videoPath: _videoPath!,
            onProgress: (p) => mounted ? setState(() => _progress = p) : null,
          );
      ref.invalidate(kycStatusProvider);
      if (!mounted) return;
      HapticFeedback.heavyImpact();
      setState(() => _done = true);
    } on KycFailure catch (e) {
      if (!mounted) return;
      _snack(e.message.isNotEmpty ? e.message : s.kycError);
      // desafio vencido ou CNH de outro dia: volta ao passo certo
      if (e.code == 'challenge_expired' || e.code == 'challenge_invalid')
        setState(() => _step = 1);
      if (e.code == 'cnh_not_today' || e.field == 'document')
        setState(() => _step = 0);
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  bool get _stepValid => switch (_step) {
    0 => _country.isNotEmpty && _docPath != null,
    1 => _videoPath != null,
    _ => _consent && !_sending,
  };

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final colors = context.colors;
    final steps = [s.kycStepDocument, s.kycStepLiveness, s.kycStepSend];
    return PopScope(
      canPop: _step == 0 || _done,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && !_sending) setState(() => _step--);
      },
      child: Scaffold(
        backgroundColor: colors.background,
        appBar: AppBar(
          title: Text(_done ? '' : s.kycIdentityRow),
          centerTitle: true,
          backgroundColor: colors.background,
          surfaceTintColor: Colors.transparent,
          bottom: _done
              ? null
              : PreferredSize(
                  preferredSize: const Size.fromHeight(30),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                    child: Row(
                      children: [
                        for (var i = 0; i < steps.length; i++) ...[
                          if (i > 0) const SizedBox(width: 6),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 220),
                                  height: 3,
                                  decoration: BoxDecoration(
                                    color: i <= _step
                                        ? colors.accentPrimary
                                        : colors.surfaceHighest,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  steps[i],
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: i == _step
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                    color: i <= _step
                                        ? colors.textPrimary
                                        : colors.textTertiary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
        ),
        body: _done
            ? _doneView(context)
            : GroupedBody(children: [_stepBody(context)]),
        bottomNavigationBar: _done
            ? null
            : SafeArea(
                top: false,
                child: Align(
                  heightFactor: 1,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 640),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                      child: SizedBox(
                        height: 52,
                        width: double.infinity,
                        child: FilledButton(
                          style: FilledButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          onPressed: _stepValid
                              ? (_step < 2
                                    ? () => setState(() => _step++)
                                    : _submit)
                              : null,
                          child: _sending
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.2,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Text('${(_progress * 100).round()}%'),
                                  ],
                                )
                              : Text(
                                  _step < 2 ? s.boostNext : s.kycSubmit,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  Widget _stepBody(BuildContext context) {
    final s = S.of(context);
    final colors = context.colors;
    final country = findCountryByCode(_country);
    switch (_step) {
      case 0:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GroupedSection(
              caption: s.kycCountry,
              children: [
                GroupedRow(
                  icon: LucideIcons.globe,
                  title: country == null
                      ? s.kycCountryChoose
                      : '${country.flag}  ${country.name}',
                  onTap: _pickCountry,
                ),
              ],
            ),
            if (_country.isNotEmpty)
              GroupedSection(
                caption: s.kycDocument,
                children: [
                  if (_isBr)
                    GroupedRow(
                      icon: LucideIcons.idCard,
                      title: s.kycDocCnh,
                      subtitle: s.kycDocCnhHint,
                      onTap: () => setState(() {
                        _docType = 'cnh_digital';
                        _docPath = null;
                      }),
                      trailing: _radio(_docType == 'cnh_digital'),
                    ),
                  GroupedRow(
                    icon: LucideIcons.bookOpen,
                    title: s.kycDocPassport,
                    subtitle: s.kycDocPassportHint,
                    onTap: () => setState(() {
                      _docType = 'passport';
                      _docPath = null;
                    }),
                    trailing: _radio(_docType == 'passport'),
                  ),
                ],
              ),
            if (_country.isNotEmpty)
              GroupedSection(
                footer: _docType == 'cnh_digital'
                    ? s.kycCnhHowTo
                    : s.kycPassportHowTo,
                children: [
                  GroupedRow(
                    icon: _docPath == null
                        ? LucideIcons.upload
                        : LucideIcons.fileCheck,
                    title: _docPath == null ? s.kycPickFile : (_docName ?? ''),
                    subtitle: _docPath == null ? null : s.kycChangeFile,
                    onTap: () => _pickDocument(),
                    trailing: _docPath == null
                        ? null
                        : Icon(
                            LucideIcons.check,
                            color: colors.success,
                            size: 20,
                          ),
                  ),
                  if (_docType == 'passport')
                    GroupedRow(
                      icon: LucideIcons.camera,
                      title: s.kycTakePhoto,
                      onTap: () => _pickDocument(camera: true),
                    ),
                ],
              ),
          ],
        );
      case 1:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 4, 4, 18),
              child: Text(
                s.kycLivenessIntro,
                style: TextStyle(
                  color: colors.textSecondary,
                  fontSize: 14.5,
                  height: 1.45,
                ),
              ),
            ),
            GroupedSection(
              children: [
                _Tip(icon: LucideIcons.sun, text: s.kycTipLight),
                _Tip(icon: LucideIcons.glasses, text: s.kycTipFace),
                _Tip(icon: LucideIcons.rotateCw, text: s.kycTipTurn),
                _Tip(icon: LucideIcons.mic, text: s.kycTipSpeak),
              ],
            ),
            GroupedSection(
              children: [
                GroupedRow(
                  icon: _videoPath == null
                      ? LucideIcons.video
                      : LucideIcons.circleCheck,
                  title: _videoPath == null ? s.kycRecord : s.kycRecorded,
                  subtitle: _videoPath == null ? null : s.kycRecordAgain,
                  onTap: _recordVideo,
                  trailing: _videoPath == null
                      ? null
                      : Icon(
                          LucideIcons.check,
                          color: colors.success,
                          size: 20,
                        ),
                ),
              ],
            ),
          ],
        );
      default:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GroupedSection(
              caption: s.kycReview,
              children: [
                GroupedRow(
                  icon: LucideIcons.globe,
                  title: country == null
                      ? _country
                      : '${country.flag}  ${country.name}',
                ),
                GroupedRow(
                  icon: LucideIcons.idCard,
                  title: _docType == 'cnh_digital'
                      ? s.kycDocCnh
                      : s.kycDocPassport,
                  subtitle: _docName,
                ),
                GroupedRow(icon: LucideIcons.video, title: s.kycRecorded),
              ],
            ),
            GroupedSection(
              children: [
                InkWell(
                  onTap: () => setState(() => _consent = !_consent),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Checkbox.adaptive(
                          value: _consent,
                          onChanged: (v) =>
                              setState(() => _consent = v ?? false),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Text(
                              s.kycConsent,
                              style: TextStyle(
                                color: colors.textPrimary,
                                fontSize: 14,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Text(
                s.kycPrivacy,
                style: TextStyle(
                  color: colors.textTertiary,
                  fontSize: 12.5,
                  height: 1.4,
                ),
              ),
            ),
          ],
        );
    }
  }

  Widget _radio(bool on) {
    final colors = context.colors;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: on ? colors.accentPrimary : Colors.transparent,
        border: Border.all(
          color: on ? colors.accentPrimary : colors.border,
          width: 2,
        ),
      ),
      child: on
          ? Icon(LucideIcons.check, size: 13, color: colors.textOnAccent)
          : null,
    );
  }

  Widget _doneView(BuildContext context) {
    final s = S.of(context);
    final colors = context.colors;
    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  LucideIcons.hourglass,
                  size: 56,
                  color: colors.accentPrimary,
                ),
                const SizedBox(height: 20),
                Text(
                  s.kycSentTitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  s.kycSentBody,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: colors.textSecondary,
                    fontSize: 15,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  height: 50,
                  width: double.infinity,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () => context.pop(),
                    child: Text(
                      s.boostFinish,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15.5,
                      ),
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
}

class _Tip extends StatelessWidget {
  const _Tip({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => GroupedRow(icon: icon, title: text);
}

/// Câmera frontal: grava até 12 s com o texto que a pessoa fala e o guia de movimento.
class _LivenessCamera extends StatefulWidget {
  const _LivenessCamera({required this.challenge});
  final KycChallenge challenge;

  @override
  State<_LivenessCamera> createState() => _LivenessCameraState();
}

class _LivenessCameraState extends State<_LivenessCamera> {
  static const _max = Duration(seconds: 12);
  static const _min = Duration(seconds: 5);

  CameraController? _ctrl;
  bool _recording = false;
  Duration _elapsed = Duration.zero;
  Timer? _timer;
  String? _error;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    try {
      final cams = await availableCameras();
      final front = cams.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
        orElse: () => cams.first,
      );
      final c = CameraController(
        front,
        ResolutionPreset.medium,
        enableAudio: true,
      );
      await c.initialize();
      if (!mounted) {
        await c.dispose();
        return;
      }
      setState(() => _ctrl = c);
    } catch (e) {
      if (mounted) setState(() => _error = '$e');
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _ctrl?.dispose();
    super.dispose();
  }

  Future<void> _start() async {
    final c = _ctrl;
    if (c == null || _recording) return;
    await c.startVideoRecording();
    HapticFeedback.mediumImpact();
    setState(() {
      _recording = true;
      _elapsed = Duration.zero;
    });
    _timer = Timer.periodic(const Duration(milliseconds: 100), (t) {
      setState(() => _elapsed += const Duration(milliseconds: 100));
      if (_elapsed >= _max) _stop();
    });
  }

  Future<void> _stop() async {
    final c = _ctrl;
    if (c == null || !_recording) return;
    _timer?.cancel();
    final f = await c.stopVideoRecording();
    HapticFeedback.mediumImpact();
    if (!mounted) return;
    setState(() => _recording = false);
    if (_elapsed < _min) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(S.of(context).kycTooShort)));
      try {
        File(f.path).deleteSync();
      } catch (_) {}
      return;
    }
    Navigator.of(context).pop(f.path);
  }

  /// O que fazer agora (muda com o tempo da gravação).
  String _hint(S s) {
    if (!_recording) return s.kycCamReady;
    final t = _elapsed.inMilliseconds;
    if (t < 2500) return s.kycCamLook;
    if (t < 5000) return s.kycCamLeft;
    if (t < 7500) return s.kycCamRight;
    return s.kycCamSpeak;
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final ch = widget.challenge;
    final c = _ctrl;
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (c != null && c.value.isInitialized)
            FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: c.value.previewSize!.height,
                height: c.value.previewSize!.width,
                child: CameraPreview(c),
              ),
            )
          else
            Center(
              child: _error == null
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        s.kycCamError,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
            ),
          // moldura do rosto
          IgnorePointer(
            child: Center(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: 250,
                height: 330,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(
                    Radius.elliptical(125, 165),
                  ),
                  border: Border.all(
                    color: _recording
                        ? const Color(0xFF22C55E)
                        : Colors.white70,
                    width: 3,
                  ),
                ),
              ),
            ),
          ),
          // topo: fechar + tempo
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(LucideIcons.x, color: Colors.white),
                    onPressed: _recording
                        ? null
                        : () => Navigator.of(context).pop(),
                  ),
                  const Spacer(),
                  if (_recording)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE11D48),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        '0:${_elapsed.inSeconds.toString().padLeft(2, '0')}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  const SizedBox(width: 12),
                ],
              ),
            ),
          ),
          // base: texto para falar + dica + botão
          Positioned(
            left: 16,
            right: 16,
            bottom: 0,
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.62),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Text(
                          s.kycSay,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          s.kycScript(ch.name, ch.date, ch.time, ch.code),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: Text(
                      _hint(s),
                      key: ValueKey(_hint(s)),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  GestureDetector(
                    onTap: _recording ? _stop : _start,
                    child: Container(
                      width: 76,
                      height: 76,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 4),
                      ),
                      padding: const EdgeInsets.all(6),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE11D48),
                          borderRadius: BorderRadius.circular(
                            _recording ? 8 : 40,
                          ),
                        ),
                        margin: EdgeInsets.all(_recording ? 14 : 0),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
