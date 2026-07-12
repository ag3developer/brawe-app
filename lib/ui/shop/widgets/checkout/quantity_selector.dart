import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/themes/brawe_colors.dart';

/// Compact `− N +` quantity stepper used in the checkout product item.
///
/// The minus button is disabled at [minQuantity] (default 1) and the plus
/// button is disabled at [maxQuantity] (stock limit) when provided.
class QuantitySelector extends StatelessWidget {
  final int quantity;
  final int minQuantity;
  final int? maxQuantity;
  final bool enabled;
  final ValueChanged<int> onChanged;

  const QuantitySelector({
    super.key,
    required this.quantity,
    required this.onChanged,
    this.minQuantity = 1,
    this.maxQuantity,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final canDecrease = enabled && quantity > minQuantity;
    final canIncrease =
        enabled && (maxQuantity == null || quantity < maxQuantity!);

    return Container(
      height: 28,
      decoration: BoxDecoration(
        border: Border.all(color: context.colors.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StepButton(
            icon: LucideIcons.minus,
            enabled: canDecrease,
            onTap: () => onChanged(quantity - 1),
          ),
          SizedBox(
            width: 30,
            child: Center(
              child: Text(
                '$quantity',
                style: TextStyle(
                  color: context.colors.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          ),
          _StepButton(
            icon: LucideIcons.plus,
            enabled: canIncrease,
            onTap: () => onChanged(quantity + 1),
          ),
        ],
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  const _StepButton({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled ? onTap : null,
      child: SizedBox(
        width: 26,
        height: 26,
        child: Icon(
          icon,
          size: 13,
          color: enabled
              ? context.colors.textPrimary
              : context.colors.textTertiary,
        ),
      ),
    );
  }
}
