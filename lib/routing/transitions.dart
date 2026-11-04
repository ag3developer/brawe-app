import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Transições padronizadas da Brawe 2026.
///
/// Use [pageWithFadeUp] para telas modais (post detail, likers).
/// Use [pageWithScaleFade] para tela imersiva (video fullscreen).
/// Use [pageWithSlideUp] para tela em "card" (composer, share sheet fullscreen).
class BraweTransitions {
  BraweTransitions._();

  static const _fast = Duration(milliseconds: 220);
  static const _normal = Duration(milliseconds: 320);

  /// Fade + slide-up suave (12px). Ideal para detalhes.
  static CustomTransitionPage<T> fadeUp<T>({
    required LocalKey? key,
    required Widget child,
    Duration duration = _fast,
  }) {
    return CustomTransitionPage<T>(
      key: key,
      child: child,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondary, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );
        return FadeTransition(
          opacity: curved,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.04),
              end: Offset.zero,
            ).animate(curved),
            child: child,
          ),
        );
      },
    );
  }

  /// Scale (0.96 → 1.0) + fade. Para vídeo fullscreen / lightbox.
  static CustomTransitionPage<T> scaleFade<T>({
    required LocalKey? key,
    required Widget child,
    Duration duration = _normal,
  }) {
    return CustomTransitionPage<T>(
      key: key,
      child: child,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      opaque: true,
      barrierColor: Colors.black,
      transitionsBuilder: (context, animation, secondary, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutExpo,
          reverseCurve: Curves.easeInCubic,
        );
        return FadeTransition(
          opacity: curved,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.94, end: 1.0).animate(curved),
            child: child,
          ),
        );
      },
    );
  }

  /// Slide vertical inteiro (estilo iOS modal). Para composer / sheets full.
  static CustomTransitionPage<T> slideUp<T>({
    required LocalKey? key,
    required Widget child,
    Duration duration = _normal,
  }) {
    return CustomTransitionPage<T>(
      key: key,
      child: child,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondary, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).animate(curved),
          child: child,
        );
      },
    );
  }
}
