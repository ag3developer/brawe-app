import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../core/themes/app_colors.dart';
import '../../core/ui/app_radius.dart';
import '../../core/ui/app_snackbar.dart';
import '../../core/ui/app_spacing.dart';
import '../view_models/start_live_view_model.dart';

class StartLiveScreen extends ConsumerWidget {
  const StartLiveScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(startLiveViewModelProvider);
    final notifier = ref.read(startLiveViewModelProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.midnightBlue,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Go Live'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          const _StartLiveHeader(),
          const SizedBox(height: AppSpacing.xl),
          _StartLiveTextField(
            label: 'Live Title',
            hintText: 'Enter a catchy title for your live',
            onChanged: notifier.updateTitle,
            enabled: !state.status.isLoading,
          ),
          const SizedBox(height: AppSpacing.md),
          _StartLiveCategoryPicker(
            value: state.category.isEmpty ? null : state.category,
            onChanged: state.status.isLoading
                ? null
                : (value) => notifier.updateCategory(value ?? ''),
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
                : const Icon(Icons.add_box_outlined),
            label: Text(state.status.isLoading ? 'Creating...' : 'Create live'),
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
    if (room == null) {
      AppSnackBar.showError(context, 'Failed to retrieve live room details.');
      return;
    }

    context.go('/live/broadcast', extra: room);
  }
}

class _StartLiveHeader extends StatelessWidget {
  const _StartLiveHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.electricPurple.withValues(alpha: 0.1),
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.electricPurple.withValues(alpha: 0.2),
              width: 2,
            ),
          ),
          child: const Icon(
            Icons.videocam_rounded,
            color: AppColors.electricPurple,
            size: 40,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          'Start a Live Stream',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Share your moments with your followers',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: AppColors.coolGray),
        ),
      ],
    );
  }
}

class _StartLiveTextField extends StatelessWidget {
  const _StartLiveTextField({
    required this.label,
    required this.hintText,
    required this.onChanged,
    this.enabled = true,
  });

  final String label;
  final String hintText;
  final ValueChanged<String> onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: textTheme.labelLarge?.copyWith(
            color: AppColors.coolGray,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        TextField(
          onChanged: onChanged,
          enabled: enabled,
          style: textTheme.bodyLarge?.copyWith(color: Colors.white),
          cursorColor: AppColors.electricPurple,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: textTheme.bodyMedium?.copyWith(
              color: AppColors.coolGray.withValues(alpha: 0.5),
            ),
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.05),
            contentPadding: const EdgeInsets.all(AppSpacing.md),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: BorderSide(
                color: Colors.white.withValues(alpha: 0.1),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: BorderSide(
                color: Colors.white.withValues(alpha: 0.1),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: const BorderSide(
                color: AppColors.electricPurple,
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _StartLiveCategoryPicker extends StatelessWidget {
  const _StartLiveCategoryPicker({
    required this.value,
    required this.onChanged,
    this.enabled = true,
  });

  final String? value;
  final ValueChanged<String?>? onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Category',
          style: textTheme.labelLarge?.copyWith(
            color: AppColors.coolGray,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        DropdownButtonFormField<String>(
          initialValue: value,
          onChanged: enabled ? onChanged : null,
          dropdownColor: AppColors.midnightBlue,
          style: textTheme.bodyLarge?.copyWith(color: Colors.white),
          icon: const Icon(
            Icons.keyboard_arrow_down,
            color: AppColors.coolGray,
          ),
          decoration: InputDecoration(
            hintText: 'Select a category',
            hintStyle: textTheme.bodyMedium?.copyWith(
              color: AppColors.coolGray.withValues(alpha: 0.5),
            ),
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.05),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: BorderSide(
                color: Colors.white.withValues(alpha: 0.1),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: BorderSide(
                color: Colors.white.withValues(alpha: 0.1),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: const BorderSide(
                color: AppColors.electricPurple,
                width: 1.5,
              ),
            ),
          ),
          items: AppConstants.categories.map((category) {
            return DropdownMenuItem(value: category, child: Text(category));
          }).toList(),
        ),
      ],
    );
  }
}
