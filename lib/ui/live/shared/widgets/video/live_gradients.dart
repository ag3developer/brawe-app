import 'package:flutter/material.dart';

/// Gradiente preto→transparente no topo da tela para garantir legibilidade
/// do HUD (avatar, pílulas) sobre qualquer vídeo claro.
///
/// Use no Stack imediatamente após o vídeo, antes dos HUDs.
class LiveTopGradient extends StatelessWidget {
  const LiveTopGradient({super.key});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        height: 200,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black54, Colors.transparent],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
      ),
    );
  }
}

/// Gradiente transparente→preto na base da tela para garantir legibilidade
/// do chat ticker, bottom bar e pinned product sobre qualquer vídeo.
class LiveBottomGradient extends StatelessWidget {
  const LiveBottomGradient({super.key});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          height: 280,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.transparent, Colors.black87],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: [0.0, 1.0],
            ),
          ),
        ),
      ),
    );
  }
}
