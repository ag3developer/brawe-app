import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../data/repositories/sound_repository.dart';
import '../../../gen/l10n/app_localizations.dart';
import '../../core/themes/brawe_colors.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ARTIST PROFILE SCREEN — Brawe Sounds
// Formulário completo para tipo de conta Músico:
//  • Nome artístico, bio
//  • País (seletor ISO) + cidade
//  • Gêneros musicais (multi-select chips)
//  • Links de plataformas (Spotify, Apple Music, YouTube, SoundCloud, Deezer)
//  • Idioma nativo do artista
// ─────────────────────────────────────────────────────────────────────────────

class ArtistProfileScreen extends ConsumerStatefulWidget {
  const ArtistProfileScreen({super.key});

  @override
  ConsumerState<ArtistProfileScreen> createState() =>
      _ArtistProfileScreenState();
}

class _ArtistProfileScreenState extends ConsumerState<ArtistProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _artistNameCtrl = TextEditingController();
  final _bioCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _spotifyCtrl = TextEditingController();
  final _appleMusicCtrl = TextEditingController();
  final _youtubeCtrl = TextEditingController();
  final _soundcloudCtrl = TextEditingController();
  final _deezerCtrl = TextEditingController();

  String? _selectedCountry;
  String? _selectedLanguage;
  final Set<String> _selectedGenres = {};
  bool _saving = false;
  bool _loaded = false;

  // Países disponíveis (ISO 3166-1 alpha-2) + bandeira
  static const _countries = [
    ('BR', '🇧🇷'),
    ('PT', '🇵🇹'),
    ('US', '🇺🇸'),
    ('AR', '🇦🇷'),
    ('MX', '🇲🇽'),
    ('CO', '🇨🇴'),
    ('CL', '🇨🇱'),
    ('PE', '🇵🇪'),
    ('UY', '🇺🇾'),
    ('PY', '🇵🇾'),
    ('BO', '🇧🇴'),
    ('EC', '🇪🇨'),
    ('VE', '🇻🇪'),
    ('ES', '🇪🇸'),
    ('FR', '🇫🇷'),
    ('DE', '🇩🇪'),
    ('IT', '🇮🇹'),
    ('GB', '🇬🇧'),
    ('JP', '🇯🇵'),
    ('KR', '🇰🇷'),
    ('NG', '🇳🇬'),
    ('GH', '🇬🇭'),
    ('ZA', '🇿🇦'),
    ('AO', '🇦🇴'),
    ('MZ', '🇲🇿'),
    ('CV', '🇨🇻'),
  ];

  // Idiomas (BCP-47)
  static const _languages = [
    ('pt', '🇧🇷 Português'),
    ('es', '🇪🇸 Español'),
    ('en', '🇺🇸 English'),
    ('fr', '🇫🇷 Français'),
    ('de', '🇩🇪 Deutsch'),
    ('it', '🇮🇹 Italiano'),
    ('ja', '🇯🇵 日本語'),
    ('ko', '🇰🇷 한국어'),
    ('yo', '🇳🇬 Yorùbá'),
    ('sw', '🇰🇪 Kiswahili'),
  ];

  // Gêneros musicais
  static const _genres = [
    'Funk',
    'Sertanejo',
    'Pagode',
    'Forró',
    'Pop',
    'Rap',
    'Hip-Hop',
    'Eletrônico',
    'Gospel',
    'Rock',
    'MPB',
    'R&B',
    'Reggae',
    'Axé',
    'Baile Funk',
    'Trap',
    'Afrobeats',
    'K-Pop',
    'Jazz',
    'Bossa Nova',
    'Soul',
    'Blues',
    'Country',
    'Metal',
    'Indie',
    'Lo-fi',
    'Classical',
    'Salsa',
    'Merengue',
    'Cumbia',
    'Reggaeton',
  ];

  @override
  void initState() {
    super.initState();
    _selectedCountry = 'BR';
    _selectedLanguage = 'pt';
    _loadExisting();
  }

  Future<void> _loadExisting() async {
    try {
      final raw = await ref.read(soundRepositoryProvider).getMyArtistProfile();
      if (!mounted) return;
      // getMyArtistProfile pode retornar null se o artista ainda não existe
      final data = (raw ?? const <String, dynamic>{}) as Map<String, dynamic>;
      setState(() {
        _artistNameCtrl.text = (data['artist_name'] as String?) ?? '';
        _bioCtrl.text = (data['bio'] as String?) ?? '';
        _cityCtrl.text = (data['city'] as String?) ?? '';
        _selectedCountry = (data['country_code'] as String?) ?? 'BR';
        _selectedLanguage = (data['language'] as String?) ?? 'pt';
        _spotifyCtrl.text = (data['spotify_url'] as String?) ?? '';
        _appleMusicCtrl.text = (data['apple_music_url'] as String?) ?? '';
        _youtubeCtrl.text = (data['youtube_url'] as String?) ?? '';
        _soundcloudCtrl.text = (data['soundcloud_url'] as String?) ?? '';
        _deezerCtrl.text = (data['deezer_url'] as String?) ?? '';
        final genres = data['genres'];
        if (genres is List) {
          _selectedGenres.addAll(genres.cast<String>());
        }
        _loaded = true;
      });
    } catch (_) {
      if (mounted) setState(() => _loaded = true);
    }
  }

  @override
  void dispose() {
    _artistNameCtrl.dispose();
    _bioCtrl.dispose();
    _cityCtrl.dispose();
    _spotifyCtrl.dispose();
    _appleMusicCtrl.dispose();
    _youtubeCtrl.dispose();
    _soundcloudCtrl.dispose();
    _deezerCtrl.dispose();
    super.dispose();
  }

  Future<void> _onSave() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();
    setState(() => _saving = true);
    try {
      await ref
          .read(soundRepositoryProvider)
          .registerArtist(
            artistName: _artistNameCtrl.text.trim(),
            bio: _bioCtrl.text.trim().isEmpty ? null : _bioCtrl.text.trim(),
            city: _cityCtrl.text.trim().isEmpty ? null : _cityCtrl.text.trim(),
            countryCode: _selectedCountry ?? 'BR',
            spotifyUrl: _spotifyCtrl.text.trim().isEmpty
                ? null
                : _spotifyCtrl.text.trim(),
            appleMusicUrl: _appleMusicCtrl.text.trim().isEmpty
                ? null
                : _appleMusicCtrl.text.trim(),
            genres: _selectedGenres.toList(),
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
            S.of(context).artistProfSaveError(e.toString()),
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
            Icon(LucideIcons.music, size: 18, color: c.accentPrimary),
            const SizedBox(width: 8),
            Text(
              'Brawe Sounds',
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
                backgroundColor: c.accentPrimary,
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
      body: !_loaded
          ? Center(child: CircularProgressIndicator(color: c.accentPrimary))
          : Form(
              key: _formKey,
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + kToolbarHeight + 16,
                  bottom: MediaQuery.of(context).padding.bottom + 32,
                ),
                children: [
                  // Identidade
                  _section(
                    context: context,
                    title: s.artistProfSectionIdentity,
                    children: [
                      _field(
                        context: context,
                        icon: LucideIcons.mic,
                        label: s.artistProfArtistName,
                        child: _textField(
                          context: context,
                          ctrl: _artistNameCtrl,
                          hint: s.artistProfArtistNameHint,
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? s.artistProfRequired
                              : null,
                        ),
                      ),
                      _divider(context),
                      _field(
                        context: context,
                        icon: LucideIcons.alignLeft,
                        label: s.artistProfBio,
                        child: _textField(
                          context: context,
                          ctrl: _bioCtrl,
                          hint: s.artistProfBioHint,
                          maxLines: 3,
                          maxLength: 300,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Localização
                  _section(
                    context: context,
                    title: s.artistProfSectionLocation,
                    children: [
                      _field(
                        context: context,
                        icon: LucideIcons.globe,
                        label: s.artistProfCountry,
                        child: _dropdownField<String>(
                          context: context,
                          value: _selectedCountry,
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
                          onChanged: (v) =>
                              setState(() => _selectedCountry = v),
                          hint: s.artistProfCountryHint,
                        ),
                      ),
                      _divider(context),
                      _field(
                        context: context,
                        icon: LucideIcons.building,
                        label: s.artistProfCity,
                        child: _textField(
                          context: context,
                          ctrl: _cityCtrl,
                          hint: s.artistProfCityHint,
                        ),
                      ),
                      _divider(context),
                      _field(
                        context: context,
                        icon: LucideIcons.languages,
                        label: s.artistProfLanguage,
                        child: _dropdownField<String>(
                          context: context,
                          value: _selectedLanguage,
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
                          onChanged: (v) =>
                              setState(() => _selectedLanguage = v),
                          hint: s.artistProfLanguageHint,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Gêneros musicais
                  _section(
                    context: context,
                    title: s.artistProfSectionGenres,
                    subtitle: s.artistProfGenresHint,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(14),
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _genres.map((genre) {
                            final selected = _selectedGenres.contains(genre);
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  if (selected) {
                                    _selectedGenres.remove(genre);
                                  } else if (_selectedGenres.length < 5) {
                                    _selectedGenres.add(genre);
                                  }
                                });
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 150),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 7,
                                ),
                                decoration: BoxDecoration(
                                  color: selected
                                      ? c.accentPrimary.withValues(alpha: 0.15)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: selected
                                        ? c.accentPrimary
                                        : c.divider,
                                  ),
                                ),
                                child: Text(
                                  genre,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: selected
                                        ? FontWeight.w700
                                        : FontWeight.w400,
                                    color: selected
                                        ? c.accentPrimary
                                        : c.textSecondary,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Plataformas de streaming
                  _section(
                    context: context,
                    title: s.artistProfSectionPlatforms,
                    children: [
                      _platformRow(
                        context: context,
                        icon: LucideIcons.music,
                        label: 'Spotify',
                        ctrl: _spotifyCtrl,
                        hint: 'spotify.com/artist/...',
                      ),
                      _divider(context),
                      _platformRow(
                        context: context,
                        icon: LucideIcons.apple,
                        label: 'Apple Music',
                        ctrl: _appleMusicCtrl,
                        hint: 'music.apple.com/...',
                      ),
                      _divider(context),
                      _platformRow(
                        context: context,
                        icon: LucideIcons.globe,
                        label: 'YouTube Music',
                        ctrl: _youtubeCtrl,
                        hint: 'youtube.com/@...',
                      ),
                      _divider(context),
                      _platformRow(
                        context: context,
                        icon: LucideIcons.cloud,
                        label: 'SoundCloud',
                        ctrl: _soundcloudCtrl,
                        hint: 'soundcloud.com/...',
                      ),
                      _divider(context),
                      _platformRow(
                        context: context,
                        icon: LucideIcons.music2,
                        label: 'Deezer',
                        ctrl: _deezerCtrl,
                        hint: 'deezer.com/artist/...',
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  String _countryName(S s, String code) {
    switch (code) {
      case 'BR':
        return s.artistProfCountryBR;
      case 'PT':
        return s.artistProfCountryPT;
      case 'US':
        return s.artistProfCountryUS;
      case 'AR':
        return s.artistProfCountryAR;
      case 'MX':
        return s.artistProfCountryMX;
      case 'CO':
        return s.artistProfCountryCO;
      case 'CL':
        return s.artistProfCountryCL;
      case 'PE':
        return s.artistProfCountryPE;
      case 'UY':
        return s.artistProfCountryUY;
      case 'PY':
        return s.artistProfCountryPY;
      case 'BO':
        return s.artistProfCountryBO;
      case 'EC':
        return s.artistProfCountryEC;
      case 'VE':
        return s.artistProfCountryVE;
      case 'ES':
        return s.artistProfCountryES;
      case 'FR':
        return s.artistProfCountryFR;
      case 'DE':
        return s.artistProfCountryDE;
      case 'IT':
        return s.artistProfCountryIT;
      case 'GB':
        return s.artistProfCountryGB;
      case 'JP':
        return s.artistProfCountryJP;
      case 'KR':
        return s.artistProfCountryKR;
      case 'NG':
        return s.artistProfCountryNG;
      case 'GH':
        return s.artistProfCountryGH;
      case 'ZA':
        return s.artistProfCountryZA;
      case 'AO':
        return s.artistProfCountryAO;
      case 'MZ':
        return s.artistProfCountryMZ;
      case 'CV':
        return s.artistProfCountryCV;
      default:
        return code;
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

  Widget _dropdownField<T>({
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
