// Privacidade da conta — API do Connect (`/privacy/*`).
//
// Configurações, resumo de outra pessoa, listas (bloqueados, silenciados, restritos),
// pedidos para seguir e exportação dos dados.

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/live_dio_provider.dart';

final privacyRepositoryProvider = Provider<PrivacyRepository>(
  (ref) => PrivacyRepository(ref.watch(liveDioProvider)),
);

/// Minha privacidade (estado compartilhado pelo hub; atualizações otimistas).
final privacyProvider =
    AsyncNotifierProvider.autoDispose<PrivacyNotifier, PrivacyOverview>(
      PrivacyNotifier.new,
    );

/// Resumo de privacidade de outra pessoa (perfil, DM, comentários…).
final privacyOfProvider = FutureProvider.autoDispose
    .family<PrivacySummary, String>(
      (ref, userId) => ref.read(privacyRepositoryProvider).summaryOf(userId),
    );

class PrivacyFailure implements Exception {
  const PrivacyFailure(this.message, {this.code});

  /// Mensagem do servidor (pt-BR) — vazia quando não há resposta (rede).
  final String message;
  final String? code;
  @override
  String toString() => message;
}

/// Valores de "quem pode".
class Who {
  const Who._();
  static const everyone = 'everyone';
  static const followers = 'followers';
  static const following = 'following';
  static const none = 'none';
}

class PrivacySettings {
  const PrivacySettings({
    required this.isPrivate,
    required this.comments,
    required this.messages,
    required this.mentions,
    required this.storyReplies,
    required this.battleInvites,
    required this.hiddenWords,
    required this.filterOffensive,
    required this.hideLikeCounts,
    required this.hideOthersLikeCounts,
    required this.showActivity,
    required this.hideFollowLists,
    required this.showInExplore,
    required this.readReceipts,
    required this.limitUntil,
  });

  final bool isPrivate;
  final String comments;
  final String messages;
  final String mentions;
  final String storyReplies;
  final String battleInvites;
  final List<String> hiddenWords;
  final bool filterOffensive;
  final bool hideLikeCounts;
  final bool hideOthersLikeCounts;
  final bool showActivity;
  final bool hideFollowLists;
  final bool showInExplore;
  final bool readReceipts;
  final DateTime? limitUntil;

  /// Limitar interações ativo agora.
  bool get limitActive =>
      limitUntil != null && limitUntil!.isAfter(DateTime.now());

  factory PrivacySettings.fromJson(Map<String, dynamic> j) {
    bool b(String k, bool d) => j[k] is bool ? j[k] as bool : d;
    String w(String k) => '${j[k] ?? Who.everyone}';
    return PrivacySettings(
      isPrivate: b('is_private', false),
      comments: w('comments'),
      messages: w('messages'),
      mentions: w('mentions'),
      storyReplies: w('story_replies'),
      battleInvites: w('battle_invites'),
      hiddenWords: ((j['hidden_words'] as List?) ?? const [])
          .map((e) => '$e')
          .toList(),
      filterOffensive: b('filter_offensive', false),
      hideLikeCounts: b('hide_like_counts', false),
      hideOthersLikeCounts: b('hide_others_like_counts', false),
      showActivity: b('show_activity', true),
      hideFollowLists: b('hide_follow_lists', false),
      showInExplore: b('show_in_explore', true),
      readReceipts: b('read_receipts', true),
      limitUntil: j['limit_until'] == null
          ? null
          : DateTime.tryParse('${j['limit_until']}')?.toLocal(),
    );
  }

  PrivacySettings copyWith({
    bool? isPrivate,
    String? comments,
    String? messages,
    String? mentions,
    String? storyReplies,
    String? battleInvites,
    List<String>? hiddenWords,
    bool? filterOffensive,
    bool? hideLikeCounts,
    bool? hideOthersLikeCounts,
    bool? showActivity,
    bool? hideFollowLists,
    bool? showInExplore,
    bool? readReceipts,
    DateTime? limitUntil,
    bool clearLimit = false,
  }) => PrivacySettings(
    isPrivate: isPrivate ?? this.isPrivate,
    comments: comments ?? this.comments,
    messages: messages ?? this.messages,
    mentions: mentions ?? this.mentions,
    storyReplies: storyReplies ?? this.storyReplies,
    battleInvites: battleInvites ?? this.battleInvites,
    hiddenWords: hiddenWords ?? this.hiddenWords,
    filterOffensive: filterOffensive ?? this.filterOffensive,
    hideLikeCounts: hideLikeCounts ?? this.hideLikeCounts,
    hideOthersLikeCounts: hideOthersLikeCounts ?? this.hideOthersLikeCounts,
    showActivity: showActivity ?? this.showActivity,
    hideFollowLists: hideFollowLists ?? this.hideFollowLists,
    showInExplore: showInExplore ?? this.showInExplore,
    readReceipts: readReceipts ?? this.readReceipts,
    limitUntil: clearLimit ? null : (limitUntil ?? this.limitUntil),
  );
}

class PrivacyCounts {
  const PrivacyCounts({this.blocked = 0, this.muted = 0, this.restricted = 0});
  final int blocked;
  final int muted;
  final int restricted;

  PrivacyCounts copyWith({int? blocked, int? muted, int? restricted}) =>
      PrivacyCounts(
        blocked: blocked ?? this.blocked,
        muted: muted ?? this.muted,
        restricted: restricted ?? this.restricted,
      );
}

class PrivacyOverview {
  const PrivacyOverview({
    required this.settings,
    required this.canBePrivate,
    required this.accountType,
    required this.followRequests,
    required this.counts,
  });

  final PrivacySettings settings;
  final bool canBePrivate;
  final String accountType;
  final int followRequests;
  final PrivacyCounts counts;

  factory PrivacyOverview.fromJson(Map<String, dynamic> j) {
    final c = j['counts'] is Map
        ? Map<String, dynamic>.from(j['counts'] as Map)
        : <String, dynamic>{};
    int n(Object? v) => v is num ? v.toInt() : 0;
    return PrivacyOverview(
      settings: PrivacySettings.fromJson(
        j['settings'] is Map
            ? Map<String, dynamic>.from(j['settings'] as Map)
            : <String, dynamic>{},
      ),
      canBePrivate: j['can_be_private'] == true,
      accountType: '${j['account_type'] ?? 'consumer'}',
      followRequests: n(j['follow_requests']),
      counts: PrivacyCounts(
        blocked: n(c['blocked']),
        muted: n(c['muted']),
        restricted: n(c['restricted']),
      ),
    );
  }

  PrivacyOverview copyWith({
    PrivacySettings? settings,
    int? followRequests,
    PrivacyCounts? counts,
  }) => PrivacyOverview(
    settings: settings ?? this.settings,
    canBePrivate: canBePrivate,
    accountType: accountType,
    followRequests: followRequests ?? this.followRequests,
    counts: counts ?? this.counts,
  );
}

/// Privacidade de outra pessoa vista por mim.
class PrivacySummary {
  const PrivacySummary({
    required this.userId,
    required this.isPrivate,
    required this.canViewContent,
    required this.canViewFollowLists,
    required this.followStatus,
    required this.canComment,
    required this.canMessage,
    required this.canMention,
    required this.canReplyStories,
    required this.canInviteBattle,
    required this.hideLikeCounts,
    required this.showActivity,
    required this.isRestricted,
  });

  final String userId;
  final bool isPrivate;
  final bool canViewContent;
  final bool canViewFollowLists;

  /// self · following · requested · none
  final String followStatus;
  final bool canComment;
  final bool canMessage;
  final bool canMention;
  final bool canReplyStories;
  final bool canInviteBattle;
  final bool hideLikeCounts;
  final bool showActivity;
  final bool isRestricted;

  factory PrivacySummary.fromJson(Map<String, dynamic> j) {
    bool b(String k, [bool d = true]) => j[k] is bool ? j[k] as bool : d;
    return PrivacySummary(
      userId: '${j['user_id'] ?? ''}',
      isPrivate: b('is_private', false),
      canViewContent: b('can_view_content'),
      canViewFollowLists: b('can_view_follow_lists'),
      followStatus: '${j['follow_status'] ?? 'none'}',
      canComment: b('can_comment'),
      canMessage: b('can_message'),
      canMention: b('can_mention'),
      canReplyStories: b('can_reply_stories'),
      canInviteBattle: b('can_invite_battle'),
      hideLikeCounts: b('hide_like_counts', false),
      showActivity: b('show_activity'),
      isRestricted: b('is_restricted', false),
    );
  }
}

/// Pessoa em uma das listas (bloqueada, silenciada, restrita ou pedido para seguir).
class PrivacyAccount {
  const PrivacyAccount({
    required this.userId,
    required this.username,
    required this.displayName,
    required this.avatarUrl,
    required this.isVerified,
    required this.since,
  });

  final String userId;
  final String username;
  final String displayName;
  final String? avatarUrl;
  final bool isVerified;

  /// `since` (listas) ou `requested_at` (pedidos).
  final DateTime? since;

  String get name => displayName.isNotEmpty ? displayName : username;

  factory PrivacyAccount.fromJson(Map<String, dynamic> j) => PrivacyAccount(
    userId: '${j['user_id']}',
    username: '${j['username'] ?? ''}',
    displayName: '${j['display_name'] ?? ''}',
    avatarUrl: j['avatar_url'] as String?,
    isVerified: j['is_verified'] == true,
    since: DateTime.tryParse(
      '${j['since'] ?? j['requested_at'] ?? ''}',
    )?.toLocal(),
  );
}

enum PrivacyList { blocked, muted, restricted }

class PrivacyNotifier extends AsyncNotifier<PrivacyOverview> {
  PrivacyNotifier();

  PrivacyRepository get _repo => ref.read(privacyRepositoryProvider);

  @override
  Future<PrivacyOverview> build() => _repo.overview();

  /// PATCH otimista: aplica [apply] já, envia [body] e volta atrás se falhar
  /// (a exceção sobe para a tela mostrar o aviso).
  Future<void> patch(
    Map<String, dynamic> body,
    PrivacySettings Function(PrivacySettings) apply,
  ) async {
    final prev = state.value;
    if (prev == null) return;
    state = AsyncData(prev.copyWith(settings: apply(prev.settings)));
    try {
      final saved = await _repo.patch(body);
      final cur = state.value ?? prev;
      state = AsyncData(cur.copyWith(settings: saved));
    } catch (e) {
      state = AsyncData(state.value?.copyWith(settings: prev.settings) ?? prev);
      rethrow;
    }
  }

  /// Ajusta os contadores locais depois de agir numa lista.
  void bump({PrivacyList? list, int delta = 0, int requestsDelta = 0}) {
    final cur = state.value;
    if (cur == null) return;
    var c = cur.counts;
    int clamp(int v) => v < 0 ? 0 : v;
    if (list != null) {
      c = switch (list) {
        PrivacyList.blocked => c.copyWith(blocked: clamp(c.blocked + delta)),
        PrivacyList.muted => c.copyWith(muted: clamp(c.muted + delta)),
        PrivacyList.restricted => c.copyWith(
          restricted: clamp(c.restricted + delta),
        ),
      };
    }
    state = AsyncData(
      cur.copyWith(
        counts: c,
        followRequests: clamp(cur.followRequests + requestsDelta),
      ),
    );
  }

  void setFollowRequests(int n) {
    final cur = state.value;
    if (cur != null) state = AsyncData(cur.copyWith(followRequests: n));
  }
}

class PrivacyRepository {
  PrivacyRepository(this._dio);
  final Dio _dio;

  PrivacyFailure _fail(Object e) {
    if (e is DioException) {
      final d = e.response?.data;
      final det = d is Map ? d['detail'] : null;
      if (det is Map && det['message'] != null) {
        return PrivacyFailure(
          det['message'].toString(),
          code: det['code']?.toString(),
        );
      }
      if (det is String) return PrivacyFailure(det);
    }
    return const PrivacyFailure('');
  }

  Future<T> _run<T>(Future<T> Function() f) async {
    try {
      return await f();
    } catch (e) {
      throw _fail(e);
    }
  }

  Map<String, dynamic> _map(dynamic d) =>
      d is Map ? Map<String, dynamic>.from(d) : <String, dynamic>{};

  List<PrivacyAccount> _items(dynamic d) =>
      ((_map(d)['items'] as List?) ?? const [])
          .whereType<Map>()
          .map((e) => PrivacyAccount.fromJson(Map<String, dynamic>.from(e)))
          .toList();

  Future<PrivacyOverview> overview() => _run(
    () async =>
        PrivacyOverview.fromJson(_map((await _dio.get('/privacy')).data)),
  );

  Future<PrivacySettings> patch(Map<String, dynamic> body) => _run(() async {
    final r = await _dio.patch('/privacy', data: body);
    return PrivacySettings.fromJson(_map(_map(r.data)['settings']));
  });

  Future<PrivacySummary> summaryOf(String userId) => _run(
    () async => PrivacySummary.fromJson(
      _map((await _dio.get('/privacy/of/$userId')).data),
    ),
  );

  String _path(PrivacyList l) => switch (l) {
    PrivacyList.blocked => 'blocked',
    PrivacyList.muted => 'muted',
    PrivacyList.restricted => 'restricted',
  };

  Future<List<PrivacyAccount>> list(PrivacyList l, {String q = ''}) =>
      _run(() async {
        final r = await _dio.get(
          '/privacy/${_path(l)}',
          queryParameters: q.trim().isEmpty ? null : {'q': q.trim()},
        );
        return _items(r.data);
      });

  Future<void> remove(PrivacyList l, String userId) =>
      _run(() => _dio.delete('/privacy/${_path(l)}/$userId'));

  Future<void> restrict(String userId) =>
      _run(() => _dio.post('/privacy/restricted/$userId'));

  Future<List<PrivacyAccount>> followRequests() => _run(
    () async => _items((await _dio.get('/privacy/follow-requests')).data),
  );

  Future<void> acceptRequest(String id) =>
      _run(() => _dio.post('/privacy/follow-requests/$id/accept'));

  Future<void> declineRequest(String id) =>
      _run(() => _dio.post('/privacy/follow-requests/$id/decline'));

  Future<void> acceptAll() =>
      _run(() => _dio.post('/privacy/follow-requests/accept-all'));

  Future<void> cancelSentRequest(String targetId) =>
      _run(() => _dio.delete('/privacy/follow-requests/sent/$targetId'));

  /// JSON bruto dos meus dados.
  Future<Object?> export() => _run(() async {
    final r = await _dio.get(
      '/privacy/export',
      options: Options(receiveTimeout: const Duration(minutes: 2)),
    );
    return r.data;
  });
}
