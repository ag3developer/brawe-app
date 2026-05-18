import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/themes/brawe_colors.dart';
import 'common/auth_action_button.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  late final AnimationController _orbitController;
  late final AnimationController _entryController;
  late final Animation<double> _fadeIn;
  late final Animation<double> _scaleIn;

  // Cada ícone tem posição angular, raio, tamanho e velocidade próprios
  static const _icons = [
    _FloatingIconData(icon: Icons.videocam_rounded,         angle: 0.0,   radius: 0.38, size: 22, speed: 1.0,  opacity: 0.85),
    _FloatingIconData(icon: Icons.music_note_rounded,       angle: 0.52,  radius: 0.42, size: 18, speed: 0.7,  opacity: 0.7),
    _FloatingIconData(icon: Icons.live_tv_rounded,          angle: 1.05,  radius: 0.36, size: 20, speed: 1.2,  opacity: 0.9),
    _FloatingIconData(icon: Icons.favorite_rounded,         angle: 1.67,  radius: 0.44, size: 16, speed: 0.9,  opacity: 0.65),
    _FloatingIconData(icon: Icons.photo_camera_rounded,     angle: 2.20,  radius: 0.40, size: 22, speed: 0.8,  opacity: 0.8),
    _FloatingIconData(icon: Icons.chat_bubble_rounded,      angle: 2.72,  radius: 0.37, size: 17, speed: 1.1,  opacity: 0.7),
    _FloatingIconData(icon: Icons.star_rounded,             angle: 3.35,  radius: 0.43, size: 16, speed: 0.75, opacity: 0.6),
    _FloatingIconData(icon: Icons.people_alt_rounded,       angle: 3.87,  radius: 0.39, size: 20, speed: 1.05, opacity: 0.8),
    _FloatingIconData(icon: Icons.trending_up_rounded,      angle: 4.40,  radius: 0.45, size: 17, speed: 0.85, opacity: 0.65),
    _FloatingIconData(icon: Icons.mic_rounded,              angle: 4.92,  radius: 0.38, size: 19, speed: 1.15, opacity: 0.75),
    _FloatingIconData(icon: Icons.shopping_bag_rounded,     angle: 5.45,  radius: 0.41, size: 18, speed: 0.95, opacity: 0.7),
    _FloatingIconData(icon: Icons.emoji_events_rounded,     angle: 5.97,  radius: 0.44, size: 16, speed: 1.0,  opacity: 0.6),
  ];

  @override
  void initState() {
    super.initState();
    _orbitController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 28),
    )..repeat();

    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _fadeIn = CurvedAnimation(parent: _entryController, curve: Curves.easeOut);
    _scaleIn = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _entryController, curve: Curves.easeOutBack),
    );

    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _entryController.forward();
    });
  }

  @override
  void dispose() {
    _orbitController.dispose();
    _entryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Ícones orbitando ─────────────────────────────────────────
          AnimatedBuilder(
            animation: _orbitController,
            builder: (context, _) {
              return Stack(
                children: _icons.map((data) {
                  final angle = data.angle +
                      _orbitController.value * 2 * math.pi * data.speed;
                  // Raio adaptado ao tamanho da tela
                  final r = size.shortestSide * data.radius;
                  final cx = size.width / 2 + math.cos(angle) * r;
                  final cy = size.height * 0.42 + math.sin(angle) * r * 0.55;

                  // Pulso sutil de opacidade
                  final pulse = 0.6 +
                      0.4 *
                          math.sin(
                              _orbitController.value * 2 * math.pi * 2 +
                                  data.angle);

                  return Positioned(
                    left: cx - data.size / 2,
                    top: cy - data.size / 2,
                    child: Opacity(
                      opacity: (data.opacity * pulse).clamp(0.0, 1.0),
                      child: Icon(
                        data.icon,
                        size: data.size.toDouble(),
                        color: colors.accentPrimary,
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),

          // ── Glow central sutil ────────────────────────────────────────
          Positioned(
            left: size.width / 2 - 160,
            top: size.height * 0.42 - 160,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    colors.accentPrimary.withValues(alpha: 0.12),
                    colors.accentPrimary.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),

          // ── Logo + conteúdo central ──────────────────────────────────
          SafeArea(
            child: FadeTransition(
              opacity: _fadeIn,
              child: ScaleTransition(
                scale: _scaleIn,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Column(
                    children: [
                      // Logo no centro vertical
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Logo — já contém o nome BRAWE
                            Image.asset(
                              'assets/images/brawe_logo.png',
                              width: 140,
                              height: 140,
                              color: colors.textPrimary,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Conecte. Transmita. Cresça.',
                              style: TextStyle(
                                color: colors.textSecondary,
                                fontSize: 15,
                                fontWeight: FontWeight.w400,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // ── Botões na base ─────────────────────────────────
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          AuthActionButton(
                            label: 'Criar conta',
                            onPressed: () => context.push('/signup'),
                          ),
                          const SizedBox(height: 12),
                          _OutlineBtn(
                            label: 'Já tenho uma conta',
                            onTap: () => context.push('/login'),
                          ),
                          const SizedBox(height: 28),
                          Center(
                            child: Text(
                              'Ao continuar você aceita os Termos de Uso.',
                              style: TextStyle(
                                color: colors.textTertiary,
                                fontSize: 11,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Botão outline limpo ───────────────────────────────────────────────────────
class _OutlineBtn extends StatelessWidget {
  const _OutlineBtn({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colors.border),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: colors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Dados de cada ícone flutuante ─────────────────────────────────────────────
class _FloatingIconData {
  const _FloatingIconData({
    required this.icon,
    required this.angle,
    required this.radius,
    required this.size,
    required this.speed,
    required this.opacity,
  });
  final IconData icon;
  final double angle;  // ângulo inicial em radianos
  final double radius; // fração da shortestSide
  final int size;
  final double speed;  // multiplicador de velocidade orbital
  final double opacity;
}