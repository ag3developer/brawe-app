import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../data/repositories/profile_repository.dart';
import '../../../gen/l10n/app_localizations.dart';
import '../../core/themes/brawe_colors.dart';

// ─────────────────────────────────────────────────────────────────────────────
// BUSINESS PROFILE SCREEN
// Formulário completo para tipo de conta Business:
//  • Nome da empresa / marca
//  • Setor de atuação (seletor)
//  • País + cidade
//  • Dados fiscais / CNPJ (fluxo de verificação separado)
//  • Links: site, LinkedIn, WhatsApp Business, Instagram
//  • Idioma de operação
// ─────────────────────────────────────────────────────────────────────────────

class BusinessProfileScreen extends ConsumerStatefulWidget {
  const BusinessProfileScreen({super.key});

  @override
  ConsumerState<BusinessProfileScreen> createState() =>
      _BusinessProfileScreenState();
}

class _BusinessProfileScreenState extends ConsumerState<BusinessProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _companyCtrl = TextEditingController();
  final _bioCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _websiteCtrl = TextEditingController();
  final _linkedinCtrl = TextEditingController();
  final _whatsappCtrl = TextEditingController();
  final _instagramCtrl = TextEditingController();

  String? _selectedCountry;
  String? _selectedLanguage;
  String? _selectedSector;
  bool _saving = false;

  static const _countries = [
    ('BR', '🇧🇷'),
    ('PT', '🇵🇹'),
    ('US', '🇺🇸'),
    ('AR', '🇦🇷'),
    ('MX', '🇲🇽'),
    ('CO', '🇨🇴'),
    ('CL', '🇨🇱'),
    ('ES', '🇪🇸'),
    ('DE', '🇩🇪'),
    ('GB', '🇬🇧'),
    ('AO', '🇦🇴'),
    ('MZ', '🇲🇿'),
  ];

  static const _languages = [
    ('pt', '🇧🇷 Português'),
    ('es', '🇪🇸 Español'),
    ('en', '🇺🇸 English'),
    ('de', '🇩🇪 Deutsch'),
    ('fr', '🇫🇷 Français'),
  ];

  static const _sectors = [
    'FashionBeauty',
    'Tech',
    'Food',
    'Entertainment',
    'Education',
    'Health',
    'Finance',
    'Retail',
    'Music',
    'Games',
    'Sports',
    'RealEstate',
    'Agro',
    'Services',
    'Ngo',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _selectedCountry = 'BR';
    _selectedLanguage = 'pt';
  }

  @override
  void dispose() {
    _companyCtrl.dispose();
    _bioCtrl.dispose();
    _cityCtrl.dispose();
    _websiteCtrl.dispose();
    _linkedinCtrl.dispose();
    _whatsappCtrl.dispose();
    _instagramCtrl.dispose();
    super.dispose();
  }

  Future<void> _onSave() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();
    setState(() => _saving = true);
    try {
      // Salva via socialLinks + campos de perfil
      final socialLinks = <String, String>{};
      if (_websiteCtrl.text.trim().isNotEmpty) {
        socialLinks['website'] = _websiteCtrl.text.trim();
      }
      if (_linkedinCtrl.text.trim().isNotEmpty) {
        socialLinks['linkedin'] = _linkedinCtrl.text.trim();
      }
      if (_instagramCtrl.text.trim().isNotEmpty) {
        socialLinks['instagram'] = _instagramCtrl.text.trim();
      }
      if (_whatsappCtrl.text.trim().isNotEmpty) {
        socialLinks['whatsapp'] = _whatsappCtrl.text.trim();
      }

      await ref
          .read(profileRepositoryProvider)
          .updateMyProfile(
            displayName: _companyCtrl.text.trim(),
            bio: _bioCtrl.text.trim(),
            socialLinks: socialLinks,
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                LucideIcons.checkCircle,
                color: context.colors.textOnAccent,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                S.of(context).editProfileSaved,
                style: TextStyle(color: context.colors.textOnAccent),
              ),
            ],
          ),
          backgroundColor: context.colors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            S.of(context).bizProfSaveError(e.toString()),
            style: TextStyle(color: context.colors.textOnAccent),
          ),
          backgroundColor: context.colors.danger,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final c = context.colors;
    final accent = c.accentPrimary;

    return Scaffold(
      backgroundColor: context.colors.background,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: context.colors.background.withValues(alpha: 0.85),
        foregroundColor: context.colors.textPrimary,
        elevation: 0,
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
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(LucideIcons.briefcase, size: 18, color: accent),
            const SizedBox(width: 8),
            Text(
              'Business',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: context.colors.textPrimary,
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: FilledButton(
              onPressed: _saving ? null : _onSave,
              style: FilledButton.styleFrom(
                backgroundColor: accent,
                foregroundColor: c.textOnAccent,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                minimumSize: Size.zero,
              ),
              child: _saving
                  ? SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: c.textOnAccent,
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
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + kToolbarHeight + 16,
            bottom: MediaQuery.of(context).padding.bottom + 32,
          ),
          children: [
            // Identidade da empresa
            _section(
              context: context,
              title: s.bizProfSectionCompany,
              children: [
                _field(
                  context: context,
                  icon: LucideIcons.building,
                  label: s.bizProfCompanyName,
                  child: _textField(
                    context: context,
                    ctrl: _companyCtrl,
                    hint: s.bizProfCompanyNameHint,
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? s.bizProfRequired
                        : null,
                  ),
                ),
                _divider(context),
                _field(
                  context: context,
                  icon: LucideIcons.alignLeft,
                  label: s.bizProfAbout,
                  child: _textField(
                    context: context,
                    ctrl: _bioCtrl,
                    hint: s.bizProfAboutHint,
                    maxLines: 3,
                    maxLength: 300,
                  ),
                ),
                _divider(context),
                _field(
                  context: context,
                  icon: LucideIcons.layoutGrid,
                  label: s.bizProfSector,
                  child: _dropdown<String>(
                    context: context,
                    value: _selectedSector,
                    hint: s.bizProfSectorHint,
                    items: _sectors
                        .map(
                          (k) => DropdownMenuItem(
                            value: k,
                            child: Text(
                              _sectorName(s, k),
                              style: TextStyle(
                                fontSize: 15,
                                color: c.textPrimary,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setState(() => _selectedSector = v),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Localização
            _section(
              context: context,
              title: s.bizProfSectionLocation,
              children: [
                _field(
                  context: context,
                  icon: LucideIcons.globe,
                  label: s.bizProfCountry,
                  child: _dropdown<String>(
                    context: context,
                    value: _selectedCountry,
                    hint: s.bizProfCountryHint,
                    items: _countries
                        .map(
                          (e) => DropdownMenuItem(
                            value: e.$1,
                            child: Text(
                              '${e.$2} ${_countryName(s, e.$1)}',
                              style: TextStyle(
                                fontSize: 15,
                                color: c.textPrimary,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setState(() => _selectedCountry = v),
                  ),
                ),
                _divider(context),
                _field(
                  context: context,
                  icon: LucideIcons.building2,
                  label: s.bizProfCity,
                  child: _textField(
                    context: context,
                    ctrl: _cityCtrl,
                    hint: s.bizProfCityHint,
                  ),
                ),
                _divider(context),
                _field(
                  context: context,
                  icon: LucideIcons.languages,
                  label: s.bizProfLanguage,
                  child: _dropdown<String>(
                    context: context,
                    value: _selectedLanguage,
                    hint: s.bizProfLanguageHint,
                    items: _languages
                        .map(
                          (l) => DropdownMenuItem(
                            value: l.$1,
                            child: Text(
                              l.$2,
                              style: TextStyle(
                                fontSize: 15,
                                color: c.textPrimary,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setState(() => _selectedLanguage = v),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Dados fiscais (CNPJ fica no fluxo de verificação)
            _section(
              context: context,
              title: s.bizProfSectionFiscal,
              children: [
                InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () => context.push('/account/verify/business'),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          LucideIcons.fileText,
                          size: 16,
                          color: c.textSecondary,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                s.bizProfFiscalRow,
                                style: TextStyle(
                                  fontSize: 15,
                                  color: c.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                s.bizProfFiscalRowHint,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: c.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          LucideIcons.chevronRight,
                          size: 16,
                          color: c.textSecondary,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Links
            _section(
              context: context,
              title: s.bizProfSectionLinks,
              children: [
                _platformRow(
                  context: context,
                  icon: LucideIcons.globe,
                  label: s.bizProfWebsite,
                  ctrl: _websiteCtrl,
                  hint: s.bizProfWebsiteHint,
                ),
                _divider(context),
                _platformRow(
                  context: context,
                  icon: LucideIcons.link,
                  label: 'LinkedIn',
                  ctrl: _linkedinCtrl,
                  hint: 'linkedin.com/company/...',
                ),
                _divider(context),
                _platformRow(
                  context: context,
                  icon: LucideIcons.atSign,
                  label: 'Instagram',
                  ctrl: _instagramCtrl,
                  hint: s.bizProfInstagramHint,
                ),
                _divider(context),
                _platformRow(
                  context: context,
                  icon: LucideIcons.messageCircle,
                  label: 'WhatsApp Business',
                  ctrl: _whatsappCtrl,
                  hint: s.bizProfWhatsappHint,
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // Helpers

  String _countryName(S s, String code) {
    switch (code) {
      case 'BR':
        return s.bizProfCountryBR;
      case 'PT':
        return s.bizProfCountryPT;
      case 'US':
        return s.bizProfCountryUS;
      case 'AR':
        return s.bizProfCountryAR;
      case 'MX':
        return s.bizProfCountryMX;
      case 'CO':
        return s.bizProfCountryCO;
      case 'CL':
        return s.bizProfCountryCL;
      case 'ES':
        return s.bizProfCountryES;
      case 'DE':
        return s.bizProfCountryDE;
      case 'GB':
        return s.bizProfCountryGB;
      case 'AO':
        return s.bizProfCountryAO;
      case 'MZ':
        return s.bizProfCountryMZ;
      default:
        return code;
    }
  }

  String _sectorName(S s, String key) {
    switch (key) {
      case 'FashionBeauty':
        return s.bizProfSectorFashionBeauty;
      case 'Tech':
        return s.bizProfSectorTech;
      case 'Food':
        return s.bizProfSectorFood;
      case 'Entertainment':
        return s.bizProfSectorEntertainment;
      case 'Education':
        return s.bizProfSectorEducation;
      case 'Health':
        return s.bizProfSectorHealth;
      case 'Finance':
        return s.bizProfSectorFinance;
      case 'Retail':
        return s.bizProfSectorRetail;
      case 'Music':
        return s.bizProfSectorMusic;
      case 'Games':
        return s.bizProfSectorGames;
      case 'Sports':
        return s.bizProfSectorSports;
      case 'RealEstate':
        return s.bizProfSectorRealEstate;
      case 'Agro':
        return s.bizProfSectorAgro;
      case 'Services':
        return s.bizProfSectorServices;
      case 'Ngo':
        return s.bizProfSectorNgo;
      case 'Other':
        return s.bizProfSectorOther;
      default:
        return key;
    }
  }

  Widget _section({
    required BuildContext context,
    required String title,
    String? subtitle,
    required List<Widget> children,
  }) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: title.toUpperCase(),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                      color: c.textTertiary,
                    ),
                  ),
                  if (subtitle != null)
                    TextSpan(
                      text: '  ·  $subtitle',
                      style: TextStyle(fontSize: 11, color: c.textTertiary),
                    ),
                ],
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: c.surface,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }

  Widget _field({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Widget child,
  }) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Icon(icon, size: 16, color: c.textSecondary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: c.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                child,
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _platformRow({
    required BuildContext context,
    required IconData icon,
    required String label,
    required TextEditingController ctrl,
    required String hint,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          Icon(icon, size: 16, color: context.colors.textSecondary),
          const SizedBox(width: 12),
          Expanded(
            child: _textField(
              context: context,
              ctrl: ctrl,
              hint: hint,
              prefixText: '$label · ',
            ),
          ),
        ],
      ),
    );
  }

  Widget _textField({
    required BuildContext context,
    required TextEditingController ctrl,
    required String hint,
    int maxLines = 1,
    int? maxLength,
    String? prefixText,
    String? Function(String?)? validator,
  }) {
    final c = context.colors;
    return TextFormField(
      // maiúscula automática só em texto livre; links ficam como digitados
      textCapitalization: prefixText == null
          ? TextCapitalization.sentences
          : TextCapitalization.none,
      controller: ctrl,
      maxLines: maxLines,
      maxLength: maxLength,
      validator: validator,
      style: TextStyle(fontSize: 15, color: c.textPrimary),
      decoration: InputDecoration(
        hintText: hint,
        prefixText: prefixText,
        prefixStyle: TextStyle(
          fontSize: 14,
          color: c.textTertiary,
          fontWeight: FontWeight.w500,
        ),
        hintStyle: TextStyle(
          fontSize: 15,
          color: c.textTertiary.withValues(alpha: 0.6),
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

  Widget _dropdown<T>({
    required BuildContext context,
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
    required String hint,
  }) {
    final c = context.colors;
    return DropdownButtonFormField<T>(
      value: value,
      items: items,
      onChanged: onChanged,
      dropdownColor: c.surfaceElevated,
      style: TextStyle(fontSize: 15, color: c.textPrimary),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          fontSize: 15,
          color: c.textTertiary.withValues(alpha: 0.6),
        ),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 4),
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
      ),
      icon: Icon(LucideIcons.chevronDown, size: 16, color: c.textSecondary),
    );
  }

  Widget _divider(BuildContext context) =>
      Divider(height: 1, indent: 42, color: context.colors.divider);
}
