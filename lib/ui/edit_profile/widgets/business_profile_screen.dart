import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../data/repositories/profile_repository.dart';
import '../../../gen/l10n/app_localizations.dart';
import '../../core/themes/app_colors.dart';
import '../../core/themes/brawe_colors.dart';

// ─────────────────────────────────────────────────────────────────────────────
// BUSINESS PROFILE SCREEN
// Formulário completo para tipo de conta Business:
//  • Nome da empresa / marca
//  • Setor de atuação (seletor)
//  • País + cidade
//  • CNPJ / Tax ID (opcional)
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
  final _cnpjCtrl = TextEditingController();
  final _websiteCtrl = TextEditingController();
  final _linkedinCtrl = TextEditingController();
  final _whatsappCtrl = TextEditingController();
  final _instagramCtrl = TextEditingController();

  String? _selectedCountry;
  String? _selectedLanguage;
  String? _selectedSector;
  bool _saving = false;

  static const _countries = [
    ('BR', '🇧🇷 Brasil'),
    ('PT', '🇵🇹 Portugal'),
    ('US', '🇺🇸 Estados Unidos'),
    ('AR', '🇦🇷 Argentina'),
    ('MX', '🇲🇽 México'),
    ('CO', '🇨🇴 Colômbia'),
    ('CL', '🇨🇱 Chile'),
    ('ES', '🇪🇸 Espanha'),
    ('DE', '🇩🇪 Alemanha'),
    ('GB', '🇬🇧 Reino Unido'),
    ('AO', '🇦🇴 Angola'),
    ('MZ', '🇲🇿 Moçambique'),
  ];

  static const _languages = [
    ('pt', '🇧🇷 Português'),
    ('es', '🇪🇸 Español'),
    ('en', '🇺🇸 English'),
    ('de', '🇩🇪 Deutsch'),
    ('fr', '🇫🇷 Français'),
  ];

  static const _sectors = [
    'Moda & Beleza',
    'Tecnologia',
    'Alimentação & Bebidas',
    'Entretenimento',
    'Educação',
    'Saúde & Bem-estar',
    'Finanças & Investimentos',
    'Varejo & E-commerce',
    'Música & Áudio',
    'Games',
    'Esportes',
    'Imóveis',
    'Agro & Sustentabilidade',
    'Serviços Profissionais',
    'ONG & Social',
    'Outro',
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
    _cnpjCtrl.dispose();
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
              const Icon(
                LucideIcons.checkCircle,
                color: Colors.white,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(S.of(context).editProfileSaved),
            ],
          ),
          backgroundColor: Colors.green.shade700,
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
          content: Text('Erro ao salvar: $e'),
          backgroundColor: Colors.red.shade700,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const accent = AppColors.braweBlue;

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
            const Icon(LucideIcons.briefcase, size: 18, color: accent),
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
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
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
              isDark: isDark,
              icon: LucideIcons.building2,
              color: accent,
              title: 'Empresa / Marca',
              children: [
                _field(
                  context: context,
                  icon: LucideIcons.building,
                  label: 'Nome da empresa ou marca',
                  child: _textField(
                    context: context,
                    ctrl: _companyCtrl,
                    hint: 'Ex: Minha Empresa S.A.',
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Obrigatório' : null,
                  ),
                ),
                _divider(context),
                _field(
                  context: context,
                  icon: LucideIcons.alignLeft,
                  label: 'Sobre a empresa',
                  child: _textField(
                    context: context,
                    ctrl: _bioCtrl,
                    hint: 'Descreva sua empresa ou marca...',
                    maxLines: 3,
                    maxLength: 300,
                  ),
                ),
                _divider(context),
                _field(
                  context: context,
                  icon: LucideIcons.layoutGrid,
                  label: 'Setor de atuação',
                  child: _dropdown<String>(
                    context: context,
                    isDark: isDark,
                    value: _selectedSector,
                    hint: 'Selecione um setor',
                    items: _sectors
                        .map(
                          (s) => DropdownMenuItem(
                            value: s,
                            child: Text(
                              s,
                              style: TextStyle(
                                fontSize: 15,
                                color: context.colors.textPrimary,
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
            const SizedBox(height: 12),

            // Localização
            _section(
              context: context,
              isDark: isDark,
              icon: LucideIcons.mapPin,
              color: accent,
              title: 'Localização',
              children: [
                _field(
                  context: context,
                  icon: LucideIcons.globe,
                  label: 'País de operação',
                  child: _dropdown<String>(
                    context: context,
                    isDark: isDark,
                    value: _selectedCountry,
                    hint: 'Selecione o país',
                    items: _countries
                        .map(
                          (c) => DropdownMenuItem(
                            value: c.$1,
                            child: Text(
                              c.$2,
                              style: TextStyle(
                                fontSize: 15,
                                color: context.colors.textPrimary,
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
                  icon: LucideIcons.building,
                  label: 'Cidade',
                  child: _textField(
                    context: context,
                    ctrl: _cityCtrl,
                    hint: 'Cidade sede',
                  ),
                ),
                _divider(context),
                _field(
                  context: context,
                  icon: LucideIcons.languages,
                  label: 'Idioma principal',
                  child: _dropdown<String>(
                    context: context,
                    isDark: isDark,
                    value: _selectedLanguage,
                    hint: 'Idioma de operação',
                    items: _languages
                        .map(
                          (l) => DropdownMenuItem(
                            value: l.$1,
                            child: Text(
                              l.$2,
                              style: TextStyle(
                                fontSize: 15,
                                color: context.colors.textPrimary,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setState(() => _selectedLanguage = v),
                  ),
                ),
                _divider(context),
                _field(
                  context: context,
                  icon: LucideIcons.hash,
                  label: 'CNPJ / Tax ID (opcional)',
                  child: _textField(
                    context: context,
                    ctrl: _cnpjCtrl,
                    hint: '00.000.000/0001-00',
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9./\-]')),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Links
            _section(
              context: context,
              isDark: isDark,
              icon: LucideIcons.link,
              color: accent,
              title: 'Links',
              children: [
                _platformRow(
                  context: context,
                  icon: LucideIcons.globe,
                  color: accent,
                  label: 'Website',
                  ctrl: _websiteCtrl,
                  hint: 'https://suaempresa.com',
                ),
                _divider(context),
                _platformRow(
                  context: context,
                  icon: LucideIcons.globe,
                  color: const Color(0xFF0A66C2),
                  label: 'LinkedIn',
                  ctrl: _linkedinCtrl,
                  hint: 'linkedin.com/company/...',
                ),
                _divider(context),
                _platformRow(
                  context: context,
                  icon: LucideIcons.globe,
                  color: const Color(0xFFE1306C),
                  label: 'Instagram',
                  ctrl: _instagramCtrl,
                  hint: '@suaempresa',
                ),
                _divider(context),
                _platformRow(
                  context: context,
                  icon: LucideIcons.messageCircle,
                  color: const Color(0xFF25D366),
                  label: 'WhatsApp Business',
                  ctrl: _whatsappCtrl,
                  hint: '+55 11 99999-9999',
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
  Widget _section({
    required BuildContext context,
    required bool isDark,
    required IconData icon,
    required Color color,
    required String title,
    required List<Widget> children,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Row(
              children: [
                Icon(icon, size: 13, color: color),
                const SizedBox(width: 6),
                Text(
                  title.toUpperCase(),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                    color: context.colors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.black.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.07)
                    : Colors.black.withValues(alpha: 0.06),
              ),
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Icon(icon, size: 16, color: context.colors.textTertiary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: context.colors.textTertiary,
                    letterSpacing: 0.2,
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
    required Color color,
    required String label,
    required TextEditingController ctrl,
    required String hint,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 15, color: color),
          ),
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
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextFormField(
      controller: ctrl,
      maxLines: maxLines,
      maxLength: maxLength,
      validator: validator,
      inputFormatters: inputFormatters,
      style: TextStyle(
        fontSize: 15,
        color: context.colors.textPrimary,
        fontWeight: FontWeight.w400,
      ),
      decoration: InputDecoration(
        hintText: hint,
        prefixText: prefixText,
        prefixStyle: TextStyle(
          fontSize: 14,
          color: context.colors.textTertiary,
          fontWeight: FontWeight.w500,
        ),
        hintStyle: TextStyle(
          fontSize: 15,
          color: context.colors.textTertiary.withValues(alpha: 0.5),
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
    required bool isDark,
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
    required String hint,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      items: items,
      onChanged: onChanged,
      dropdownColor: context.colors.surfaceElevated,
      style: TextStyle(fontSize: 15, color: context.colors.textPrimary),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          fontSize: 15,
          color: context.colors.textTertiary.withValues(alpha: 0.5),
        ),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 4),
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
      ),
      icon: Icon(
        LucideIcons.chevronDown,
        size: 16,
        color: context.colors.textTertiary,
      ),
    );
  }

  Widget _divider(BuildContext context) => Divider(
    height: 1,
    indent: 42,
    color: context.colors.divider.withValues(alpha: 0.5),
  );
}
