import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../data/repositories/sound_repository.dart';
import '../../../gen/l10n/app_localizations.dart';
import '../../core/themes/app_colors.dart';
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

  // Países disponíveis (ISO 3166-1 alpha-2)
  static const _countries = [
    ('BR', '🇧🇷 Brasil'),
    ('PT', '🇵🇹 Portugal'),
    ('US', '🇺🇸 Estados Unidos'),
    ('AR', '🇦🇷 Argentina'),
    ('MX', '🇲🇽 México'),
    ('CO', '🇨🇴 Colômbia'),
    ('CL', '🇨🇱 Chile'),
    ('PE', '🇵🇪 Peru'),
    ('UY', '🇺🇾 Uruguai'),
    ('PY', '🇵🇾 Paraguai'),
    ('BO', '🇧🇴 Bolívia'),
    ('EC', '🇪🇨 Equador'),
    ('VE', '🇻🇪 Venezuela'),
    ('ES', '🇪🇸 Espanha'),
    ('FR', '🇫🇷 França'),
    ('DE', '🇩🇪 Alemanha'),
    ('IT', '🇮🇹 Itália'),
    ('GB', '🇬🇧 Reino Unido'),
    ('JP', '🇯🇵 Japão'),
    ('KR', '🇰🇷 Coreia do Sul'),
    ('NG', '🇳🇬 Nigéria'),
    ('GH', '🇬🇭 Gana'),
    ('ZA', '🇿🇦 África do Sul'),
    ('AO', '🇦🇴 Angola'),
    ('MZ', '🇲🇿 Moçambique'),
    ('CV', '🇨🇻 Cabo Verde'),
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
    'Funk', 'Sertanejo', 'Pagode', 'Forró', 'Pop', 'Rap', 'Hip-Hop',
    'Eletrônico', 'Gospel', 'Rock', 'MPB', 'R&B', 'Reggae', 'Axé',
    'Baile Funk', 'Trap', 'Afrobeats', 'K-Pop', 'Jazz', 'Bossa Nova',
    'Soul', 'Blues', 'Country', 'Metal', 'Indie', 'Lo-fi', 'Classical',
    'Salsa', 'Merengue', 'Cumbia', 'Reggaeton',
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
      final raw =
          await ref.read(soundRepositoryProvider).getMyArtistProfile();
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
      await ref.read(soundRepositoryProvider).registerArtist(
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
          content: Row(children: [
            const Icon(LucideIcons.checkCircle, color: Colors.white, size: 16),
            const SizedBox(width: 8),
            Text(S.of(context).editProfileSaved),
          ]),
          backgroundColor: Colors.green.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
            const Icon(LucideIcons.music, size: 18, color: Color(0xFFEC4899)),
            const SizedBox(width: 8),
            Text('Brawe Sounds',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: context.colors.textPrimary,
                )),
          ],
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: FilledButton(
              onPressed: _saving ? null : _onSave,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFEC4899),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                minimumSize: Size.zero,
              ),
              child: _saving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : Text(s.editProfileSave,
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
      body: !_loaded
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFEC4899)))
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
                    isDark: isDark,
                    icon: LucideIcons.user,
                    color: const Color(0xFFEC4899),
                    title: 'Identidade artística',
                    children: [
                      _field(
                        context: context,
                        icon: LucideIcons.mic,
                        label: 'Nome artístico',
                        child: _textField(
                          ctrl: _artistNameCtrl,
                          hint: 'Como você é conhecido',
                          validator: (v) =>
                              (v == null || v.trim().isEmpty) ? 'Obrigatório' : null,
                        ),
                      ),
                      _divider(context),
                      _field(
                        context: context,
                        icon: LucideIcons.alignLeft,
                        label: 'Bio do artista',
                        child: _textField(
                          ctrl: _bioCtrl,
                          hint: 'Conte sua história musical...',
                          maxLines: 3,
                          maxLength: 300,
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
                    color: const Color(0xFFEC4899),
                    title: 'Localização',
                    children: [
                      _field(
                        context: context,
                        icon: LucideIcons.globe,
                        label: 'País',
                        child: _dropdownField<String>(
                          context: context,
                          isDark: isDark,
                          value: _selectedCountry,
                          items: _countries
                              .map((c) => DropdownMenuItem(
                                    value: c.$1,
                                    child: Text(c.$2,
                                        style: TextStyle(
                                            fontSize: 15,
                                            color: context.colors.textPrimary)),
                                  ))
                              .toList(),
                          onChanged: (v) => setState(() => _selectedCountry = v),
                          hint: 'Selecione seu país',
                        ),
                      ),
                      _divider(context),
                      _field(
                        context: context,
                        icon: LucideIcons.building,
                        label: 'Cidade',
                        child: _textField(
                          ctrl: _cityCtrl,
                          hint: 'Sua cidade',
                        ),
                      ),
                      _divider(context),
                      _field(
                        context: context,
                        icon: LucideIcons.languages,
                        label: 'Idioma nativo',
                        child: _dropdownField<String>(
                          context: context,
                          isDark: isDark,
                          value: _selectedLanguage,
                          items: _languages
                              .map((l) => DropdownMenuItem(
                                    value: l.$1,
                                    child: Text(l.$2,
                                        style: TextStyle(
                                            fontSize: 15,
                                            color: context.colors.textPrimary)),
                                  ))
                              .toList(),
                          onChanged: (v) =>
                              setState(() => _selectedLanguage = v),
                          hint: 'Idioma principal',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Gêneros musicais
                  _sectionWithContent(
                    context: context,
                    isDark: isDark,
                    icon: LucideIcons.music2,
                    color: const Color(0xFFEC4899),
                    title: 'Gêneros musicais',
                    subtitle: 'Selecione até 5 gêneros',
                    content: Padding(
                      padding: const EdgeInsets.fromLTRB(14, 4, 14, 14),
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
                                  horizontal: 12, vertical: 7),
                              decoration: BoxDecoration(
                                color: selected
                                    ? const Color(0xFFEC4899)
                                        .withValues(alpha: 0.15)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: selected
                                      ? const Color(0xFFEC4899)
                                      : context.colors.divider,
                                  width: selected ? 1.5 : 1,
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
                                      ? const Color(0xFFEC4899)
                                      : context.colors.textSecondary,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Plataformas de streaming
                  _section(
                    context: context,
                    isDark: isDark,
                    icon: LucideIcons.headphones,
                    color: const Color(0xFFEC4899),
                    title: 'Plataformas de streaming',
                    children: [
                      _platformRow(
                        context: context,
                        icon: LucideIcons.music,
                        color: const Color(0xFF1DB954),
                        label: 'Spotify',
                        ctrl: _spotifyCtrl,
                        hint: 'spotify.com/artist/...',
                      ),
                      _divider(context),
                      _platformRow(
                        context: context,
                        icon: LucideIcons.apple,
                        color: const Color(0xFFFC3C44),
                        label: 'Apple Music',
                        ctrl: _appleMusicCtrl,
                        hint: 'music.apple.com/...',
                      ),
                      _divider(context),
                      _platformRow(
                        context: context,
                        icon: LucideIcons.youtube,
                        color: const Color(0xFFFF0000),
                        label: 'YouTube Music',
                        ctrl: _youtubeCtrl,
                        hint: 'youtube.com/@...',
                      ),
                      _divider(context),
                      _platformRow(
                        context: context,
                        icon: LucideIcons.cloud,
                        color: const Color(0xFFFF5500),
                        label: 'SoundCloud',
                        ctrl: _soundcloudCtrl,
                        hint: 'soundcloud.com/...',
                      ),
                      _divider(context),
                      _platformRow(
                        context: context,
                        icon: LucideIcons.music2,
                        color: const Color(0xFF00C7F2),
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
            child: Row(children: [
              Icon(icon, size: 13, color: color),
              const SizedBox(width: 6),
              Text(title.toUpperCase(),
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                      color: context.colors.textTertiary)),
            ]),
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
                      : Colors.black.withValues(alpha: 0.06)),
            ),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }

  Widget _sectionWithContent({
    required BuildContext context,
    required bool isDark,
    required IconData icon,
    required Color color,
    required String title,
    String? subtitle,
    required Widget content,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Row(children: [
              Icon(icon, size: 13, color: color),
              const SizedBox(width: 6),
              Text(title.toUpperCase(),
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                      color: context.colors.textTertiary)),
              if (subtitle != null) ...[
                const SizedBox(width: 6),
                Text('· $subtitle',
                    style: TextStyle(
                        fontSize: 11, color: context.colors.textTertiary)),
              ],
            ]),
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
                      : Colors.black.withValues(alpha: 0.06)),
            ),
            child: content,
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
                Text(label,
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: context.colors.textTertiary,
                        letterSpacing: 0.2)),
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
    required TextEditingController ctrl,
    required String hint,
    int maxLines = 1,
    int? maxLength,
    String? prefixText,
    String? Function(String?)? validator,
  }) {
    return Builder(builder: (context) {
      return TextFormField(
        controller: ctrl,
        maxLines: maxLines,
        maxLength: maxLength,
        validator: validator,
        style: TextStyle(
            fontSize: 15, color: context.colors.textPrimary, fontWeight: FontWeight.w400),
        decoration: InputDecoration(
          hintText: hint,
          prefixText: prefixText,
          prefixStyle: TextStyle(
              fontSize: 14,
              color: context.colors.textTertiary,
              fontWeight: FontWeight.w500),
          hintStyle: TextStyle(
              fontSize: 15,
              color: context.colors.textTertiary.withValues(alpha: 0.5)),
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
    });
  }

  Widget _dropdownField<T>({
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
      dropdownColor: isDark
          ? const Color(0xFF1A1A2E)
          : Colors.white,
      style: TextStyle(fontSize: 15, color: context.colors.textPrimary),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
            fontSize: 15,
            color: context.colors.textTertiary.withValues(alpha: 0.5)),
        isDense: true,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 4),
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
      ),
      icon: Icon(LucideIcons.chevronDown,
          size: 16, color: context.colors.textTertiary),
    );
  }

  Widget _divider(BuildContext context) => Divider(
        height: 1,
        indent: 42,
        color: context.colors.divider.withValues(alpha: 0.5),
      );
}
