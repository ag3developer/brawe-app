import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/repositories/battle_assets_repository.dart';
import '../../../gen/l10n/app_localizations.dart';
import 'battle_narrator.dart';

/// Aviso informativo curto (meta atingida, outro viewer subiu de nível) para
/// o painel de avisos da live quando NÃO há batalha. Nunca vai para o chat.
@immutable
class LiveInfoNotice {
  const LiveInfoNotice(this.seq, this.text, {this.roomId});
  final int seq;
  final String text;

  /// Sala de origem (cada painel só mostra os da própria sala).
  final String? roomId;
}

class LiveInfoFeed {
  final ValueNotifier<LiveInfoNotice?> notice = ValueNotifier(null);
  int _seq = 0;

  void post(String text, {String? roomId}) {
    if (text.isEmpty) return;
    notice.value = LiveInfoNotice(++_seq, text, roomId: roomId);
  }
}

final liveInfoFeedProvider = Provider<LiveInfoFeed>((ref) {
  final f = LiveInfoFeed();
  ref.onDispose(f.notice.dispose);
  return f;
});

/// Encaminha um aviso do jogo (chaves do narrador: `goal_reached`,
/// `level_up`...): em batalha vai para o NARRADOR; fora dela, para o painel
/// de avisos ([LiveNoticeLane]). Nunca para o chat.
void routeGameNotice(
  WidgetRef ref,
  BuildContext context,
  String key,
  Map<String, String> vars, {
  String? roomId,
}) {
  final line = resolveNarratorLine(
    manifest: ref.read(battleAssetsProvider),
    l10n: S.of(context),
    lang: Localizations.localeOf(context).languageCode,
    key: key,
    vars: vars,
  );
  if (line == null) return;
  final narrator = ref.read(battleNarratorProvider);
  if (narrator.active) {
    narrator.push(line);
  } else {
    ref.read(liveInfoFeedProvider).post(line.text, roomId: roomId);
  }
}
