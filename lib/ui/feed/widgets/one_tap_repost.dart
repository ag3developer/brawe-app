import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/repositories/post_repository.dart';
import '../../../data/services/feedback_service.dart';
import '../../../gen/l10n/app_localizations.dart';

/// Repost em UM toque, como o curtir: o estado muda na hora ([apply]),
/// há feedback tátil/sonoro e um aviso na tela atual com "Desfazer".
/// Tocar de novo num post já repostado desfaz direto. Se a API falhar,
/// o estado é revertido e o erro aparece como aviso na própria tela.
///
/// [apply] recebe o novo estado (`true` = repostado) e deve atualizar o
/// ícone/cor/contagem da tela chamadora.
Future<void> oneTapRepost({
  required BuildContext context,
  required WidgetRef ref,
  required String postId,
  required bool currentlyReposted,
  required void Function(bool reposted) apply,
}) async {
  final messenger = ScaffoldMessenger.maybeOf(context);
  final s = S.of(context);
  final repo = ref.read(postRepositoryProvider);
  ref.read(feedbackServiceProvider).repost();

  void toast(String text, {SnackBarAction? action}) {
    messenger?.hideCurrentSnackBar();
    messenger?.showSnackBar(
      SnackBar(
        content: Text(text),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        action: action,
      ),
    );
  }

  Future<void> undo() async {
    apply(false);
    try {
      await repo.toggleRepost(postId, true);
      toast(s.feedRepostUndone);
    } catch (_) {
      apply(true);
      toast(s.feedCannotShare);
    }
  }

  apply(!currentlyReposted);
  try {
    await repo.toggleRepost(postId, currentlyReposted);
    if (currentlyReposted) {
      toast(s.feedRepostUndone);
    } else {
      toast(
        s.mediaRepostedToast,
        action: SnackBarAction(label: s.mediaUndo, onPressed: undo),
      );
    }
  } catch (_) {
    apply(currentlyReposted);
    toast(s.feedCannotShare);
  }
}
