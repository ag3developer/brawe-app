import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/themes/app_colors.dart';
import '../../core/ui/app_radius.dart';
import '../../core/ui/app_snackbar.dart';
import '../../core/ui/app_spacing.dart';
import '../view_models/live_feed_view_model.dart';
import '../view_models/start_live_view_model.dart';

class StartLiveScreen extends ConsumerWidget {
  const StartLiveScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(startLiveViewModelProvider);
    final notifier = ref.read(startLiveViewModelProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.nearBlack,
      appBar: AppBar(
        title: const Text('Go Live'),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          const _StartLiveHeader(),
          const SizedBox(height: AppSpacing.xl),
          _StartLiveTextField(
            label: 'Live title',
            hintText: 'What are you streaming?',
            onChanged: notifier.updateTitle,
            enabled: !state.status.isLoading,
          ),
          const SizedBox(height: AppSpacing.md),
          _StartLiveTextField(
            label: 'Description (optional)',
            hintText: 'Tell viewers what to expect',
            maxLines: 3,
            onChanged: notifier.updateDescription,
            enabled: !state.status.isLoading,
          ),
          const SizedBox(height: AppSpacing.md),
          _StartLiveTextField(
            label: 'Category (optional)',
            hintText: 'Gaming, Music, Talk...',
            onChanged: notifier.updateCategory,
            enabled: !state.status.isLoading,
          ),
          const SizedBox(height: AppSpacing.md),
          SwitchListTile.adaptive(
            value: state.isPrivate,
            onChanged: state.status.isLoading ? null : notifier.togglePrivacy,
            activeThumbColor: AppColors.electricPurple,
            contentPadding: EdgeInsets.zero,
            title: const Text(
              'Private live',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: const Text(
              'Only invited viewers can access this live.',
              style: TextStyle(color: AppColors.coolGray),
            ),
          ),
          if (state.errorMessage != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              state.errorMessage!,
              style: const TextStyle(color: AppColors.mutedRed),
            ),
          ],
          const SizedBox(height: AppSpacing.xl),
          FilledButton.icon(
            onPressed: state.canSubmit
                ? () => _onStartLive(context, ref)
                : null,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.electricPurple,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
            ),
            icon: state.status.isLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.sensors),
            label: Text(state.status.isLoading ? 'Starting...' : 'Start live'),
          ),
        ],
      ),
    );
  }

  Future<void> _onStartLive(BuildContext context, WidgetRef ref) async {
    final success = await ref
        .read(startLiveViewModelProvider.notifier)
        .submit();
    if (!context.mounted) {
      return;
    }

    if (!success) {
      final error = ref.read(startLiveViewModelProvider).errorMessage;
      if (error != null) {
        AppSnackBar.showError(context, error);
      }
      return;
    }

    final room = ref.read(startLiveViewModelProvider).status.asData?.value;
    ref.invalidate(liveFeedViewModelProvider);
    AppSnackBar.showSuccess(
      context,
      room == null
          ? 'Live started successfully.'
          : '"${room.title}" is now live.',
    );
    context.go('/live');
  }
}

class _StartLiveHeader extends StatelessWidget {
  const _StartLiveHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.deepBlue.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: Colors.white12),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Start your broadcast',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: AppSpacing.xs),
          Text(
            'We will create your room and immediately set it to live.',
            style: TextStyle(color: AppColors.coolGray),
          ),
        ],
      ),
    );
  }
}

class _StartLiveTextField extends StatelessWidget {
  const _StartLiveTextField({
    required this.label,
    required this.hintText,
    required this.onChanged,
    required this.enabled,
    this.maxLines = 1,
  });

  final String label;
  final String hintText;
  final ValueChanged<String> onChanged;
  final bool enabled;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return TextField(
      enabled: enabled,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        labelStyle: const TextStyle(color: AppColors.coolGray),
        hintStyle: TextStyle(color: AppColors.coolGray.withValues(alpha: 0.7)),
        filled: true,
        fillColor: AppColors.slate.withValues(alpha: 0.6),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
