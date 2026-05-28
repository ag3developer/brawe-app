import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../gen/l10n/app_localizations.dart';
import '../../core/themes/brawe_colors.dart';
import '../utils/creator_l10n.dart';
import '../view_models/creator_network_view_model.dart';
import '../widgets/creator_state_views.dart';
import '../widgets/creator_tier_badge.dart';

class CreatorProfileSettingsScreen extends ConsumerStatefulWidget {
  const CreatorProfileSettingsScreen({super.key});

  @override
  ConsumerState<CreatorProfileSettingsScreen> createState() =>
      _CreatorProfileSettingsScreenState();
}

class _CreatorProfileSettingsScreenState
    extends ConsumerState<CreatorProfileSettingsScreen> {
  final _displayName = TextEditingController();
  final _bio = TextEditingController();
  final _category = TextEditingController();
  final _instagram = TextEditingController();
  final _tiktok = TextEditingController();
  final _youtube = TextEditingController();
  bool _badgeVisible = true;

  @override
  void dispose() {
    _displayName.dispose();
    _bio.dispose();
    _category.dispose();
    _instagram.dispose();
    _tiktok.dispose();
    _youtube.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final async = ref.watch(myCreatorProfileProvider);
    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        backgroundColor: context.colors.background,
        elevation: 0,
        title: Text(s.creatorProfileTitle),
      ),
      body: async.when(
        loading: () => const CreatorLoadingView(),
        error: (e, _) => CreatorErrorView(message: '$e'),
        data: (profile) {
          if (profile == null) {
            return CreatorEmptyState(
              icon: Icons.lock_outline_rounded,
              title: s.creatorBadgeLocked,
              subtitle: s.creatorProfileSubtitle,
            );
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
            children: [
              Center(
                child: Column(
                  children: [
                    CreatorTierBadge(tier: profile.tier, size: 64, showLabel: false),
                    const SizedBox(height: 10),
                    Text(profile.tier.name.toUpperCase(),
                        style: TextStyle(
                          color: profile.tier.color,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                          fontSize: 13,
                        )),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              Text(s.creatorProfileSubtitle,
                  style: TextStyle(
                    color: context.colors.textSecondary,
                    fontSize: 13.5,
                  )),
              const SizedBox(height: 18),
              _field(_displayName, s.creatorProfileFieldDisplayName),
              _field(_bio, s.creatorProfileFieldBio, lines: 3),
              _field(_category, s.creatorProfileFieldCategory),
              const SizedBox(height: 12),
              Text(s.creatorProfileFieldSocial,
                  style: TextStyle(
                    color: context.colors.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 13.5,
                  )),
              const SizedBox(height: 10),
              _field(_instagram, 'Instagram'),
              _field(_tiktok, 'TikTok'),
              _field(_youtube, 'YouTube'),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: _badgeVisible,
                onChanged: (v) => setState(() => _badgeVisible = v),
                title: Text(s.creatorProfileFieldBadgeVisibility,
                    style: TextStyle(color: context.colors.textPrimary)),
                activeThumbColor: context.colors.accentPrimary,
              ),
              const SizedBox(height: 18),
              FilledButton.icon(
                icon: const Icon(Icons.save_rounded),
                label: Text(s.creatorProfileSave),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(s.creatorProfileSaved)),
                  );
                },
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  backgroundColor: context.colors.accentPrimary,
                  foregroundColor: context.colors.textOnAccent,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _field(TextEditingController c, String label, {int lines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: c,
        minLines: lines,
        maxLines: lines,
        style: TextStyle(color: context.colors.textPrimary),
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: context.colors.surface,
          labelStyle: TextStyle(color: context.colors.textSecondary),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: context.colors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: context.colors.accentPrimary, width: 1.5),
          ),
        ),
      ),
    );
  }
}
