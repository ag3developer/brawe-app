/// Sugere títulos para a live baseado em hora do dia e categoria.
/// Funciona 100% offline — depois pode ser substituído por um endpoint backend.
class TitleSuggester {
  const TitleSuggester();

  List<String> suggest({String? category, DateTime? now}) {
    final dt = now ?? DateTime.now();
    final hour = dt.hour;
    final timeTag = _timeTag(hour);
    final cat = (category ?? '').trim();

    final byCategory = <String, List<String>>{
      'Moda': [
        '$timeTag de moda — what to wear?',
        'Look do dia ao vivo',
        'Provador online — me ajuda a escolher',
      ],
      'Beleza': [
        '$timeTag fazendo make ao vivo',
        'Skincare routine — bora juntos',
        'Resenha de produto novo',
      ],
      'Jogos': [
        'Bora jogar — quem entra?',
        'Rank up live • $timeTag',
        'Aquecimento antes do ranqueada',
      ],
      'Música': [
        '$timeTag musical — pedidos abertos',
        'Tocando ao vivo — chega aí',
        'Playlist + papo',
      ],
      'Esportes': [
        'Comentando o jogo ao vivo',
        '$timeTag esportiva — vamos comentar',
        'Treino + papo',
      ],
      'Comida': [
        '$timeTag na cozinha — bora cozinhar',
        'Receita ao vivo',
        'Testando uma receita nova',
      ],
    };

    final base = byCategory[cat] ??
        [
          '$timeTag com a galera',
          'Chega aí, vamos conversar',
          'Live aberta — pode chegar',
        ];

    return base.take(3).toList();
  }

  String _timeTag(int hour) {
    if (hour < 6) return 'Madrugada';
    if (hour < 12) return 'Bom dia';
    if (hour < 18) return 'Boa tarde';
    return 'Boa noite';
  }
}
