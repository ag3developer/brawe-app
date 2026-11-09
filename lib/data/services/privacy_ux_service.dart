import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/live_dio_provider.dart';
import '../repositories/auth_state_provider.dart';
import 'post_service.dart';

/// Chamadas pequenas de privacidade usadas onde as pessoas interagem
/// (perfil, comentários, notificações, chat). A tela de ajustes de
/// privacidade tem o próprio repositório.

/// Erro do servidor no formato `detail: {code, message}`.
class PrivacyApiError {
  const PrivacyApiError({this.code, this.message, this.status});
  final String? code;
  final String? message;
  final int? status;

  static PrivacyApiError? from(Object e) {
    if (e is! DioException) return null;
    final data = e.response?.data;
    final detail = data is Map ? data['detail'] : null;
    if (detail is Map) {
      return PrivacyApiError(
        code: detail['code']?.toString(),
        message: detail['message']?.toString(),
        status: e.response?.statusCode,
      );
    }
    return PrivacyApiError(status: e.response?.statusCode);
  }

  /// Código do 403 de regra de privacidade, se for um.
  static String? codeOf(Object e) => from(e)?.code;

  /// Mensagem pronta do servidor para o código dado (ou null).
  static String? messageFor(Object e, Set<String> codes) {
    final err = from(e);
    if (err == null || !codes.contains(err.code)) return null;
    final m = err.message;
    return (m == null || m.isEmpty) ? null : m;
  }
}

/// `GET /privacy/of/{id}`: o que EU posso fazer com essa pessoa.
class UserPrivacy {
  const UserPrivacy({
    this.isPrivate = false,
    this.canViewContent = true,
    this.canViewFollowLists = true,
    this.followStatus = 'none',
    this.canComment = true,
    this.canMessage = true,
    this.canReplyStories = true,
    this.canInviteBattle = true,
    this.hideLikeCounts = false,
    this.showActivity = true,
    this.isRestricted = false,
    this.messageBlockedReason,
  });

  final bool isPrivate;
  final bool canViewContent;
  final bool canViewFollowLists;
  final String followStatus;
  final bool canComment;
  final bool canMessage;
  final bool canReplyStories;
  final bool canInviteBattle;
  final bool hideLikeCounts;
  final bool showActivity;
  final bool isRestricted;
  final String? messageBlockedReason;

  factory UserPrivacy.fromJson(Map<String, dynamic> j) => UserPrivacy(
    isPrivate: j['is_private'] == true,
    canViewContent: j['can_view_content'] != false,
    canViewFollowLists: j['can_view_follow_lists'] != false,
    followStatus: (j['follow_status'] ?? 'none').toString(),
    canComment: j['can_comment'] != false,
    canMessage: j['can_message'] != false,
    canReplyStories: j['can_reply_stories'] != false,
    canInviteBattle: j['can_invite_battle'] != false,
    hideLikeCounts: j['hide_like_counts'] == true,
    showActivity: j['show_activity'] != false,
    isRestricted: j['is_restricted'] == true,
  );

  UserPrivacy copyWith({bool? isRestricted}) => UserPrivacy(
    isPrivate: isPrivate,
    canViewContent: canViewContent,
    canViewFollowLists: canViewFollowLists,
    followStatus: followStatus,
    canComment: canComment,
    canMessage: canMessage,
    canReplyStories: canReplyStories,
    canInviteBattle: canInviteBattle,
    hideLikeCounts: hideLikeCounts,
    showActivity: showActivity,
    isRestricted: isRestricted ?? this.isRestricted,
  );
}

class PrivacyUxService {
  PrivacyUxService(this._dio);
  final Dio _dio;

  Future<UserPrivacy> of(String userId) async {
    final r = await _dio.get('/privacy/of/$userId');
    return UserPrivacy.fromJson(Map<String, dynamic>.from(r.data as Map));
  }

  Future<bool> hideOthersLikeCounts() async {
    final r = await _dio.get('/privacy');
    final s = (r.data as Map)['settings'];
    return s is Map && s['hide_others_like_counts'] == true;
  }

  Future<void> cancelSentRequest(String targetId) async {
    await _dio.delete('/privacy/follow-requests/sent/$targetId');
  }

  Future<void> acceptRequest(String requesterId) async {
    await _dio.post('/privacy/follow-requests/$requesterId/accept');
  }

  Future<void> declineRequest(String requesterId) async {
    await _dio.post('/privacy/follow-requests/$requesterId/decline');
  }

  Future<int> pendingRequestsCount() async {
    final r = await _dio.get('/privacy/follow-requests');
    final items = (r.data as Map)['items'];
    return items is List ? items.length : 0;
  }

  Future<void> setRestricted(String userId, bool restricted) async {
    if (restricted) {
      await _dio.post('/privacy/restricted/$userId');
    } else {
      await _dio.delete('/privacy/restricted/$userId');
    }
  }

  Future<bool> setCommentsDisabled(String postId, bool disabled) async {
    final r = await _dio.patch(
      '/posts/$postId/comments-settings',
      data: {'comments_disabled': disabled},
    );
    final d = r.data;
    return d is Map ? d['comments_disabled'] == true : disabled;
  }
}

final privacyUxServiceProvider = Provider<PrivacyUxService>(
  (ref) => PrivacyUxService(ref.watch(liveDioProvider)),
);

/// Regras que valem entre mim e [userId]. Falha de rede = sem restrição
/// (o servidor ainda aplica as regras de verdade).
final userPrivacyProvider = FutureProvider.autoDispose
    .family<UserPrivacy, String>((ref, userId) async {
      try {
        return await ref.read(privacyUxServiceProvider).of(userId);
      } catch (_) {
        return const UserPrivacy();
      }
    });

/// Quantos pedidos para seguir estão pendentes comigo.
final pendingFollowRequestsProvider = FutureProvider.autoDispose<int>((
  ref,
) async {
  try {
    return await ref.read(privacyUxServiceProvider).pendingRequestsCount();
  } catch (_) {
    return 0;
  }
});

/// Minha preferência "ocultar curtidas dos outros" (lida uma vez).
final hideOthersLikeCountsProvider = FutureProvider<bool>((ref) async {
  final uid = ref.watch(authStateProvider.select((a) => a.value?.id));
  if (uid == null) return false;
  try {
    return await ref.read(privacyUxServiceProvider).hideOthersLikeCounts();
  } catch (_) {
    return false;
  }
});

/// Pedido para seguir pendente por [userId] (perfil privado).
class FollowRequestedNotifier extends Notifier<bool> {
  FollowRequestedNotifier(this.userId);
  final String userId;

  @override
  bool build() =>
      ref.watch(userPrivacyProvider(userId)).value?.followStatus == 'requested';

  void set(bool v) => state = v;
}

final followRequestedProvider = NotifierProvider.autoDispose
    .family<FollowRequestedNotifier, bool, String>(FollowRequestedNotifier.new);

/// Ação recusada por regra de privacidade (403 com `code` + `message`).
class PrivacyBlockedException implements Exception {
  const PrivacyBlockedException(this.code, this.message);
  final String code;
  final String? message;
}

/// Comentário recusado pelas regras de privacidade (403).
class CommentBlockedException implements Exception {
  const CommentBlockedException(this.code, this.message);
  final String code;
  final String? message;
}

/// Regras de comentário do post para MIM: desativados / quem pode comentar.
typedef CommentRules = ({bool disabled, bool canComment});

final postCommentRulesProvider = FutureProvider.autoDispose
    .family<CommentRules, String>((ref, postId) async {
      try {
        final dto = await ref.read(postServiceProvider).getById(postId);
        return (disabled: dto.commentsDisabled, canComment: dto.canComment);
      } catch (_) {
        return (disabled: false, canComment: true);
      }
    });

/// Esconder o número de curtidas deste post para mim?
/// Vale quando o autor escondeu (e eu não sou ele) ou eu escondi as dos outros.
bool shouldHideLikeCount(
  WidgetRef ref, {
  required String authorId,
  required bool postHides,
}) {
  final me = ref.watch(authStateProvider.select((a) => a.value?.id));
  if (me != null && me == authorId) return false;
  if (postHides) return true;
  return ref.watch(hideOthersLikeCountsProvider).value ?? false;
}
