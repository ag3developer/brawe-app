import 'dart:ui' as ui;
import 'package:flutter/material.dart';

/// Botão circular glass (BackdropFilter blur) usado para ações soltas
/// no topo do HUD da live — ex.: more menu (⋯), close.
///
/// Tamanho fixo 34x34, ideal para barra superior compacta.
class TopHudCircleIcon extends StatelessWidget {
  const TopHudCircleIcon({
    super.key,
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipOval(
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.45),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.10),
                width: 0.5,
              ),
            ),
            child: Icon(icon, color: Colors.white, size: 18),
          ),
        ),
      ),
    );
  }
}
