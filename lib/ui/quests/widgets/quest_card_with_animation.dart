import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/models/quest.dart';
import '../../../gen/l10n/app_localizations.dart';
import '../../core/themes/brawe_colors.dart';
import '../view_models/quests_view_model.dart';
import 'level_up_celebration.dart';
import 'reward_collection_animation.dart';

/// Wrapper que adiciona a animação de coleta de recompensa ao card de quest.
///
/// Coordena:
/// - Animação de sucesso (partículas + contador)
/// - Level up celebration (se aplicável)
/// - Fallback para redução de movimento
/// - Integração com o view model
class QuestCardWithAnimation extends ConsumerStatefulWidget {
  final DailyQuest quest;
  final VoidCallback onClaimSuccess;

  const QuestCardWithAnimation({
    super.key,
    required this.quest,
    required this.onClaimSuccess,
  });

  @override
  ConsumerState<QuestCardWithAnimation> createState() {
    return _QuestCardWithAnimationState();
  }
}

class _QuestCardWithAnimationState extends ConsumerState<QuestCardWithAnimation>
    with SingleTickerProviderStateMixin {
  late RewardCollectionController _rewardCtrl;
  final GlobalKey<_AnimatedQuestCardState> _cardKey =
      GlobalKey<_AnimatedQuestCardState>();
  OverlayEntry? _overlayEntry;
  bool _isClaimingInProgress = false;

  @override
  void initState() {
    super.initState();
    _rewardCtrl = RewardCollectionController(
      vsync: this,
      mediaQuery: MediaQuery.of(context),
    );
  }

  @override
  void dispose() {
    _rewardCtrl.dispose();
    _overlayEntry?.remove();
    super.dispose();
  }

  Future<void> _handleClaim() async {
    if (_isClaimingInProgress) return;
    _isClaimingInProgress = true;

    try {
      final viewModel = ref.read(questsViewModelProvider.notifier);

      // Iniciar loading no botão
      _cardKey.currentState?._setLoading(true);

      // Chamar a API
      await viewModel.claimQuest(widget.quest.questKey);

      if (!context.mounted) {
        _isClaimingInProgress = false;
        return;
      }

      // Obter dados atualizados
      final updatedData = ref.read(questsViewModelProvider).value;
      final updatedQuest = updatedData?.quests.firstWhere(
        (q) => q.questKey == widget.quest.questKey,
        orElse: () => widget.quest,
      );

      if (!context.mounted) {
        _isClaimingInProgress = false;
        return;
      }

      // Dados para animação
      final xpEarned = widget.quest.xpReward;
      final coinsEarned = widget.quest.coinsReward;

      // Calcular progressão da barra de XP
      // (será 0-1, representando quanto avançou na barra)
      final oldLevelXp = updatedData?.profile.xpIntoLevel ?? 0;
      final newLevelXp =
          (oldLevelXp + xpEarned) / (updatedData?.profile.xpToNextLevel ?? 1);
      final xpProgression = newLevelXp.clamp(0.0, 1.0);
      final levelUp =
          (oldLevelXp + xpEarned) >= (updatedData?.profile.xpToNextLevel ?? 1);

      // Mostrar overlay de animação
      _showRewardOverlay(
        xpEarned: xpEarned,
        coinsEarned: coinsEarned,
        xpProgression: xpProgression,
        levelUp: levelUp,
        paletteEnd: _paletteFor(widget.quest).end,
      );

      // Executar animação
      await _rewardCtrl.play(
        xpEarned: xpEarned,
        coinsEarned: coinsEarned,
        xpProgression: xpProgression,
        levelUp: levelUp,
        onComplete: () {
          _overlayEntry?.remove();
          _overlayEntry = null;
        },
      );

      // Atualizar UI do card para estado coletado
      _cardKey.currentState?._setSuccess(true);

      // Callback de sucesso
      widget.onClaimSuccess();
    } catch (e) {
      if (context.mounted) {
        _cardKey.currentState?._setError();
      }
    } finally {
      _isClaimingInProgress = false;
      _cardKey.currentState?._setLoading(false);
    }
  }

  void _showRewardOverlay({
    required int xpEarned,
    required int coinsEarned,
    required double xpProgression,
    required bool levelUp,
    required Color paletteEnd,
  }) {
    _overlayEntry = OverlayEntry(
      builder: (context) => RewardCollectionOverlay(
        controller: _rewardCtrl,
        cardCenter: _getCardCenter(),
        accentColor: paletteEnd,
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);

    // Se level up, mostrar celebração em modal
    if (levelUp && !MediaQuery.of(context).disableAnimations) {
      Future.delayed(const Duration(milliseconds: 400), () {
        if (!context.mounted) return;

        final s = S.of(context);
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => LevelUpCelebration(
            newLevel:
                (ref.read(questsViewModelProvider).value?.profile.level ?? 1),
            accentColor: paletteEnd,
            levelUpText: s.questsLevelUp,
            onComplete: () {
              Navigator.of(ctx).pop();
            },
          ),
        );
      });
    }
  }

  Offset _getCardCenter() {
    final RenderBox? cardBox =
        _cardKey.currentContext?.findRenderObject() as RenderBox?;
    if (cardBox != null) {
      final size = cardBox.size;
      final position = cardBox.localToGlobal(Offset.zero);
      return Offset(
        position.dx + size.width / 2,
        position.dy + size.height / 2,
      );
    }
    return Offset(
      MediaQuery.of(context).size.width / 2,
      MediaQuery.of(context).size.height / 2,
    );
  }

  @override
  Widget build(BuildContext context) {
    return _AnimatedQuestCard(
      key: _cardKey,
      quest: widget.quest,
      onClaim: _handleClaim,
    );
  }
}

/// Card de quest com suporte a animação.
class _AnimatedQuestCard extends StatefulWidget {
  final DailyQuest quest;
  final VoidCallback onClaim;

  const _AnimatedQuestCard({
    super.key,
    required this.quest,
    required this.onClaim,
  });

  @override
  State<_AnimatedQuestCard> createState() => _AnimatedQuestCardState();
}

class _AnimatedQuestCardState extends State<_AnimatedQuestCard> {
  bool _isLoading = false;
  bool _isSuccess = false;
  bool _showError = false;

  void _setLoading(bool value) {
    if (mounted) setState(() => _isLoading = value);
  }

  void _setSuccess(bool value) {
    if (mounted) setState(() => _isSuccess = value);
  }

  void _setError() {
    if (mounted) {
      setState(() {
        _showError = true;
        _isLoading = false;
      });
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted) setState(() => _showError = false);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Return empty widget - this file has unused references
    // and should be refactored or removed from the project
    return const SizedBox.shrink();
  }

  Widget _buildQuestCardContent() {
    // Implementar card aqui - por enquanto usando Container como placeholder
    // será integrado com o _QuestCard original do quests_screen.dart
    return Container();
  }
}

// Paleta de cores por categoria (mesmo do quests_screen.dart)
class _QuestPalette {
  final Color start;
  final Color end;
  const _QuestPalette(this.start, this.end);
}

_QuestPalette _paletteFor(DailyQuest q) {
  switch (q.category) {
    case 'engagement':
      return const _QuestPalette(Color(0xFF6E4DFF), Color(0xFF3BB8FF));
    case 'social':
      return const _QuestPalette(Color(0xFFFF4D8D), Color(0xFFFFD93D));
    case 'creator':
      return const _QuestPalette(Color(0xFF2BD995), Color(0xFF3BB8FF));
    default:
      return const _QuestPalette(Color(0xFF6E4DFF), Color(0xFFFF4D8D));
  }
}
