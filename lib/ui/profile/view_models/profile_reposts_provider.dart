import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/repositories/post_repository.dart';
import '../../../domain/models/post.dart';

/// Posts de outras pessoas que o usuário repostou (aba Reposts do perfil).
final profileRepostsProvider = FutureProvider.autoDispose
    .family<List<Post>, String>((ref, userId) {
  return ref.read(postRepositoryProvider).getUserReposts(userId);
});
