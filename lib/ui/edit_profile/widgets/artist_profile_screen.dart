import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/themes/app_colors.dart';
import '../../core/themes/brawe_colors.dart';
import '../../../data/repositories/profile_repository.dart';
import '../../../data/repositories/sound_repository.dart';
import '../../../gen/l10n/app_localizations.dart';

/// Tela de perfil de artista do Brawe Sounds.
/// Acessível pelo Edit Profile quando o tipo de conta é Músico.
class ArtistProfileScreen extends ConsumerStatefulWidget {
  const ArtistProfileScreen({super.key});

  @override
  ConsumerState<ArtistProfileScreen> createState() =>
      _ArtistProfileScreenState();
}

class _ArtistProfileScreenState extends ConsumerState<ArtistProfileScreen> {
  final _artistNameCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _countryCtrl = TextEditingController();
  final _spotifyCtrl = TextEditingController();
  final _appleMusicCtrl = TextEditingController();
  final _youtubeCtrl = TextEditingController();

  final Set<String> _selectedGenres = {};
  bool _saving = false;

  static const _genres = [
    'Funk',
    'Sertanejo',
    'Pagode',
    'Forró',
    'Pop',
    'Rap',
    'Eletrônico',
    'Gospel',
    'Rock',
    'MPB',
    'R&B',
    'Reggae',
    'Axé',
  ];

  @override
  void dispose() {
    _artistNameCtrl.dispose();
    _cityCtrl.dispose();
    _countryCtrl.dispose();
    _spotifyCtrl.dispose();
    _appleMusicCtrl.dispose();
    _youtubeCtrl.dispose();
    super.dispose();
  }

  Future<void> _onSave() async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      await ref
          .read(soundRepositoryProvider)
          .registerArtist(
            artistName: _artistNameCtrl.text.trim(),
            city: _cityCtrl.text.trim().isEmpty ? null : _cityCtrl.text.trim(),
            spotifyUrl: _spotifyCtrl.text.trim().isEmpty
                ? null
                : _spotifyCtrl.text.trim(),
            appleMusicUrl: _appleMusicCtrl.text.trim().isEmpty
                ? null
                : _appleMusicCtrl.text.trim(),
            genres: _selectedGenres.toList(),
            countryCode: _countryCtrl.text.trim().isEmpty
                ? 'BR'
                : _countryCtrl.text.trim(),
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Perfil de artista salvo!'),
          backgroundColor: Colors.green,
        ),
      );
      context.pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao salvar: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Perfil de Artista',
              style: TextStyle(
                color: colors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              'Seus dados musicais',
              style: TextStyle(
                color: colors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Nome artístico ──────────────────────────────────
                  _PlatformField(
                    controller: _artistNameCtrl,
                    hint: 'Nome artístico',
                    prefixIcon: Icons.mic_outlined,
                  ),
                  const SizedBox(height: 12),

                  // ── Cidade + País ────────────────────────────────────
                  Row(
                    children: [
                      Expanded(
                        child: _PlatformField(
                          controller: _cityCtrl,
                          hint: 'Cidade',
                          prefixIcon: Icons.location_on_outlined,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _PlatformField(
                          controller: _countryCtrl,
                          hint: 'País',
                          prefixIcon: Icons.language_outlined,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // ── Gêneros ──────────────────────────────────────────
                  Text(
                    'GÊNEROS',
                    style: TextStyle(
                      color: colors.textSecondary,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _genres.map((genre) {
                      final selected = _selectedGenres.contains(genre);
                      return GestureDetector(
                        onTap: () => setState(() {
                          selected
                              ? _selectedGenres.remove(genre)
                              : _selectedGenres.add(genre);
                        }),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 160),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: selected
                                ? AppColors.electricPurple.withOpacity(0.2)
                                : colors.surfaceElevated,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: selected
                                  ? AppColors.electricPurple
                                  : colors.border,
                              width: selected ? 1.5 : 1,
                            ),
                          ),
                          child: Text(
                            genre,
                            style: TextStyle(
                              color: selected
                                  ? AppColors.electricPurple
                                  : colors.textPrimary,
                              fontSize: 13,
                              fontWeight: selected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  // ── Plataformas ──────────────────────────────────────
                  Text(
                    'PLATAFORMAS',
                    style: TextStyle(
                      color: colors.textSecondary,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Spotify
                  _PlatformField(
                    controller: _spotifyCtrl,
                    hint: 'open.spotify.com/artist/...',
                    prefixIcon: Icons.music_note,
                    accentColor: const Color(0xFF1DB954),
                  ),
                  const SizedBox(height: 10),

                  // Apple Music
                  _PlatformField(
                    controller: _appleMusicCtrl,
                    hint: 'music.apple.com/artist/...',
                    prefixIcon: Icons.library_music_outlined,
                    accentColor: const Color(0xFFFC3C44),
                  ),
                  const SizedBox(height: 10),

                  // YouTube
                  _PlatformField(
                    controller: _youtubeCtrl,
                    hint: 'youtube.com/@...',
                    prefixIcon: Icons.play_arrow_rounded,
                    accentColor: const Color(0xFFFF0000),
                  ),
                ],
              ),
            ),
          ),

          // ── Botão Salvar ─────────────────────────────────────────────
          Padding(
            padding: EdgeInsets.fromLTRB(
              16,
              8,
              16,
              16 + MediaQuery.of(context).padding.bottom,
            ),
            child: SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _saving ? null : _onSave,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.mutedRed,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: _saving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Salvar alterações',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Campo de plataforma com ícone colorido ────────────────────────────────────
class _PlatformField extends StatelessWidget {
  const _PlatformField({
    required this.controller,
    required this.hint,
    required this.prefixIcon,
    this.accentColor,
  });

  final TextEditingController controller;
  final String hint;
  final IconData prefixIcon;
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceElevated,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        children: [
          if (accentColor != null)
            Container(
              width: 48,
              height: 52,
              decoration: BoxDecoration(
                color: accentColor!.withOpacity(0.15),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(11),
                  bottomLeft: Radius.circular(11),
                ),
                border: Border(right: BorderSide(color: colors.border)),
              ),
              child: Icon(prefixIcon, color: accentColor, size: 22),
            )
          else
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Icon(prefixIcon, color: colors.textSecondary, size: 20),
            ),
          Expanded(
            child: TextField(
              controller: controller,
              style: TextStyle(color: colors.textPrimary, fontSize: 14),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(
                  color: colors.textSecondary.withOpacity(0.5),
                  fontSize: 14,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
