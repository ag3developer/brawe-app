import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Tema REAL do app para sheets/diálogos abertos de dentro do StoryViewer.
///
/// O visualizador é envolvido por `ForceDarkTheme` (a mídia fica escura, como
/// no Instagram), e `showModalBottomSheet`/`showDialog` capturam esse tema
/// escuro. Painéis (presente, menu, visualizações, denúncia...) NÃO são mídia:
/// devem seguir o tema escolhido pelo usuário. O Navigator raiz fica acima do
/// `ForceDarkTheme`, então o `Theme` dele é o do MaterialApp.
class StoryAppTheme extends StatelessWidget {
  const StoryAppTheme({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final data = Theme.of(Navigator.of(context, rootNavigator: true).context);
    final dark = data.brightness == Brightness.dark;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: (dark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark)
          .copyWith(
            statusBarColor: Colors.transparent,
            systemNavigationBarColor: Colors.transparent,
            systemNavigationBarDividerColor: Colors.transparent,
          ),
      child: Theme(data: data, child: child),
    );
  }
}
