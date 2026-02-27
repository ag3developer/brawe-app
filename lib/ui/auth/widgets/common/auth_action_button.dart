import 'package:flutter/material.dart';
import '../../../core/themes/app_colors.dart';
import '../../../core/ui/app_radius.dart';

class AuthActionButton extends StatelessWidget {
  const AuthActionButton({super.key, required this.label, required this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = onPressed == null;
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient:
              !isDisabled
                  ? const LinearGradient(
                    colors: [AppColors.electricPurple, AppColors.softViolet],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  )
                  : null,
          color: isDisabled ? Colors.white.withValues(alpha: 0.1) : null,
          borderRadius: BorderRadius.circular(AppRadius.md),
          boxShadow:
              !isDisabled
                  ? [
                    BoxShadow(
                      color: AppColors.electricPurple.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ]
                  : null,
        ),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            elevation: 0,
            padding: EdgeInsets.zero,
          ),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }
}
