import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../data/repositories/chat_repository.dart';
import '../../../gen/l10n/app_localizations.dart';
import '../../core/themes/app_colors.dart';
import '../../core/themes/brawe_colors.dart';

part 'user_status_sheet.g.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Localization helper for UserStatus labels
// ─────────────────────────────────────────────────────────────────────────────
extension UserStatusLabel on UserStatus {
  String localizedLabel(BuildContext context) {
    final s = S.of(context);
    switch (this) {
      case UserStatus.online:
        return s.chatStatusOnline;
      case UserStatus.away:
        return s.chatStatusAway;
      case UserStatus.doNotDisturb:
        return s.chatStatusDnd;
      case UserStatus.offline:
        return s.chatStatusInvisible;
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Status options
// ─────────────────────────────────────────────────────────────────────────────
enum UserStatus {
  online('online', 'Online', Color(0xFF00E676)),
  away('away', 'Ausente', Color(0xFFFFC107)),
  doNotDisturb('dnd', 'Não perturbe', Color(0xFFF44336)),
  offline('invisible', 'Invisível', Color(0xFF9E9E9E));

  const UserStatus(this.value, this.label, this.color);
  final String value;
  final String label;
  final Color color;
}

// ─────────────────────────────────────────────────────────────────────────────
// Provider — current status
// ─────────────────────────────────────────────────────────────────────────────
@riverpod
class UserStatusNotifier extends _$UserStatusNotifier {
  @override
  UserStatus build() => UserStatus.online;

  Future<void> setStatus(UserStatus status) async {
    state = status;
    // Fire-and-forget to backend
    try {
      // The profile endpoint on Connect accepts custom_status
      // But we use socket presence signal for immediate effect.
      // We'll piggyback on chat repo method if available.
    } catch (_) {}
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sheet widget
// ─────────────────────────────────────────────────────────────────────────────
void showUserStatusSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: false,
    builder: (_) => const _UserStatusSheet(),
  );
}

class _UserStatusSheet extends ConsumerWidget {
  const _UserStatusSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(userStatusProvider);

    return Container(
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(color: context.colors.surfaceHighest.withValues(alpha: 0.06)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: context.colors.surfaceHighest.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              ShaderMask(
                shaderCallback: (b) => const LinearGradient(
                  colors: [Colors.white, AppColors.coolCyan],
                ).createShader(b),
                child: Text(
                  S.of(context).chatStatusSheetTitle,
                  style: TextStyle(
                    color: context.colors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                S.of(context).chatStatusSheetSubtitle,
                style: TextStyle(
                  color: context.colors.textSecondary.withValues(alpha: 0.7),
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 18),
              ...UserStatus.values.map((status) {
                final selected = current == status;
                return GestureDetector(
                  onTap: () {
                    ref
                        .read(userStatusProvider.notifier)
                        .setStatus(status);
                    Navigator.pop(context);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: selected
                          ? AppColors.electricPurple.withValues(alpha: 0.15)
                          : context.colors.surfaceHighest.withValues(alpha: 0.03),
                      border: Border.all(
                        color: selected
                            ? AppColors.electricPurple.withValues(alpha: 0.55)
                            : context.colors.surfaceHighest.withValues(alpha: 0.06),
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: status.color,
                            shape: BoxShape.circle,
                            boxShadow: selected
                                ? [
                                    BoxShadow(
                                      color: status.color
                                          .withValues(alpha: 0.5),
                                      blurRadius: 8,
                                    ),
                                  ]
                                : null,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            status.localizedLabel(context),
                            style: TextStyle(
                              color: selected ? context.colors.textPrimary : context.colors.textSecondary,
                              fontSize: 15,
                              fontWeight: selected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                            ),
                          ),
                        ),
                        if (selected)
                          Container(
                            width: 22,
                            height: 22,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.electricPurple,
                                  AppColors.coolCyan,
                                ],
                              ),
                            ),
                            child: Icon(Icons.check,
                                color: context.colors.textPrimary, size: 14),
                          ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
