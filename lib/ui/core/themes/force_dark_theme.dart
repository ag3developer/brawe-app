import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_theme.dart';

/// Forces the dark theme for immersive media screens (lives, stories,
/// broadcasting) regardless of the user's preferred theme mode.
///
/// This is the same pattern used by Instagram, TikTok and X — content
/// pages that are dominated by media remain dark for contrast and
/// "cinema" feel, while chrome (home, settings, lists) respects the
/// user's theme preference.
class ForceDarkTheme extends StatelessWidget {
  const ForceDarkTheme({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    // Ícones claros nas barras do sistema enquanto a tela forçada escura
    // estiver por baixo delas. Sem isso, com o app no tema CLARO, o
    // AnnotatedRegion global (main.dart) deixava os ícones da status bar
    // escuros sobre o vídeo/fundo preto (Home, lives) — invisíveis. Em
    // sheets, só afeta a barra de navegação quando o sheet está sobre ela.
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.light,
        systemNavigationBarDividerColor: Colors.transparent,
      ),
      child: Theme(
        data: AppTheme.dark(),
        child: child,
      ),
    );
  }
}
