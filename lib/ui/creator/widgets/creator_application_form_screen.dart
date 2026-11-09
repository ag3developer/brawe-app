import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../data/repositories/creator_network_repository.dart';
import '../../../data/services/legal_assets_service.dart';
import '../../../domain/models/creator_network.dart';
import '../../../gen/l10n/app_localizations.dart';
import '../../core/themes/brawe_colors.dart';
import '../../core/widgets/country_picker.dart';
import '../../core/widgets/simple_markdown_view.dart';
import '../../settings/widgets/legal_webview_screen.dart';
import '../../../domain/models/failure.dart';
import '../utils/creator_l10n.dart';
import '../view_models/creator_applicant_provider.dart';
import '../view_models/creator_network_view_model.dart';

/// Redes aceitas para análise do perfil (valor = chave em `social_links`).
const kCreatorApplyPlatforms = <String, String>{
  'instagram': 'Instagram',
  'tiktok': 'TikTok',
  'youtube': 'YouTube',
  'twitch': 'Twitch',
  'twitter': 'X',
};

/// Usuário/@ de rede social: letras, números, ponto, hífen e sublinhado.
final _handleRe = RegExp(r'^[A-Za-z0-9._-]{2,50}$');

/// Remove espaços e o @ inicial digitado/colado.
String normalizeCreatorHandle(String raw) =>
    raw.trim().replaceFirst(RegExp(r'^@+'), '');

bool isValidCreatorHandle(String raw) =>
    _handleRe.hasMatch(normalizeCreatorHandle(raw));

const kCreatorMotivationMin = 20;

/// Inscrição na Creator Network em 3 etapas curtas. Tudo é obrigatório.
/// Nome, @, e-mail e foto vêm da conta logada e nunca são pedidos.
class CreatorApplicationFormScreen extends ConsumerStatefulWidget {
  const CreatorApplicationFormScreen({super.key});

  @override
  ConsumerState<CreatorApplicationFormScreen> createState() =>
      _CreatorApplicationFormScreenState();
}

class _CreatorApplicationFormScreenState
    extends ConsumerState<CreatorApplicationFormScreen> {
  static const _stepCount = 3;

  final _handle = TextEditingController();
  final _followers = TextEditingController();
  final _motivation = TextEditingController();

  int _step = 0;
  ContentNiche? _niche;
  String _platform = 'instagram';
  bool _doesLive = false;
  bool _acceptedTerms = false;
  bool _submitting = false;
  Country? _selectedCountry;

  String _language = 'pt';

  @override
  void initState() {
    super.initState();
    for (final c in [_handle, _followers, _motivation]) {
      c.addListener(_refresh);
    }
    // País pré-preenchido pela região do aparelho (pode trocar).
    _selectedCountry = findCountryByCode(
      WidgetsBinding.instance.platformDispatcher.locale.countryCode,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _language = Localizations.localeOf(context).languageCode;
      if (!{'pt', 'en', 'es'}.contains(_language)) _language = 'en';
      setState(() {});
    });
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    for (final c in [_handle, _followers, _motivation]) {
      c.dispose();
    }
    super.dispose();
  }

  int get _followersValue => int.tryParse(_followers.text.trim()) ?? 0;

  bool get _step0Valid => _niche != null && _selectedCountry != null;
  bool get _step1Valid =>
      isValidCreatorHandle(_handle.text) && _followersValue >= 1;
  bool get _step2Valid =>
      _motivation.text.trim().length >= kCreatorMotivationMin && _acceptedTerms;

  bool get _currentStepValid => switch (_step) {
    0 => _step0Valid,
    1 => _step1Valid,
    _ => _step2Valid,
  };

  bool get _allValid => _step0Valid && _step1Valid && _step2Valid;

  /// A inscrição pode ter sido gravada mesmo que a resposta tenha falhado
  /// (timeout, queda de rede após o servidor salvar). Confere no servidor.
  Future<bool> _savedOnServer() async {
    try {
      final a = await ref
          .read(creatorNetworkRepositoryProvider)
          .getMyApplication();
      if (a == null) return false;
      final recent =
          DateTime.now().difference(a.createdAt).inMinutes.abs() < 15;
      return recent && a.status == ApplicationStatus.pendingReview;
    } catch (_) {
      return false;
    }
  }

  void _goSubmitted() {
    ref.invalidate(myCreatorApplicationProvider);
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(S.of(context).creatorFormSuccess)));
    context.go('/creator/submitted');
  }

  Future<void> _submit() async {
    // Evita duplo envio (toque duplo antes do rebuild).
    if (_submitting || !_allValid) return;
    FocusScope.of(context).unfocus();
    setState(() => _submitting = true);
    try {
      // Versão dos Termos vigente (cacheada). Se falhar, o backend usa a default.
      final termsVersion = await ref.read(creatorTermsVersionProvider.future);
      await ref
          .read(creatorApplicationFormControllerProvider.notifier)
          .submit(
            country: _selectedCountry!.code,
            language: _language,
            niche: _niche!,
            platform: _platform,
            handle: normalizeCreatorHandle(_handle.text),
            followersCount: _followersValue,
            doesLive: _doesLive,
            motivation: _motivation.text.trim(),
            termsAccepted: _acceptedTerms,
            termsVersion: termsVersion,
          );
      _goSubmitted();
    } catch (e) {
      if (!mounted) return;
      final s = S.of(context);
      final msg = _errorMessage(s, e);
      if (msg == null) {
        // 409: já existe inscrição ativa -> leva para o acompanhamento.
        ref.invalidate(myCreatorApplicationProvider);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(s.creatorFormAlreadyExists)));
        context.go('/creator/status');
      } else if (!_isRejection(e) && await _savedOnServer()) {
        // O servidor guardou a inscrição; só a resposta se perdeu.
        _goSubmitted();
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg), duration: const Duration(seconds: 5)),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  /// Recusa explícita do servidor (422/401): não há o que conferir.
  bool _isRejection(Object e) =>
      e is Failure &&
      e.map(
        network: (_) => false,
        server: (_) => false,
        unauthorized: (_) => true,
        unknown: (_) => false,
        validation: (_) => true,
      );

  /// Converte o erro do repositório em mensagem traduzida.
  /// Retorna null quando a inscrição já existe (409).
  String? _errorMessage(S s, Object e) {
    if (e is! Failure) return s.creatorFormError;
    return e.map(
      network: (_) => s.creatorApplyErrNetwork,
      server: (_) => s.creatorApplyErrServer,
      unauthorized: (_) => s.creatorApplyErrSession,
      unknown: (_) => s.creatorFormError,
      validation: (v) {
        final m = v.message ?? '';
        if (m.contains('creator_application_already_active')) return null;
        // 422 do Pydantic: "loc: [body, campo]" -> nomes dos campos com erro.
        final fields = RegExp(
          r'loc:\s*\[body,\s*(?:social_links,\s*)?([a-z_]+)',
        ).allMatches(m).map((x) => _fieldLabel(s, x.group(1)!)).toSet();
        if (fields.isNotEmpty) {
          return s.creatorApplyErrFields(fields.join(', '));
        }
        return s.creatorFormError;
      },
    );
  }

  String _fieldLabel(S s, String key) {
    switch (key) {
      case 'country':
        return s.creatorFormCountry;
      case 'followers_count':
        return s.creatorFormFollowers;
      case 'motivation':
        return s.creatorFormMotivation;
      case 'social_links':
        return s.creatorApplyHandleLabel;
      case 'terms_accepted':
        return s.creatorFormTermsLink;
      case 'niche':
        return s.creatorApplyTypeTitle;
      default:
        return key;
    }
  }

  Future<void> _openTerms() async {
    final service = ref.read(legalAssetsServiceProvider);
    final md = await service.loadCreatorTerms(_language);
    // Versão vigente (best-effort) para mostrar no rodapé do sheet.
    final version = await ref.read(creatorTermsVersionProvider.future);
    if (!mounted) return;
    final s = S.of(context);
    await showModalBottomSheet(
      useRootNavigator: true,
      useSafeArea: true,
      context: context,
      isScrollControlled: true,
      backgroundColor: context.colors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => SizedBox(
        height: MediaQuery.of(sheetContext).size.height * 0.92,
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: context.colors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Título + versão
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      s.creatorFormTermsLink,
                      style: TextStyle(
                        color: context.colors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  if (version != null && version.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: context.colors.surfaceElevated,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        s.creatorFormTermsVersion(version),
                        style: TextStyle(
                          color: context.colors.textSecondary,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(child: SimpleMarkdownView(markdown: md)),
            Padding(
              padding: EdgeInsets.fromLTRB(
                16,
                8,
                16,
                MediaQuery.of(sheetContext).padding.bottom + 12,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(sheetContext).pop(),
                      child: Text(s.creatorFormTermsClose),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      icon: const Icon(LucideIcons.check, size: 18),
                      label: Text(s.creatorApplyAcceptButton),
                      onPressed: () {
                        Navigator.of(sheetContext).pop();
                        if (mounted) {
                          setState(() {
                            _acceptedTerms = true;
                          });
                        }
                      },
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

  void _openUse(bool privacy) =>
      LegalWebViewScreen.openLegal(context, privacy: privacy);

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final c = context.colors;
    final last = _step == _stepCount - 1;
    return PopScope(
      canPop: !_submitting,
      child: Scaffold(
        backgroundColor: c.background,
        appBar: AppBar(
          backgroundColor: c.background,
          elevation: 0,
          scrolledUnderElevation: 0,
          title: Text(s.creatorFormTitle),
          leading: IconButton(
            icon: const Icon(LucideIcons.chevronLeft),
            onPressed: _submitting
                ? null
                : () {
                    if (_step > 0) {
                      setState(() => _step--);
                    } else {
                      context.pop();
                    }
                  },
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                children: [
                  _accountHeader(s),
                  const SizedBox(height: 14),
                  _progress(s),
                  const SizedBox(height: 18),
                  if (_step == 0) ..._stepContent(s),
                  if (_step == 1) ..._stepNetwork(s),
                  if (_step == 2) ..._stepAbout(s),
                ],
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: Row(
                  children: [
                    if (_step > 0) ...[
                      Expanded(
                        flex: 2,
                        child: OutlinedButton(
                          onPressed: _submitting
                              ? null
                              : () => setState(() => _step--),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size.fromHeight(52),
                          ),
                          child: Text(s.creatorApplyBack),
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                    Expanded(
                      flex: 3,
                      child: FilledButton.icon(
                        icon: _submitting
                            ? SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: c.textOnAccent,
                                ),
                              )
                            : Icon(
                                last
                                    ? LucideIcons.send
                                    : LucideIcons.arrowRight,
                                size: 18,
                              ),
                        label: Text(
                          _submitting
                              ? s.creatorFormSubmitting
                              : last
                              ? s.creatorFormSubmit
                              : s.creatorApplyNext,
                        ),
                        onPressed: _submitting || !_currentStepValid
                            ? null
                            : last
                            ? _submit
                            : () => setState(() => _step++),
                        style: FilledButton.styleFrom(
                          minimumSize: const Size.fromHeight(52),
                          backgroundColor: c.accentPrimary,
                          foregroundColor: c.textOnAccent,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Conta logada: mostrada, nunca pedida.
  Widget _accountHeader(S s) {
    final c = context.colors;
    final me = ref.watch(creatorApplicantProvider).value;
    final name = me?.name ?? '';
    final user = (me?.username ?? '').isNotEmpty ? '@${me!.username}' : '';
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: c.border),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: c.surfaceElevated,
            backgroundImage: (me?.avatarUrl ?? '').isNotEmpty
                ? NetworkImage(me!.avatarUrl!)
                : null,
            child: (me?.avatarUrl ?? '').isEmpty
                ? Icon(LucideIcons.user, color: c.textSecondary)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  [name, user].where((e) => e.isNotEmpty).join('  '),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: c.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 14.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  s.creatorApplyAsAccount,
                  style: TextStyle(color: c.textSecondary, fontSize: 12.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _progress(S s) {
    final c = context.colors;
    final titles = [
      s.creatorApplyStepContent,
      s.creatorApplyStepNetwork,
      s.creatorApplyStepAbout,
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            for (var i = 0; i < _stepCount; i++) ...[
              Expanded(
                child: Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: i <= _step ? c.accentPrimary : c.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              if (i < _stepCount - 1) const SizedBox(width: 6),
            ],
          ],
        ),
        const SizedBox(height: 10),
        Text(
          '${s.creatorApplyStepOf(_step + 1, _stepCount)} · ${titles[_step]}',
          style: TextStyle(
            color: c.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  List<Widget> _stepContent(S s) {
    final c = context.colors;
    return [
      Text(
        s.creatorApplyTypeHint,
        style: TextStyle(color: c.textSecondary, fontSize: 13),
      ),
      const SizedBox(height: 12),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [for (final n in ContentNiche.values) _nicheChip(s, n)],
      ),
      const SizedBox(height: 20),
      _countryField(s),
    ];
  }

  List<Widget> _stepNetwork(S s) {
    final c = context.colors;
    return [
      Text(
        s.creatorApplyHandleWhy,
        style: TextStyle(color: c.textSecondary, fontSize: 13, height: 1.4),
      ),
      const SizedBox(height: 12),
      Text(
        s.creatorApplyPlatformLabel,
        style: TextStyle(
          color: c.textPrimary,
          fontWeight: FontWeight.w700,
          fontSize: 14,
        ),
      ),
      const SizedBox(height: 8),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final e in kCreatorApplyPlatforms.entries)
            ChoiceChip(
              key: ValueKey('platform_${e.key}'),
              selected: _platform == e.key,
              showCheckmark: false,
              label: Text(e.value),
              labelStyle: TextStyle(
                color: _platform == e.key ? c.textOnAccent : c.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
              selectedColor: c.accentPrimary,
              backgroundColor: c.surface,
              side: BorderSide(
                color: _platform == e.key ? c.accentPrimary : c.border,
              ),
              onSelected: (_) => setState(() => _platform = e.key),
            ),
        ],
      ),
      const SizedBox(height: 16),
      _field(
        _handle,
        s.creatorApplyHandleLabel,
        fieldKey: const ValueKey('field_handle'),
        prefix: '@',
        hint: s.creatorApplyInstagramHint,
        maxLength: 60,
        validate: (v) =>
            isValidCreatorHandle(v) ? null : s.creatorApplyErrHandle,
      ),
      _field(
        _followers,
        s.creatorFormFollowers,
        fieldKey: const ValueKey('field_followers'),
        keyboard: TextInputType.number,
        maxLength: 10,
        formatters: [FilteringTextInputFormatter.digitsOnly],
        action: TextInputAction.done,
        validate: (v) =>
            (int.tryParse(v) ?? 0) >= 1 ? null : s.creatorApplyErrFollowersMin,
      ),
      SwitchListTile(
        contentPadding: EdgeInsets.zero,
        value: _doesLive,
        onChanged: _submitting ? null : (v) => setState(() => _doesLive = v),
        title: Text(
          s.creatorFormDoesLive,
          style: TextStyle(color: c.textPrimary, fontSize: 14.5),
        ),
        activeThumbColor: c.accentPrimary,
      ),
    ];
  }

  List<Widget> _stepAbout(S s) {
    return [
      _field(
        _motivation,
        s.creatorFormMotivation,
        fieldKey: const ValueKey('field_motivation'),
        hint: s.creatorFormMotivationPlaceholder,
        lines: 5,
        maxLength: 1000,
        capitalization: TextCapitalization.sentences,
        validate: (v) => v.length >= kCreatorMotivationMin
            ? null
            : s.creatorApplyErrMotivation(kCreatorMotivationMin),
      ),
      const SizedBox(height: 4),
      _termsBox(s),
    ];
  }

  Widget _nicheChip(S s, ContentNiche n) {
    final c = context.colors;
    final sel = _niche == n;
    return ChoiceChip(
      key: ValueKey('niche_${n.name}'),
      selected: sel,
      showCheckmark: false,
      avatar: Icon(
        n.lucide,
        size: 16,
        color: sel ? c.textOnAccent : c.textSecondary,
      ),
      label: Text(n.label(s)),
      labelStyle: TextStyle(
        color: sel ? c.textOnAccent : c.textPrimary,
        fontWeight: FontWeight.w600,
        fontSize: 13,
      ),
      selectedColor: c.accentPrimary,
      backgroundColor: c.surface,
      side: BorderSide(color: sel ? c.accentPrimary : c.border),
      onSelected: (_) => setState(() => _niche = n),
    );
  }

  /// Aceite dos termos (obrigatório): checkbox + links para Termos do Creator
  /// (markdown em sheet), Termos de Uso e Privacidade (LegalWebViewScreen).
  Widget _termsBox(S s) {
    final c = context.colors;
    TextSpan link(String text, VoidCallback onTap) => TextSpan(
      text: text,
      style: TextStyle(
        color: c.accentPrimary,
        fontWeight: FontWeight.w700,
        decoration: TextDecoration.underline,
      ),
      recognizer: TapGestureRecognizer()..onTap = onTap,
    );
    final borderColor = _acceptedTerms
        ? c.accentPrimary.withValues(alpha: 0.5)
        : c.border;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(4, 8, 12, 8),
          decoration: BoxDecoration(
            color: c.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: borderColor, width: 1),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Checkbox(
                value: _acceptedTerms,
                onChanged: _submitting
                    ? null
                    : (v) => setState(() {
                        _acceptedTerms = v ?? false;
                      }),
                activeColor: c.accentPrimary,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text.rich(
                    TextSpan(
                      style: TextStyle(
                        color: c.textPrimary,
                        fontSize: 13.5,
                        height: 1.45,
                      ),
                      children: [
                        TextSpan(text: s.creatorFormTermsPrefix),
                        link(s.creatorFormTermsLink, _openTerms),
                        const TextSpan(text: ', '),
                        link(s.creatorApplyTermsUse, () => _openUse(false)),
                        TextSpan(text: s.creatorApplyTermsAnd),
                        link(s.settingsPrivacyPolicy, () => _openUse(true)),
                        TextSpan(text: s.creatorFormTermsSuffix),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// País (bandeira + nome + ISO). Pré-preenchido pela região do aparelho.
  Widget _countryField(S s) {
    final c = context.colors;
    return InkWell(
      key: const ValueKey('field_country'),
      borderRadius: BorderRadius.circular(12),
      onTap: _submitting
          ? null
          : () async {
              final picked = await showCountryPicker(
                context,
                selectedCode: _selectedCountry?.code,
                title: s.creatorFormCountry,
              );
              if (picked != null) setState(() => _selectedCountry = picked);
            },
      child: InputDecorator(
        decoration: _decoration(s.creatorFormCountry).copyWith(
          suffixIcon: Icon(
            LucideIcons.chevronDown,
            size: 18,
            color: c.textSecondary,
          ),
        ),
        child: _selectedCountry != null
            ? Row(
                children: [
                  Text(
                    _selectedCountry!.flag,
                    style: const TextStyle(fontSize: 22),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '${_selectedCountry!.name} (${_selectedCountry!.code})',
                      style: TextStyle(color: c.textPrimary, fontSize: 15),
                    ),
                  ),
                ],
              )
            : const SizedBox(height: 22),
      ),
    );
  }

  Widget _field(
    TextEditingController ctrl,
    String label, {
    Key? fieldKey,
    String? hint,
    String? prefix,
    int lines = 1,
    int? maxLength,
    TextInputType? keyboard,
    TextInputAction? action,
    TextCapitalization capitalization = TextCapitalization.none,
    List<TextInputFormatter>? formatters,
    required String? Function(String value) validate,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        key: fieldKey,
        controller: ctrl,
        enabled: !_submitting,
        decoration: _decoration(
          label,
          hint: hint,
        ).copyWith(prefixText: prefix, counterText: lines > 1 ? null : ''),
        style: TextStyle(color: context.colors.textPrimary),
        minLines: lines,
        maxLines: lines,
        maxLength: maxLength,
        keyboardType: lines > 1 ? TextInputType.multiline : keyboard,
        textInputAction:
            action ??
            (lines > 1 ? TextInputAction.newline : TextInputAction.next),
        textCapitalization: capitalization,
        inputFormatters: formatters,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        validator: (v) {
          final t = (v ?? '').trim();
          if (t.isEmpty) return S.of(context).creatorFormValidationRequired;
          return validate(t);
        },
      ),
    );
  }

  InputDecoration _decoration(String label, {String? hint}) {
    final c = context.colors;
    OutlineInputBorder b(Color color, [double w = 1]) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: color, width: w),
    );
    return InputDecoration(
      labelText: label,
      hintText: hint,
      filled: true,
      fillColor: c.surface,
      labelStyle: TextStyle(color: c.textSecondary),
      hintStyle: TextStyle(color: c.textTertiary),
      enabledBorder: b(c.border),
      disabledBorder: b(c.border),
      focusedBorder: b(c.accentPrimary, 1.5),
      errorBorder: b(c.danger),
      focusedErrorBorder: b(c.danger, 1.5),
    );
  }
}
