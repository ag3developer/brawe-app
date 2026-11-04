import 'package:flutter/material.dart';

/// Catálogo central de ilustrações 3D da Brawe.
///
/// Cada asset tem 3 densidades (1x/2x/3x) em
/// `assets/images/illustrations/`, resolvidas automaticamente
/// pelo Flutter para Android e iOS.
enum BraweIllustration {
  wallet('wallet_3d.png'),
  coin('coin_3d.png'),
  diamond('diamond_3d.png'),
  gift('gift_3d.png'),
  package('package_3d.png'),
  shield('shield_3d.png'),
  bell('bell_3d.png'),
  chart('chart_3d.png'),
  trophy('trophy_3d.png'),
  microphone('microphone_3d.png'),
  avatar('avatar_3d.png'),
  master('master_3d.png');

  const BraweIllustration(this._file);
  final String _file;

  String get path => 'assets/images/illustrations/$_file';

  ImageProvider get provider => AssetImage(path);
}

/// Widget para renderizar uma [BraweIllustration] com tamanho e
/// halo opcional. Use em headers de telas (wallet, quests, packages…).
class BraweIllustrationView extends StatelessWidget {
  const BraweIllustrationView(
    this.illustration, {
    super.key,
    this.size = 140,
    this.haloColor,
    this.semanticLabel,
  });

  final BraweIllustration illustration;
  final double size;
  final Color? haloColor;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final halo = haloColor;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (halo != null)
            Container(
              width: size * 0.92,
              height: size * 0.92,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    halo.withValues(alpha: 0.35),
                    halo.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          Image.asset(
            illustration.path,
            width: size,
            height: size,
            fit: BoxFit.contain,
            semanticLabel: semanticLabel,
            filterQuality: FilterQuality.high,
          ),
        ],
      ),
    );
  }
}
