import 'package:flutter/material.dart';

import '../../core/themes/app_colors.dart';
import '../../core/themes/brawe_colors.dart';

/// Paleta única da área de missões (gamificação pode ser expressiva, mas todas
/// as cores nascem aqui). Tons que existem como token vêm de `AppColors`
/// (os mesmos de `context.colors`); só a cor de ação muda entre claro e escuro
/// e por isso é lida do contexto via [QuestTonesX.questPrimary].
abstract final class QuestTones {
  // Iguais aos tokens accentGold / accentPink / accentSecondary / success.
  static const Color gold = AppColors.gold;
  static const Color pink = AppColors.brandPink;
  static const Color sky = AppColors.braweSky;
  static const Color mint = AppColors.success;

  // Tons exclusivos das missões.
  static const Color violet = Color(0xFF7C5CFF); // XP
  static const Color orchid = Color(0xFFB14DFF);
  static const Color cyan = Color(0xFF22D3EE);
  static const Color flame = Color(0xFFFF8B33);
  static const Color ember = AppColors.braweEmber;
  static const Color coral = Color(0xFFFF3D6E); // missões de live
  static const Color indigo = Color(0xFF2B1B8F); // fundo do herói
  static const Color fuchsia = AppColors.hotPink;

  // Metais dos emblemas.
  static const Color bronze = Color(0xFFCD7F32);
  static const Color bronzeDeep = Color(0xFF8B5A2B);
  static const Color silver = Color(0xFFE0E0E0);
  static const Color silverMid = Color(0xFFBDBDBD);
  static const Color silverDeep = Color(0xFF9E9E9E);
  static const Color silverDark = Color(0xFF757575);

  // Gelo / lavanda dos emblemas de sequência.
  static const Color ice = Color(0xFF7DD3FC);
  static const Color iceDeep = Color(0xFF3B82F6);
  static const Color lavender = Color(0xFFC4B5FD);
  static const Color lavenderDeep = Color(0xFF6366F1);

  /// Conteúdo sobre gradiente colorido (sempre claro, nos dois temas).
  static const Color onGradient = Colors.white;

  /// Sombra / escurecimento sobre arte.
  static const Color shade = Colors.black;

  /// Confete da celebração.
  static const List<Color> confetti = [gold, pink, cyan, violet, mint, flame];

  static const List<Color> xpGradient = [violet, cyan];
  static const List<Color> coinGradient = [gold, flame];
  static const List<Color> fireGradient = [gold, flame, coral];
}

extension QuestTonesX on BuildContext {
  /// Cor de ação do tema atual (azul claro/escuro).
  Color get questPrimary => colors.accentPrimary;

  /// Fundo do herói: do azul profundo ao céu, derivado da cor de ação.
  List<Color> get questHeroGradient => [
    QuestTones.indigo,
    colors.accentPrimary,
    AppColors.braweSky,
  ];

  /// Cinzas dos emblemas bloqueados, derivados das superfícies do tema.
  (Color, Color) get questLockedGreys => (
    Color.lerp(colors.surfaceHighest, colors.textTertiary, 0.25)!,
    Color.lerp(colors.surfaceHighest, colors.textTertiary, 0.5)!,
  );
}
