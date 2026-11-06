/// Enquete anexada a um post de texto. Voto único e definitivo.
///
/// Contagens/percentuais vêm `null` do servidor enquanto o espectador não
/// votou e a enquete segue aberta (exceto para o autor).
class PollOption {
  const PollOption({
    required this.id,
    required this.text,
    this.votes,
    this.percent,
  });

  final String id;
  final String text;
  final int? votes;
  final int? percent;

  factory PollOption.fromJson(Map<String, dynamic> json) => PollOption(
    id: json['id'].toString(),
    text: (json['text'] ?? '').toString(),
    votes: (json['votes'] as num?)?.toInt(),
    percent: (json['percent'] as num?)?.toInt(),
  );

  @override
  bool operator ==(Object other) =>
      other is PollOption &&
      other.id == id &&
      other.text == text &&
      other.votes == votes &&
      other.percent == percent;

  @override
  int get hashCode => Object.hash(id, text, votes, percent);
}

class PostPoll {
  const PostPoll({
    required this.options,
    required this.endsAt,
    this.totalVotes,
    this.ended = false,
    this.myVote,
  });

  final List<PollOption> options;
  final DateTime endsAt;
  final int? totalVotes;
  final bool ended;

  /// `option_id` em que o espectador votou, se votou.
  final String? myVote;

  factory PostPoll.fromJson(Map<String, dynamic> json) => PostPoll(
    options: [
      for (final o in (json['options'] as List? ?? const []))
        PollOption.fromJson(Map<String, dynamic>.from(o as Map)),
    ],
    endsAt: DateTime.parse(json['ends_at'].toString()),
    totalVotes: (json['total_votes'] as num?)?.toInt(),
    ended: json['ended'] == true,
    myVote: json['my_vote']?.toString(),
  );

  bool get hasVoted => myVote != null;

  /// Encerrada pelo servidor ou pelo relógio local.
  bool isEnded(DateTime now) => ended || !endsAt.isAfter(now);

  /// Resultados (barras/percentuais) só existem quando o servidor os enviou.
  bool get hasCounts => totalVotes != null && options.every((o) => o.percent != null);

  PostPoll copyWith({
    List<PollOption>? options,
    int? totalVotes,
    bool? ended,
    String? myVote,
    bool clearMyVote = false,
  }) => PostPoll(
    options: options ?? this.options,
    endsAt: endsAt,
    totalVotes: totalVotes ?? this.totalVotes,
    ended: ended ?? this.ended,
    myVote: clearMyVote ? null : (myVote ?? this.myVote),
  );

  @override
  bool operator ==(Object other) =>
      other is PostPoll &&
      other.endsAt == endsAt &&
      other.totalVotes == totalVotes &&
      other.ended == ended &&
      other.myVote == myVote &&
      _listEq(other.options, options);

  @override
  int get hashCode => Object.hash(endsAt, totalVotes, ended, myVote, Object.hashAll(options));

  static bool _listEq(List<PollOption> a, List<PollOption> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}

/// Localização do post em nível de cidade ("Recife, PE"). Nunca coordenadas.
class PostLocation {
  const PostLocation({
    required this.city,
    this.region,
    this.country,
    required this.label,
  });

  final String city;
  final String? region;

  /// ISO-3166 alpha-2.
  final String? country;
  final String label;

  factory PostLocation.fromJson(Map<String, dynamic> json) {
    final city = (json['city'] ?? '').toString();
    final region = json['region']?.toString();
    final country = json['country']?.toString();
    final label = json['label']?.toString();
    return PostLocation(
      city: city,
      region: region,
      country: country,
      label: (label != null && label.isNotEmpty)
          ? label
          : buildLabel(city, region, country),
    );
  }

  /// Mesma regra do servidor: "Cidade, UF" (ou país se não houver região).
  static String buildLabel(String city, String? region, String? country) {
    final tail = (region != null && region.isNotEmpty) ? region : country;
    return (tail == null || tail.isEmpty) ? city : '$city, $tail';
  }

  Map<String, dynamic> toRequestJson() => {
    'city': city,
    if (region != null && region!.isNotEmpty) 'region': region,
    'country': country,
  };

  @override
  bool operator ==(Object other) =>
      other is PostLocation &&
      other.city == city &&
      other.region == region &&
      other.country == country &&
      other.label == label;

  @override
  int get hashCode => Object.hash(city, region, country, label);
}
