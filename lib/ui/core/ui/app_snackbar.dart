import 'package:flutter/material.dart';
import '../themes/app_colors.dart';

class AppSnackBar {
  const AppSnackBar._();

  static void showSuccess(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.check_circle_outline,
              color: AppColors.coolCyan,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
      ),
    );
  }

  static void showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.mutedRed.withValues(alpha: 0.95),
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(message, style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  /// Aviso "ambíguo" — operação pode ter dado certo ou não, mas o
  /// resultado é incerto (timeouts, conexão dropou). Visual amarelo
  /// para diferenciar do vermelho de erro hard.
  ///
  /// Usado p.ex. quando o upload de story dá timeout: o backend pode
  /// ter persistido OK, então mostrar "FALHA" (vermelho) seria mentira
  /// e induziria o usuário a tentar de novo, criando duplicatas.
  static void showWarning(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFFD97706).withValues(alpha: 0.95),
        content: Row(
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(message, style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
        duration: const Duration(seconds: 4),
      ),
    );
  }
}
