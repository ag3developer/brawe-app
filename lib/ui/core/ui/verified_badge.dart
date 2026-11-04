import 'package:flutter/material.dart';

/// ✔️ Selo de conta verificada — o MESMO em todo o app (feed, comentários,
/// stories, chat, live, notificações, busca, perfil...).
///
/// Selo azul com o "check" sempre branco (um círculo branco por trás
/// preenche o recorte do ícone), então fica legível em fundo claro, escuro
/// ou sobre vídeo, sem variante por tema.
///
/// Tamanhos sugeridos: 13 em linhas de chat/listas compactas, 14 em listas,
/// 16 em títulos, 20 no cabeçalho do perfil.
class VerifiedBadge extends StatelessWidget {
  const VerifiedBadge({super.key, this.size = 14, this.gap = 4});

  final double size;

  /// Espaço à esquerda (entre o nome e o selo).
  final double gap;

  static const Color color = Color(0xFF1D9BF0);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: gap),
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: size * 0.5,
              height: size * 0.5,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
            Icon(Icons.verified, size: size, color: color),
          ],
        ),
      ),
    );
  }

  /// Para usar dentro de Text.rich / RichText.
  static InlineSpan span({double size = 13, double gap = 3}) =>
      WidgetSpan(
        alignment: PlaceholderAlignment.middle,
        child: VerifiedBadge(size: size, gap: gap),
      );
}
