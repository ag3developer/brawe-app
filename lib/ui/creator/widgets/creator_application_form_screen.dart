import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../data/services/legal_assets_service.dart';
import '../../../domain/models/creator_network.dart';
import '../../../gen/l10n/app_localizations.dart';
import '../../core/themes/brawe_colors.dart';
import '../../core/widgets/simple_markdown_view.dart';
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
  final _country = TextEditingController();
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
      _fullName, _username, _email, _phone, _country, _city,
      _instagram, _tiktok, _youtube, _followers, _bio, _motivation,
      _goals, _portfolio
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_acceptedTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S.of(context).creatorFormTermsMustAccept)),
      );
      return;
    }
    setState(() => _submitting = true);
    try {
      // Versão dos Termos vigente — recuperada do backend (cacheada).
      // Se a chamada falhar, o backend usa a versão default.
      final termsVersion =
          await ref.read(creatorTermsVersionProvider.future);
      await ref
          .read(creatorApplicationFormControllerProvider.notifier)
          .submit(
            fullName: _fullName.text.trim(),
            username: _username.text.trim(),
            email: _email.text.trim(),
            phone: _phone.text.trim().isEmpty ? null : _phone.text.trim(),
            country: _country.text.trim(),
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
            motivation: _motivation.text.trim().isEmpty ? null : _motivation.text.trim(),
            goals: _goals.text.trim().isEmpty ? null : _goals.text.trim(),
            portfolioUrl:
                _portfolio.text.trim().isEmpty ? null : _portfolio.text.trim(),
            termsAccepted: _acceptedTerms,
            termsVersion: termsVersion,
          );
      if (!mounted) return;
      context.go('/creator/submitted');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S.of(context).creatorFormError)),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
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
                      icon: const Icon(Icons.check_rounded),
                      label: Text(s.creatorFormTermsLink),
                      onPressed: () {
                        Navigator.of(sheetContext).pop();
                        if (mounted) {
                          setState(() => _acceptedTerms = true);
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

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        backgroundColor: context.colors.background,
        elevation: 0,
        title: Text(s.creatorFormTitle),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
          children: [
            Text(s.creatorFormSubtitle,
                style: TextStyle(
                  color: context.colors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                )),
            const SizedBox(height: 6),
            Text(s.creatorFormDescription,
                style: TextStyle(
                  color: context.colors.textSecondary,
                  fontSize: 13.5,
                  height: 1.45,
                )),
            const SizedBox(height: 22),

            _section(s.creatorFormSectionIdentity),
            _field(_fullName, s.creatorFormFullName, required: true),
            _field(_username, s.creatorFormUsername, required: true),
            _field(_email, s.creatorFormEmail,
                required: true, keyboard: TextInputType.emailAddress, isEmail: true),
            _field(_phone, s.creatorFormPhone, keyboard: TextInputType.phone),
            _field(_country, s.creatorFormCountry, required: true),
            _field(_city, s.creatorFormCity),

            _section(s.creatorFormSectionContent),
            DropdownButtonFormField<ContentNiche>(
              initialValue: _niche,
              decoration: _decoration(s.creatorFormNiche),
              dropdownColor: context.colors.surfaceElevated,
              items: ContentNiche.values
                  .map((n) => DropdownMenuItem(
                        value: n,
                        child: Text(n.name,
                            style: TextStyle(color: context.colors.textPrimary)),
                      ))
                  .toList(),
              onChanged: (v) => setState(() => _niche = v ?? ContentNiche.other),
            ),
            const SizedBox(height: 12),
            Text(s.creatorFormCategory,
                style: TextStyle(
                  color: context.colors.textSecondary,
                  fontWeight: FontWeight.w600,
                  fontSize: 12.5,
                )),
            const SizedBox(height: 8),
            ...kCreatorTiersOrder.map(
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
            _field(_instagram, 'Instagram'),
            _field(_tiktok, 'TikTok'),
            _field(_youtube, 'YouTube'),
            _field(_followers, s.creatorFormFollowers,
                keyboard: TextInputType.number),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: _doesLive,
              onChanged: (v) => setState(() => _doesLive = v),
              title: Text(s.creatorFormDoesLive,
                  style: TextStyle(color: context.colors.textPrimary)),
              activeThumbColor: context.colors.accentPrimary,
            ),

            _section(s.creatorFormSectionAbout),
            _field(_bio, s.creatorFormBio, hint: s.creatorFormBioPlaceholder, lines: 3),
            _field(_motivation, s.creatorFormMotivation,
                hint: s.creatorFormMotivationPlaceholder, lines: 3),
            _field(_goals, s.creatorFormGoals,
                hint: s.creatorFormGoalsPlaceholder, lines: 3),
            _field(_portfolio, s.creatorFormPortfolio),

            const SizedBox(height: 12),

            // ── Aceite dos termos ────────────────────────────
            // Obrigatório (App Store §5.1.1 / LGPD). Clicar no link "Termos
            // do Brawe Creator Network" abre o bottom sheet com o markdown
            // legal completo (PT/EN/ES) e um botão "Aceitar" que também
            // marca o checkbox automaticamente.
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: context.colors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: _acceptedTerms
                      ? context.colors.accentPrimary.withValues(alpha: 0.5)
                      : context.colors.border,
                  width: _acceptedTerms ? 1.4 : 1,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Checkbox(
                    value: _acceptedTerms,
                    onChanged: (v) => setState(() => _acceptedTerms = v ?? false),
                    activeColor: context.colors.accentPrimary,
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: RichText(
                        text: TextSpan(
                          style: TextStyle(
                            color: context.colors.textPrimary,
                            fontSize: 13.5,
                            height: 1.4,
                          ),
                          children: [
                            TextSpan(text: s.creatorFormTermsPrefix),
                            TextSpan(
                              text: s.creatorFormTermsLink,
                              style: TextStyle(
                                color: context.colors.accentPrimary,
                                fontWeight: FontWeight.w700,
                                decoration: TextDecoration.underline,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = _openTerms,
                            ),
                            TextSpan(text: s.creatorFormTermsSuffix),
                          ],
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: s.creatorFormTermsOpen,
                    icon: Icon(Icons.open_in_new_rounded,
                        color: context.colors.accentPrimary),
                    onPressed: _openTerms,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),
            FilledButton.icon(
              icon: _submitting
                  ? const SizedBox(
                      width: 16, height: 16,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.send_rounded),
              label: Text(_submitting
                  ? s.creatorFormSubmitting
                  : s.creatorFormSubmit),
              onPressed: _submitting ? null : _submit,
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
                backgroundColor: context.colors.accentPrimary,
                foregroundColor: context.colors.textOnAccent,
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => context.pop(),
              child: Text(s.creatorFormCancel),
            ),
          ],
        ),
      ),
    );
  }

  Widget _section(String title) => Padding(
        padding: const EdgeInsets.only(top: 18, bottom: 10),
        child: Text(title,
            style: TextStyle(
              color: context.colors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.2,
            )),
      );

  Widget _field(
    TextEditingController c,
    String label, {
    String? hint,
    bool required = false,
    bool isEmail = false,
    int lines = 1,
    TextInputType? keyboard,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: c,
        decoration: _decoration(label, hint: hint),
        style: TextStyle(color: context.colors.textPrimary),
        minLines: lines,
        maxLines: lines,
        keyboardType: keyboard,
        validator: (v) {
          final t = (v ?? '').trim();
          if (required && t.isEmpty) {
            return S.of(context).creatorFormValidationRequired;
          }
          if (isEmail && t.isNotEmpty && !t.contains('@')) {
            return S.of(context).creatorFormValidationEmail;
          }
          return null;
        },
      ),
    );
  }

  InputDecoration _decoration(String label, {String? hint}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      filled: true,
      fillColor: context.colors.surface,
      labelStyle: TextStyle(color: context.colors.textSecondary),
      hintStyle: TextStyle(color: context.colors.textTertiary),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: context.colors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: context.colors.accentPrimary, width: 1.5),
      ),
    );
  }
}
