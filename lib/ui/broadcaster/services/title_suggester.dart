import '../../../gen/l10n/app_localizations.dart';

/// Sugere títulos para a live baseado em hora do dia e categoria.
/// Funciona 100% offline — depois pode ser substituído por um endpoint backend.
///
/// Os títulos são localizados via `S.of(context)` — o caller passa a instância
/// `S` (lookup) ao chamar `suggest`. A categoria recebida é o ID canônico
/// (ex: 'Música', 'Beleza') usado no backend; o suggester só usa esse ID
/// para escolher o grupo de sugestões.
class TitleSuggester {
  const TitleSuggester();

  List<String> suggest({
    required S s,
    String? category,
    DateTime? now,
  }) {
    final dt = now ?? DateTime.now();
    final hour = dt.hour;
    final timeTag = _timeTag(s, hour);
    final cat = (category ?? '').trim();

    final byCategory = <String, List<String>>{
      'Moda': [
        s.suggestModa1(timeTag),
        s.suggestModa2,
        s.suggestModa3,
      ],
      'Beleza': [
        s.suggestBeleza1(timeTag),
        s.suggestBeleza2,
        s.suggestBeleza3,
      ],
      'Jogos': [
        s.suggestJogos1,
        s.suggestJogos2(timeTag),
        s.suggestJogos3,
      ],
      'Música': [
        s.suggestMusica1(timeTag),
        s.suggestMusica2,
        s.suggestMusica3,
      ],
      'Esportes': [
        s.suggestEsportes1,
        s.suggestEsportes2(timeTag),
        s.suggestEsportes3,
      ],
      'Comida': [
        s.suggestComida1(timeTag),
        s.suggestComida2,
        s.suggestComida3,
      ],
    };

    final base = byCategory[cat] ??
        [
          s.suggestGeneric1(timeTag),
          s.suggestGeneric2,
          s.suggestGeneric3,
        ];

    return base.take(3).toList();
  }

  String _timeTag(S s, int hour) {
    if (hour < 6) return s.suggestTimeDawn;
    if (hour < 12) return s.suggestTimeMorning;
    if (hour < 18) return s.suggestTimeAfternoon;
    return s.suggestTimeEvening;
  }
}
