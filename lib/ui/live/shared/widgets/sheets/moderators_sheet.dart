import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/themes/brawe_colors.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../../data/services/live_moderation_service.dart';
import '../../../../../domain/models/live_moderation.dart';
import '../../../../../gen/l10n/app_localizations.dart';
import '../../../../core/themes/force_dark_theme.dart';

/// Lista de moderadores do criador, com remoção. Aberta pelo "Mais" do
/// broadcaster.
class ModeratorsSheet extends ConsumerStatefulWidget {
  const ModeratorsSheet({super.key});

  static Future<void> show(BuildContext context) {
    FocusManager.instance.primaryFocus?.unfocus();
    return showModalBottomSheet<void>(
      useRootNavigator: true,
      useSafeArea: true,
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (_) => const ForceDarkTheme(child: ModeratorsSheet()),
    );
  }

  @override
  ConsumerState<ModeratorsSheet> createState() => _ModeratorsSheetState();
}

class _ModeratorsSheetState extends ConsumerState<ModeratorsSheet> {
  List<LiveModerator>? _items;
  bool _failed = false;
  final Set<String> _removing = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final list = await ref.read(liveModerationServiceProvider).listModerators();
    if (!mounted) return;
    setState(() {
      _items = list;
      _failed = list == null;
    });
  }

  Future<void> _remove(LiveModerator m) async {
    if (!_removing.add(m.userId)) return;
    setState(() {});
    final res = await ref
        .read(liveModerationServiceProvider)
        .removeModerator(m.userId);
    if (!mounted) return;
    _removing.remove(m.userId);
    if (res == ModerationResult.ok) {
      setState(
        () => _items = _items?.where((e) => e.userId != m.userId).toList(),
      );
    } else {
      setState(() {});
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(S.of(context).modActionFailed)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final items = _items;
    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.7,
        ),
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: context.colors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Icon(
                  LucideIcons.shield,
                  color: context.colors.accentSecondary,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Text(
                  s.modModeratorsTitle,
                  style: TextStyle(
                    color: context.colors.textPrimary,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              s.modModeratorsSubtitle,
              style: TextStyle(
                color: context.colors.textPrimary.withValues(alpha: 0.6),
                fontSize: 12.5,
              ),
            ),
            const SizedBox(height: 12),
            if (items == null && !_failed)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 28),
                child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
              )
            else if (_failed)
              _Message(s.modModeratorsLoadFailed)
            else if (items!.isEmpty)
              _Message(s.modModeratorsEmpty)
            else
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: items.length,
                  itemBuilder: (_, i) {
                    final m = items[i];
                    return _ModeratorTile(
                      moderator: m,
                      busy: _removing.contains(m.userId),
                      removeLabel: s.modRemoveModerator,
                      onRemove: () => _remove(m),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 20),
    child: Text(
      text,
      style: TextStyle(
        color: context.colors.textPrimary.withValues(alpha: 0.7),
        fontSize: 13.5,
      ),
    ),
  );
}

class _ModeratorTile extends StatelessWidget {
  const _ModeratorTile({
    required this.moderator,
    required this.busy,
    required this.removeLabel,
    required this.onRemove,
  });

  final LiveModerator moderator;
  final bool busy;
  final String removeLabel;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final m = moderator;
    final avatar = m.avatarUrl;
    final name = m.name.isNotEmpty ? m.name : (m.username ?? '');
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        radius: 20,
        backgroundColor: context.colors.divider,
        backgroundImage: avatar == null
            ? null
            : ResizeImage(NetworkImage(avatar), width: 80),
        child: avatar == null
            ? Text(
                name.isEmpty ? '?' : name.characters.first.toUpperCase(),
                style: TextStyle(color: context.colors.textPrimary),
              )
            : null,
      ),
      title: Text(
        name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: context.colors.textPrimary,
          fontWeight: FontWeight.w700,
        ),
      ),
      subtitle: m.username == null
          ? null
          : Text(
              '@${m.username}',
              style: TextStyle(
                color: context.colors.textPrimary.withValues(alpha: 0.55),
              ),
            ),
      trailing: busy
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : IconButton(
              tooltip: removeLabel,
              icon: Icon(
                LucideIcons.userMinus,
                color: context.colors.textSecondary,
                size: 20,
              ),
              onPressed: onRemove,
            ),
    );
  }
}
