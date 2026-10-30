import 'package:flutter/material.dart';

/// Marca Brawe (guia de marca, "Aplicações da marca"). Funciona nos temas
/// claro e escuro.
///
/// - [BraweLogo.new]: o símbolo (o "B" com as faíscas). Padrão dentro do app.
/// - [BraweLogo.wordmark]: só o nome "Brawe", tinta no claro e branco no
///   escuro. Usado no topo do feed antes de rolar; nunca ao lado do símbolo.
class BraweLogo extends StatelessWidget {
  /// Símbolo: lado da área da imagem. Nome: altura do texto.
  final double size;
  final bool _wordmark;

  const BraweLogo({super.key, this.size = 44}) : _wordmark = false;

  const BraweLogo.wordmark({super.key, this.size = 24}) : _wordmark = true;

  @override
  Widget build(BuildContext context) {
    final String asset;
    if (_wordmark) {
      asset = Theme.of(context).brightness == Brightness.dark
          ? 'assets/images/brawe_wordmark_white.png'
          : 'assets/images/brawe_wordmark.png';
    } else {
      asset = 'assets/images/brawe-icon.png';
    }
    return Semantics(
      label: 'Brawe',
      image: true,
      child: Image.asset(
        asset,
        width: _wordmark ? null : size,
        height: size,
        fit: BoxFit.contain,
        excludeFromSemantics: true,
      ),
    );
  }
}
