import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../data/services/legal_assets_service.dart';
import '../../../domain/models/creator_network.dart';
import '../../../gen/l10n/app_localizations.dart';
import '../../core/themes/brawe_colors.dart';
import '../../core/widgets/country_picker.dart';
import '../../core/widgets/simple_markdown_view.dart';
import '../../settings/widgets/legal_webview_screen.dart';
import '../../../domain/models/failure.dart';
import '../utils/creator_l10n.dart';
import '../view_models/creator_network_view_model.dart';
import '../widgets/creator_tier_card.dart';

class CreatorApplicationFormScreen extends ConsumerStatefulWidget {
  const CreatorApplicationFormScreen({super.key});

  @override
  ConsumerState<CreatorApplicationFormScreen> createState() =>
      _CreatorApplicationFormScreenState();
}

class _CreatorApplicationFormScreenState
    extends ConsumerState<CreatorApplicationFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final _fullName = TextEditingController();
  final _username = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _city = TextEditingController();
  final _instagram = TextEditingController();
  final _tiktok = TextEditingController();
  final _youtube = TextEditingController();
  final _followers = TextEditingController(text: '0');
  final _bio = TextEditingController();
  final _motivation = TextEditingController();
  final _goals = TextEditingController();
  final _portfolio = TextEditingController();

  ContentNiche _niche = ContentNiche.lifestyle;
  CreatorTier? _requestedTier;
  bool _doesLive = false;
  bool _acceptedTerms = false;
  bool _submitting = false;
  bool _termsError = false;
  Country? _selectedCountry;

  String _language = 'pt';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _language = Localizations.localeOf(context).languageCode;
      if (!{'pt', 'en', 'es'}.contains(_language)) _language = 'en';
      setState(() {});
    });
  }

  @override
  void dispose() {
    for (final c in [
      _fullName, _username, _email, _phone, _city,
      _instagram, _tiktok, _youtube, _followers, _bio, _motivation,
      _goals, _portfolio
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  /// Normaliza o link do portfólio: sem esquema vira https://.
  String? _normalizeUrl(String raw) {
    final t = raw.trim();
    if (t.isEmpty) return null;
    return RegExp(r'^https?://', caseSensitive: false).hasMatch(t)
        ? t
        : 'https://$t';
  }

  Future<void> _submit() async {
    // Evita duplo envio (toque duplo antes do rebuild).
    if (_submitting) return;
    FocusScope.of(context).unfocus();
    final formOk = _formKey.currentState!.validate();
    final termsOk = _acceptedTerms;
    setState(() => _termsError = !termsOk);
    if (!formOk || !termsOk) {
      if (!termsOk && formOk) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(S.of(context).creatorFormTermsMustAccept)),
        );
      }
      return;
    }
    setState(() => _submitting = true);
    try {
      // Versão dos Termos vigente (cacheada). Se falhar, o backend usa a default.
      final termsVersion = await ref.read(creatorTermsVersionProvider.future);
      await ref.read(creatorApplicationFormControllerProvider.notifier).submit(
            fullName: _fullName.text.trim(),
            username: _username.text.trim().replaceFirst(RegExp(r'^@+'), ''),
            email: _email.text.trim(),
            phone: _phone.text.trim().isEmpty ? null : _phone.text.trim(),
            country: _selectedCountry!.code,
            city: _city.text.trim().isEmpty ? null : _city.text.trim(),
            language: _language,
            niche: _niche,
            requestedTier: _requestedTier,
            socialLinks: SocialLinks(
              instagram: _instagram.text.trim(),
              tiktok: _tiktok.text.trim(),
              youtube: _youtube.text.trim(),
            ),
            followersCount: int.tryParse(_followers.text.trim()) ?? 0,
            doesLive: _doesLive,
            bio: _bio.text.trim().isEmpty ? null : _bio.text.trim(),
            motivation:
                _motivation.text.trim().isEmpty ? null : _motivation.text.trim(),
            goals: _goals.text.trim().isEmpty ? null : _goals.text.trim(),
            portfolioUrl: _normalizeUrl(_portfolio.text),
            termsAccepted: _acceptedTerms,
            termsVersion: termsVersion,
          );
      if (!mounted) return;
      context.go('/creator/submitted');
    } catch (e) {
      if (!mounted) return;
      final s = S.of(context);
      final msg = _errorMessage(s, e);
      if (msg == null) {
        // 409: já existe inscrição ativa -> leva para o acompanhamento.
        ref.invalidate(myCreatorApplicationProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(s.creatorFormAlreadyExists)),
        );
        context.go('/creator/status');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg), duration: const Duration(seconds: 5)),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

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
        final fields = RegExp(r'loc:\s*\[body,\s*(?:social_links,\s*)?([a-z_]+)')
            .allMatches(m)
            .map((x) => _fieldLabel(s, x.group(1)!))
            .toSet();
        if (fields.isNotEmpty) {
          return s.creatorApplyErrFields(fields.join(', '));
        }
        return s.creatorFormError;
      },
    );
  }

  String _fieldLabel(S s, String key) {
    switch (key) {
      case 'full_name':
        return s.creatorFormFullName;
      case 'username':
        return s.creatorFormUsername;
      case 'email':
        return s.creatorFormEmail;
      case 'phone':
        return s.creatorFormPhone;
      case 'country':
        return s.creatorFormCountry;
      case 'city':
        return s.creatorFormCity;
      case 'followers_count':
        return s.creatorFormFollowers;
      case 'bio':
        return s.creatorFormBio;
      case 'motivation':
        return s.creatorFormMotivation;
      case 'goals':
        return s.creatorFormGoals;
      case 'portfolio_url':
        return s.creatorFormPortfolio;
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
                          horizontal: 8, vertical: 3),
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
                  16, 8, 16, MediaQuery.of(sheetContext).padding.bottom + 12),
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
                            _termsError = false;
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
    return PopScope(
      canPop: !_submitting,
      child: Scaffold(
        backgroundColor: c.background,
        appBar: AppBar(
          backgroundColor: c.background,
          elevation: 0,
          scrolledUnderElevation: 0,
          title: Text(s.creatorFormTitle),
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
            children: [
              Text(s.creatorFormSubtitle,
                  style: TextStyle(
                    color: c.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  )),
              const SizedBox(height: 4),
              Text(s.creatorFormDescription,
                  style: TextStyle(
                    color: c.textSecondary,
                    fontSize: 13.5,
                    height: 1.4,
                  )),

              _section(s.creatorFormSectionIdentity),
              _field(_fullName, s.creatorFormFullName,
                  required: true,
                  maxLength: 120,
                  capitalization: TextCapitalization.words,
                  autofill: AutofillHints.name,
                  validate: (v) => v.length < 2 || !v.contains(' ')
                      ? s.creatorApplyErrName
                      : null),
              _field(_username, s.creatorFormUsername,
                  required: true,
                  maxLength: 50,
                  prefix: '@',
                  autofill: AutofillHints.username,
                  formatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9._]')),
                  ],
                  validate: (v) =>
                      v.replaceFirst('@', '').length < 2 ? s.creatorApplyErrUsername : null),
              _field(_email, s.creatorFormEmail,
                  required: true,
                  keyboard: TextInputType.emailAddress,
                  autofill: AutofillHints.email,
                  formatters: [FilteringTextInputFormatter.deny(RegExp(r'\s'))],
                  validate: (v) => RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]{2,}$')
                          .hasMatch(v)
                      ? null
                      : s.creatorFormValidationEmail),
              _field(_phone, s.creatorFormPhone,
                  optional: true,
                  keyboard: TextInputType.phone,
                  maxLength: 32,
                  autofill: AutofillHints.telephoneNumber,
                  formatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9+()\-\s]')),
                  ],
                  validate: (v) {
                    if (v.isEmpty) return null;
                    final digits = v.replaceAll(RegExp(r'\D'), '').length;
                    return digits < 8 || digits > 15
                        ? s.creatorApplyErrPhone
                        : null;
                  }),
              _countryField(s),
              _field(_city, s.creatorFormCity,
                  optional: true,
                  maxLength: 80,
                  capitalization: TextCapitalization.words),

              _section(s.creatorApplyTypeTitle),
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Text(s.creatorApplyTypeHint,
                    style: TextStyle(color: c.textSecondary, fontSize: 13)),
              ),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final n in ContentNiche.values) _nicheChip(s, n),
                ],
              ),
              const SizedBox(height: 18),
              Text(s.creatorFormCategory,
                  style: TextStyle(
                    color: c.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  )),
              const SizedBox(height: 2),
              Text(s.creatorApplyCategoryHint,
                  style: TextStyle(color: c.textSecondary, fontSize: 12.5)),
              const SizedBox(height: 8),
              ...kCreatorTiersOrder.reversed.map(
                (t) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: CreatorTierCard(
                    tier: t,
                    title: t.title(s),
                    description: t.body(s),
                    compact: true,
                    selected: _requestedTier == t,
                    onTap: () => setState(
                        () => _requestedTier = _requestedTier == t ? null : t),
                  ),
                ),
              ),

              _section(s.creatorFormSectionSocial),
              _field(_instagram, 'Instagram',
                  optional: true,
                  prefix: '@',
                  hint: s.creatorApplyInstagramHint,
                  formatters: [FilteringTextInputFormatter.deny(RegExp(r'\s'))]),
              _field(_tiktok, 'TikTok',
                  optional: true,
                  prefix: '@',
                  formatters: [FilteringTextInputFormatter.deny(RegExp(r'\s'))]),
              _field(_youtube, 'YouTube',
                  optional: true,
                  prefix: '@',
                  formatters: [FilteringTextInputFormatter.deny(RegExp(r'\s'))]),
              _field(_followers, s.creatorFormFollowers,
                  keyboard: TextInputType.number,
                  maxLength: 10,
                  formatters: [FilteringTextInputFormatter.digitsOnly],
                  validate: (v) => v.isNotEmpty && int.tryParse(v) == null
                      ? s.creatorApplyErrFollowers
                      : null),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: _doesLive,
                onChanged: (v) => setState(() => _doesLive = v),
                title: Text(s.creatorFormDoesLive,
                    style: TextStyle(color: c.textPrimary, fontSize: 14.5)),
                activeThumbColor: c.accentPrimary,
              ),

              _section(s.creatorFormSectionAbout),
              _field(_bio, s.creatorFormBio,
                  hint: s.creatorFormBioPlaceholder,
                  lines: 3,
                  maxLength: 600,
                  optional: true,
                  capitalization: TextCapitalization.sentences),
              _field(_motivation, s.creatorFormMotivation,
                  hint: s.creatorFormMotivationPlaceholder,
                  lines: 3,
                  maxLength: 1000,
                  optional: true,
                  capitalization: TextCapitalization.sentences),
              _field(_goals, s.creatorFormGoals,
                  hint: s.creatorFormGoalsPlaceholder,
                  lines: 3,
                  maxLength: 1000,
                  optional: true,
                  capitalization: TextCapitalization.sentences),
              _field(_portfolio, s.creatorFormPortfolio,
                  keyboard: TextInputType.url,
                  hint: 'https://',
                  action: TextInputAction.done,
                  formatters: [FilteringTextInputFormatter.deny(RegExp(r'\s'))],
                  validate: (v) {
                    if (v.isEmpty) return null;
                    final u = Uri.tryParse(_normalizeUrl(v)!);
                    final ok = u != null &&
                        u.host.contains('.') &&
                        (u.scheme == 'http' || u.scheme == 'https');
                    return ok ? null : s.creatorApplyErrUrl;
                  }),

              const SizedBox(height: 8),
              _termsBox(s),

              const SizedBox(height: 18),
              FilledButton.icon(
                icon: _submitting
                    ? SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: c.textOnAccent))
                    : const Icon(LucideIcons.send, size: 18),
                label: Text(
                    _submitting ? s.creatorFormSubmitting : s.creatorFormSubmit),
                onPressed: _submitting ? null : _submit,
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  backgroundColor: c.accentPrimary,
                  foregroundColor: c.textOnAccent,
                ),
              ),
              const SizedBox(height: 4),
              TextButton(
                onPressed: _submitting ? null : () => context.pop(),
                child: Text(s.creatorFormCancel),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _nicheChip(S s, ContentNiche n) {
    final c = context.colors;
    final sel = _niche == n;
    return ChoiceChip(
      selected: sel,
      showCheckmark: false,
      avatar: Icon(n.lucide,
          size: 16, color: sel ? c.textOnAccent : c.textSecondary),
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
    final borderColor = _termsError
        ? c.danger
        : _acceptedTerms
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
            border: Border.all(color: borderColor, width: _termsError ? 1.4 : 1),
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
                          if (_acceptedTerms) _termsError = false;
                        }),
                activeColor: c.accentPrimary,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text.rich(
                    TextSpan(
                      style: TextStyle(
                          color: c.textPrimary, fontSize: 13.5, height: 1.45),
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
        if (_termsError)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 4),
            child: Text(s.creatorFormTermsMustAccept,
                style: TextStyle(color: c.danger, fontSize: 12.5)),
          ),
      ],
    );
  }

  Widget _section(String title) => Padding(
        padding: const EdgeInsets.only(top: 26, bottom: 12),
        child: Text(title.toUpperCase(),
            style: TextStyle(
              color: context.colors.textTertiary,
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.1,
            )),
      );

  /// Campo de país com seletor (bandeira + nome + ISO). Envia ISO-2 ao backend.
  Widget _countryField(S s) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: FormField<Country>(
        initialValue: _selectedCountry,
        validator: (_) =>
            _selectedCountry == null ? s.creatorApplyErrCountry : null,
        builder: (state) => InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () async {
            final picked = await showCountryPicker(
              context,
              selectedCode: _selectedCountry?.code,
              title: s.creatorFormCountry,
            );
            if (picked != null) {
              setState(() => _selectedCountry = picked);
              state.didChange(picked);
            }
          },
          child: InputDecorator(
            decoration: _decoration(s.creatorFormCountry).copyWith(
              errorText: state.errorText,
              suffixIcon: Icon(LucideIcons.chevronDown,
                  size: 18, color: c.textSecondary),
            ),
            child: _selectedCountry != null
                ? Row(
                    children: [
                      Text(_selectedCountry!.flag,
                          style: const TextStyle(fontSize: 22)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          '${_selectedCountry!.name} (${_selectedCountry!.code})',
                          style:
                              TextStyle(color: c.textPrimary, fontSize: 15),
                        ),
                      ),
                    ],
                  )
                : const SizedBox(height: 22),
          ),
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController ctrl,
    String label, {
    String? hint,
    String? prefix,
    bool required = false,
    bool optional = false,
    int lines = 1,
    int? maxLength,
    TextInputType? keyboard,
    TextInputAction? action,
    TextCapitalization capitalization = TextCapitalization.none,
    String? autofill,
    List<TextInputFormatter>? formatters,
    String? Function(String value)? validate,
  }) {
    final s = S.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: ctrl,
        enabled: !_submitting,
        decoration: _decoration(
          optional ? '$label (${s.creatorApplyOptional})' : label,
          hint: hint,
        ).copyWith(
          prefixText: prefix,
          counterText: lines > 1 ? null : '',
        ),
        style: TextStyle(color: context.colors.textPrimary),
        minLines: lines,
        maxLines: lines,
        maxLength: maxLength,
        keyboardType: lines > 1 ? TextInputType.multiline : keyboard,
        textInputAction: action ??
            (lines > 1 ? TextInputAction.newline : TextInputAction.next),
        textCapitalization: capitalization,
        autofillHints: autofill == null ? null : [autofill],
        inputFormatters: formatters,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        validator: (v) {
          final t = (v ?? '').trim();
          if (required && t.isEmpty) return s.creatorFormValidationRequired;
          return validate?.call(t);
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
